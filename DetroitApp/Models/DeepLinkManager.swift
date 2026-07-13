//
//  DeepLinkManager.swift
//  DetroitApp
//
//  Created by Blair Myers on 3/24/24.
//

import SwiftUI

class DeepLinkManager: ObservableObject {
    @Published var deepLinkEventId: String?
    
    func handleDeepLink(_ url: URL) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if urlComponents?.scheme == "offwoodward", let host = urlComponents?.host, host == "event" {
            let pathComponents = url.pathComponents
            let eventIdPathComponents = pathComponents.dropFirst(1)
            let eventId = eventIdPathComponents.joined(separator: "/").removingPercentEncoding

            DispatchQueue.main.async {
                self.deepLinkEventId = eventId
            }
        }
    }
}
