//
//  EventView.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI

struct EventView: View {
    let event: Event
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                imageView
                dateView
                    .padding(10)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                locationView
                    .padding(10)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                descriptionView
                    .padding(10)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                    .padding(.bottom, 25)
                linkView
                    .padding(.bottom, 10)
            }
            .navigationTitle(event.name)
        }
    }
    
    var dateView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("DATE")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            HorizontalDivider()
            Text(event.date)
        }
    }
    
    var locationView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("LOCATION")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            HorizontalDivider()
            Text(event.location)
        }
    }
    
    var imageView: some View {
        AsyncImage(url: URL(string: event.image ?? ""))
            //.resizable()
            .frame(width: 500, height: 500)
    }
    
    var descriptionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("DESCRIPTION")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            HorizontalDivider()
            Text(event.description ?? "")
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var linkView: some View {
        Link("TICKETS", destination: URL(string: event.website ?? "")!)
            .font(.system(size: 30, weight: .bold, design: .monospaced))
            .foregroundColor(.orange)
    }
}

struct EventView_Previews: PreviewProvider {
    @State static var event = Event(name: "Art Fair", date: "8-25-23", location: "Detroit", locationNarrowed: "DIA", address: "123 Woodward Ave", neighborhood: "Downtown", category: "Art", website: "www.google.com", image: nil, description: "It's gonna be a blast! Come on by", price: 0, timeStart: 700, timeEnd: 1100, rating: 5)
    
    static var previews: some View {
        EventView(event: event)
    }
}
