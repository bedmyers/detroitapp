//
//  Event.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI

struct Event: Identifiable {
    var id = UUID()
    var name: String
    var date: String
    //var neighborhood: String
    var locationShortName: String
    var location: String
    var website: String?
    var image: Image?
    var description: String
}
