//
//  EventViewModel.swift
//  DetroitApp
//
//  Created by Blair Myers on 7/13/23.
//

import Foundation
import FirebaseDatabase
import CoreLocation

final class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    private lazy var databasePath: DatabaseReference? = {
        let ref = Database.database().reference()
        return ref
    }()
    
    var eventsLoaded = false
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let geocoder = CLGeocoder()
    
    private let queue = DispatchQueue(label: "geocodingQueue", attributes: .concurrent)
    private let semaphore = DispatchSemaphore(value: 1)
    private let maxRetries = 3
    
    func listentoRealtimeDatabase() {
        guard !eventsLoaded else {
            return
        }

        guard let databasePath = databasePath else {
            return
        }

        // Fetch all events first
        databasePath.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self, snapshot.exists() else {
                print("No events found in the database.")
                return
            }
            
            var fetchedEvents: [Event] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let json = childSnapshot.value as? [String: Any] {
                    do {
                        let eventData = try JSONSerialization.data(withJSONObject: json)
                        let event = try self.decoder.decode(Event.self, from: eventData)
                        fetchedEvents.append(event)
                    } catch {
                        print("An error occurred while decoding event: \(error)")
                    }
                }
            }
            
            // Log the number of events fetched
            print("Fetched \(fetchedEvents.count) events.")
            
            // Geocode all fetched events
            self.geocodeEvents(events: fetchedEvents)
        }
        
        eventsLoaded = true
    }
    
    func stopListening() {
        databasePath?.removeAllObservers()
    }
    
    private func geocodeEvents(events: [Event]) {
        let group = DispatchGroup()
        
        for event in events {
            group.enter()
            queue.async { [weak self] in
                guard let self = self else { return }
                self.geocodeEvent(event: event, retryCount: 0) {
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("All geocoding tasks are complete. Total events: \(self.events.count)")
        }
    }
    
    private func geocodeEvent(event: Event, retryCount: Int, completion: @escaping () -> Void) {
        print("Starting geocoding for event: \(event.name)")
        semaphore.wait()
        geocoder.geocodeAddressString(event.address) { [weak self] placemarks, error in
            defer {
                self?.semaphore.signal()
            }
            
            if let error = error {
                print("Geocoding failed for address: \(event.address) with error: \(error)")
                if retryCount < self?.maxRetries ?? 0 {
                    print("Retrying geocoding for event: \(event.name), attempt \(retryCount + 1)")
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        self?.geocodeEvent(event: event, retryCount: retryCount + 1, completion: completion)
                    }
                } else {
                    completion()
                }
            } else if let self = self, let placemark = placemarks?.first, let location = placemark.location {
                var updatedEvent = event
                updatedEvent.latitude = location.coordinate.latitude
                updatedEvent.longitude = location.coordinate.longitude
                DispatchQueue.main.async {
                    self.events.append(updatedEvent)
                    print("Geocoded event: \(event.name) at latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude)")
                }
                completion()
            } else {
                print("Geocoding failed for address: \(event.address) with no placemarks.")
                if retryCount < self?.maxRetries ?? 0 {
                    print("Retrying geocoding for event: \(event.name), attempt \(retryCount + 1)")
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        self?.geocodeEvent(event: event, retryCount: retryCount + 1, completion: completion)
                    }
                } else {
                    completion()
                }
            }
        }
    }
}
