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
                titleView
                dateView
                    .padding(10)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                locationView
                    .padding(10)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                priceView
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
    
    var titleView: some View {
        VStack {
            Text(event.name)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
        }
    }
    
    var priceView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("PRICE")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            HorizontalDivider()
            if event.price == "Free" {
                Text("Free")
            } else {
                Text(event.price ?? "")
            }
        }
    }
    
    var dateView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("TIME")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            HorizontalDivider()
            Text(event.formattedDate)
            Text("\(event.formattedTimes.0) - \(event.formattedTimes.1)")
        }
    }
    
    var locationView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("LOCATION")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            HorizontalDivider()
            Text(event.neighborhood)
            Text(event.location)
            Text(event.address)
        }
    }
    
    var imageView: some View {
        AsyncImage(
            url: URL(string: event.image ?? ""),
            content: { image in
                image.resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(maxWidth: 500, maxHeight: 500)
            },
            placeholder: {
                ProgressView()
            }
        )
    }
    
    var descriptionView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ABOUT")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            HorizontalDivider()
            
            Text(event.processedDescription)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var linkView: some View {
        Link("WEBSITE", destination: URL(string: event.website ?? "")!)
            .font(.system(size: 30, weight: .bold, design: .monospaced))
            .foregroundColor(.orange)
    }
}

struct EventView_Previews: PreviewProvider {
    @State static var event = Event(name: "Art Fair", date: "8/25/23", location: "Detroit Institute of Arts", locationNarrowed: "DIA", address: "123 Woodward Ave", neighborhood: "Midtown", category: "Art", website: "www.google.com", image: nil, description: "It's gonna be a blast! Come on by", price: "5", timeStart: 700, timeEnd: 1100, rating: 5, type: "Concert")
    
    static var previews: some View {
        EventView(event: event)
    }
}

extension String {
    var paragraphs: [String] {
        return self.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }
}
