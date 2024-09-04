//
//  EventViewModel.swift
//  DetroitApp
//
//  Created by Blair Myers on 7/13/23.
//

import Foundation
import FirebaseDatabase
import CoreLocation
import Combine

final class EventViewModel: NSObject, ObservableObject {
    @Published private(set) var eventsByDay: [String: [Event]] = [:]
    @Published var userNeighborhood: String?

    private let databasePath: DatabaseReference = Database.database().reference()
    private let decoder = JSONDecoder()
    private let locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        setupLocationObserver()
    }

    private func setupLocationObserver() {
        locationManager.$location
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let location = location else { return }
                self?.determineUserNeighborhood(from: location)
            }
            .store(in: &cancellables)
    }

    func listentoRealtimeDatabase() {
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

            self.processAndSortEvents(fetchedEvents)
        }
    }

    private func processAndSortEvents(_ events: [Event]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sortedEvents = Dictionary(grouping: events) { $0.fullDate }
                .mapValues { $0.sorted { $0.timeStart ?? 0 < $1.timeStart ?? 0 } }
            
            DispatchQueue.main.async {
                self.eventsByDay = sortedEvents
            }
        }
    }

    private func determineUserNeighborhood(from location: CLLocation) {
        let neighborhoodCenters: [String: CLLocation] = [
            "Downtown": CLLocation(latitude: 42.3314, longitude: -83.0458),
            "Midtown": CLLocation(latitude: 42.3480, longitude: -83.0580),
            "Corktown": CLLocation(latitude: 42.3317, longitude: -83.0675),
            "Eastern Market": CLLocation(latitude: 42.3473, longitude: -83.0405),
            "North End": CLLocation(latitude: 42.3839, longitude: -83.0821),
            "Southwest": CLLocation(latitude: 42.3179, longitude: -83.0921),
            "East Side": CLLocation(latitude: 42.3748, longitude: -82.9645),
            "Hamtramck": CLLocation(latitude: 42.3926, longitude: -83.0496)
        ]

        var closestNeighborhood: String?
        var smallestDistance: CLLocationDistance = Double.greatestFiniteMagnitude

        for (neighborhood, center) in neighborhoodCenters {
            let distance = location.distance(from: center)
            if distance < smallestDistance {
                smallestDistance = distance
                closestNeighborhood = neighborhood
            }
        }

        print("Detected neighborhood: \(closestNeighborhood ?? "None")")
        DispatchQueue.main.async {
            self.userNeighborhood = closestNeighborhood
        }
    }
    
    func getEvents(for date: String, category: String? = nil, location: String? = nil) -> [Event] {
        let events = eventsByDay[date] ?? []
        return events.filter { event in
            (category == nil || event.category == category) &&
            (location == nil || event.neighborhood == location)
        }
    }
}
