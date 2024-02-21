//
//  EventView.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI
import EventKit

struct EventView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showingShareSheet = false
    @State private var isOptionSheetPresented = false
    @State private var eventStore = EKEventStore()
    @State private var sharedItems: [Any] = []
    let event: Event
    
    var body: some View {
        ZStack {
            Color(.offWhite)
                .ignoresSafeArea()
            ScrollView(.vertical) {
                VStack {
                    moreView
                        .padding(.trailing, 20)
                        .padding(5)
                    titleView
                        .frame(alignment: .leading)
                        .padding(.leading, 10)
                        .padding(.trailing, 25)
                    imageView
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    dateView
                        .padding(10)
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    locationView
                        .padding(10)
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    priceView
                        .padding(10)
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    if event.processedDescription != "" {
                        descriptionView
                            .padding(10)
                            .padding(.leading, 25)
                            .padding(.trailing, 25)
                            .padding(.bottom, 25)
                    }
                    linkView
                        .padding(.bottom, 10)
                }
                .actionSheet(isPresented: $isOptionSheetPresented) {
                    ActionSheet(title: Text("Options"), buttons: [
                        .default(Text("Share"), action: {
                            shareEvent()
                        }),
                        .default(Text("Add to Calendar"), action: {
                            requestAccessAndAddEvent()
                        }),
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingShareSheet) {
                    ShareSheet(items: sharedItems)
                }
            }
        }
    }
    
    var moreView: some View {
        HStack() {
            Spacer()
            Button {
                isOptionSheetPresented = true
            } label: {
                Label("", systemImage: "ellipsis.circle")
            }
            .foregroundColor(Color(.orange))
        }
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Text(event.name.uppercased())
                .font(.custom("ExoRoman-Bold", size: 36))
                .foregroundColor(Color(.mantis))
        }
    }
    
    var priceView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("PRICE")
                .font(.custom("ExoRoman-Black", size: 24))
                .foregroundColor(Color(.mantis))
            HorizontalDivider()
            if event.price == "Free" {
                Text("Free")
                    .font(.custom("ExoRoman-Regular", size: 16))
            } else {
                Text(event.price ?? "")
                    .font(.custom("ExoRoman-Regular", size: 16))
            }
        }
        .foregroundColor(Color(.mantis))
    }
    
    var dateView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("TIME")
                .font(.custom("ExoRoman-Black", size: 24))
                .foregroundColor(Color(.mantis))
            HorizontalDivider()
            Text(event.formattedDate)
                .font(.custom("ExoRoman-Regular", size: 16))
            Text("\(event.formattedTimes.0) - \(event.formattedTimes.1)")
                .font(.custom("ExoRoman-Regular", size: 16))
        }
        .foregroundColor(Color(.mantis))
    }
    
    var locationView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("LOCATION")
                .font(.custom("ExoRoman-Black", size: 24))
                .foregroundColor(Color(.mantis))
            HorizontalDivider()
            Text(event.location)
                .font(.custom("ExoRoman-Regular", size: 16))
            Link(event.address, destination: URL(string: "http://maps.apple.com/?address=\(event.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
                .font(.custom("ExoRoman-Bold", size: 16))
                .foregroundColor(CustomColors.orange)
            Text(event.neighborhood)
                .font(.custom("ExoRoman-Regular", size: 16))
        }
        .foregroundColor(Color(.mantis))
    }
    
    var imageView: some View {
        AsyncImage(
            url: URL(string: event.image ?? ""),
            content: { image in
                image.resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(maxWidth: 500, maxHeight: 500)
                     .cornerRadius(3)
                     .shadow(color: .gray, radius: 2, x: 2, y: 2)
            },
            placeholder: {
                ProgressView()
            }
        )
    }
    
    var descriptionView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ABOUT")
                .font(.custom("ExoRoman-Black", size: 24))
                .foregroundColor(Color(.mantis))
            HorizontalDivider()
            
            Text(event.processedDescription)
                .font(.custom("ExoRoman-Regular", size: 16))
        }
        .foregroundColor(Color(.mantis))
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var linkView: some View {
        Link("WEBSITE", destination: URL(string: event.website ?? "")!)
            .font(.custom("ExoRoman-Black", size: 30))
            .foregroundColor(CustomColors.orange)
    }
    
    func requestAccessAndAddEvent() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                DispatchQueue.main.async {
                    addEventToCalendar(event: event)
                }
            } else {
                // Handle the error or the case where permission is denied
                // You might want to show an alert to the user
            }
        }
    }
    
    func addEventToCalendar(event: Event) {
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.title = event.name
        ekEvent.startDate = event.eventStart
        ekEvent.endDate = event.eventEnd
        ekEvent.location = event.location
        ekEvent.notes = event.processedDescription
        ekEvent.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(ekEvent, span: .thisEvent)
        } catch let error as NSError {
            print("Can't send to iCal: \(error)")
        }
    }
    
    func shareEvent() {
    }
}

struct EventView_Previews: PreviewProvider {
    @State static var event = Event(name: "Art Fair", date: "8/25/23", location: "Detroit Institute of Arts", locationNarrowed: "DIA", address: "123 Woodward Ave", neighborhood: "Midtown", category: "Art", website: "www.google.com", image: nil, description: "It's gonna be a blast! Come on by", price: "5", timeStart: 700, timeEnd: 1100, rating: 5, type: "Concert", priceInt: 0)
    
    static var previews: some View {
        EventView(event: event)
    }
}

extension String {
    var paragraphs: [String] {
        return self.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }
}
