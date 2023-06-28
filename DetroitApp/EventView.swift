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
        event.image?
            .resizable()
            .frame(width: 500, height: 500)
    }
    
    var descriptionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("DESCRIPTION")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
            HorizontalDivider()
            Text(event.description)
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
    static var previews: some View {
        @State var event = Event(name: "Van Gogh in America", date: "Fri. 2 Jun - Sat. 3 Jun\n5:00 - 11:00PM", locationShortName: "DIA", location: "Detroit Institute of Arts\n5200 Woodward Ave\nDetroit, MI, 48202", website: "https://dia.org/events/exhibitions/van-gogh-america", image: Image("VanGogh"), description: "See Van Gogh in Detroit with the exhibition Van Gogh in America, which celebrates the Detroit Institute of Art’s status as the first public museum in the United States to purchase a painting by Vincent van Gogh, his Self-Portrait (1887). On the 100th anniversary of its acquisition, experience 74 authentic Van Gogh works from around the world and discover the fascinating story of America’s introduction to this iconic artist, in an exhibition only at the DIA.\nA full-length, illustrated catalogue with essays by the exhibition curator and Van Gogh scholars will accompany the exhibition. The Detroit Institute of Arts is the exclusive venue for this exhibition.\nThe exhibition will explore the considerable efforts made by early promoters of modernism in the United States—including dealers, collectors, private art organizations, public institutions, and the artist’s family—to introduce the artist, his biography, and his artistic production into the American consciousness.")
        EventView(event: event)
    }
}
