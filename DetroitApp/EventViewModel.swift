//
//  EventViewModel.swift
//  DetroitApp
//
//  Created by Blair Myers on 7/13/23.
//

import Foundation
import FirebaseDatabase

final class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    private lazy var databasePath: DatabaseReference? = {
        let ref = Database.database().reference()
        return ref
    }()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func listentoRealtimeDatabase() {
        guard let databasePath = databasePath else {
            return
        }
        databasePath
            .observe(.childAdded) { [weak self] snapshot in
                guard
                    let self = self,
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                do {
                    let eventData = try JSONSerialization.data(withJSONObject: json)
                    let event = try self.decoder.decode(Event.self, from: eventData)
                    self.events.append(event)
                } catch {
                    print("an error occurred", error)
                }
            }
    }
    
    func stopListening() {
        databasePath?.removeAllObservers()
    }
}
