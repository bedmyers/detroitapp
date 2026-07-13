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
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deepLinkManager)
                .environmentObject(eventViewModel)
                .onOpenURL { url in
                    deepLinkManager.handleDeepLink(url)
                }
        }
    }
}
