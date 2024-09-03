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
    @StateObject private var deepLinkManager = DeepLinkManager()
    @StateObject private var eventViewModel = EventViewModel()

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
                .environmentObject(eventViewModel)
                .onOpenURL { url in
                    print("URL received: \(url)")
                    deepLinkManager.handleDeepLink(url)
                }
        }
    }
}
