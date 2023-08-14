//
//  Event.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI

struct Event: Decodable {
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
    let price: Double?
    let timeStart: Int?
    let timeEnd: Int?
    let rating: Int
}
