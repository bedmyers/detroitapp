//
//  Event.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI

struct Event: Decodable, Hashable {
    let name: String
    let date: String
    let location: String
    let locationNarrowed: String?
    let address: String
    let neighborhood: String
    let category: String
    let website: String?
    let image: String?
    let description: String?
    let price: Int?
    let timeStart: Int?
    let timeEnd: Int?
    let rating: Int
    
    var processedDescription: String {
        return description?.replacingOccurrences(of: "\\n\\n", with: "\n\n") ?? ""
    }
    
    var dayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        guard let eventDate = dateFormatter.date(from: date) else {
            return ""
        }

        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: eventDate)
    }
}
