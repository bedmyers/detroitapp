//
//  DetroitAppApp.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI
import FirebaseCore

@main
struct DetroitAppApp: App {
    var deepLinkManager = DeepLinkManager()
    
    init() {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else if let error = error {
                print("Notification permissions denied with error: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deepLinkManager)
                .onOpenURL { url in
                    print("URL received: \(url)")
                    let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
                    if urlComponents?.scheme == "offwoodward", let host = urlComponents?.host, host == "event" {
                        let pathComponents = url.pathComponents
                        
                        let eventIdPathComponents = pathComponents.dropFirst(1)
                        let eventId = eventIdPathComponents.joined(separator: "/").removingPercentEncoding
                        
                        print("Deep link to event with ID: \(eventId ?? "")")
                        deepLinkManager.deepLinkEventId = eventId
                    }
                }
        }
    }

    func handleDeepLink(_ url: URL) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if urlComponents?.scheme == "offwoodward", let host = urlComponents?.host, host == "event" {
            let pathComponents = url.pathComponents
            if pathComponents.count >= 3 {
                let eventId = pathComponents[2].removingPercentEncoding
                print("Deep link to event with ID: \(eventId ?? "")")
                deepLinkManager.deepLinkEventId = eventId
            }
        }
    }
}
