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
    @State private var showingReminderOptions = false
    @State private var eventStore = EKEventStore()
    @State private var shareSheetItems: [Any] = []
    
    let events: [Event]
    @State private var currentIndex: Int
    
    init(events: [Event], currentIndex: Int) {
        self.events = events
        _currentIndex = State(initialValue: currentIndex)
    }
    
    var body: some View {
        ZStack {
            Color(.offWhite)
                .ignoresSafeArea()
            ScrollView(.vertical) {
                VStack {
                    moreView
                        .tint(CustomColors.orange)
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
                    if events[currentIndex].processedDescription != "" {
                        descriptionView
                            .padding(10)
                            .padding(.leading, 25)
                            .padding(.trailing, 25)
                            .padding(.bottom, 25)
                    }
                    if events[currentIndex].website?.count ?? 6 > 5 {
                        linkView
                            .padding(.bottom, 10)
                    }
                }
                .actionSheet(isPresented: $isOptionSheetPresented) {
                    ActionSheet(title: Text("Options"), buttons: [
                        .default(Text("Share"), action: shareEvent),
                        .default(Text("Add to Calendar"), action: requestAccessAndAddEvent),
                        .default(Text("Remind Me 1 Hour Before"), action: { scheduleReminder(hoursBefore: 1) }),
                        .default(Text("Remind Me 24 Hours Before"), action: { scheduleReminder(hoursBefore: 24) }),
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingShareSheet) {
                    ShareSheet(items: shareSheetItems)
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width < -threshold {
                            // Swipe left
                            withAnimation {
                                if currentIndex < events.count - 1 {
                                    currentIndex += 1
                                }
                            }
                        } else if value.translation.width > threshold {
                            // Swipe right
                            withAnimation {
                                if currentIndex > 0 {
                                    currentIndex -= 1
                                }
                            }
                        }
                    }
            )
        }
    }
    
    var moreView: some View {
        HStack() {
            Spacer()
            Button {
                isOptionSheetPresented = true
            } label: {
                Label("", systemImage: "ellipsis.circle")
                    .imageScale(.large)
            }
            .tint(CustomColors.orange)
        }
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Text(events[currentIndex].name.uppercased())
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
            if events[currentIndex].price == "Free" {
                Text("Free")
                    .font(.custom("ExoRoman-Regular", size: 16))
            } else {
                Text(events[currentIndex].price ?? "")
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
            Text(events[currentIndex].formattedDate)
                .font(.custom("ExoRoman-Regular", size: 16))
            Text("\(events[currentIndex].formattedTimes.0) - \(events[currentIndex].formattedTimes.1)")
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
            Text(events[currentIndex].location)
                .font(.custom("ExoRoman-Regular", size: 16))
            Link(events[currentIndex].address, destination: URL(string: "http://maps.apple.com/?address=\(events[currentIndex].address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
                .font(.custom("ExoRoman-Bold", size: 16))
                .foregroundColor(CustomColors.orange)
            Text(events[currentIndex].neighborhood)
                .font(.custom("ExoRoman-Regular", size: 16))
        }
        .foregroundColor(Color(.mantis))
    }
    
    var imageView: some View {
        AsyncImage(
            url: URL(string: events[currentIndex].image ?? ""),
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
            
            Text(events[currentIndex].processedDescription)
                .font(.custom("ExoRoman-Regular", size: 16))
        }
        .foregroundColor(Color(.mantis))
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var linkView: some View {
        Link("WEBSITE", destination: URL(string: events[currentIndex].website ?? "")!)
            .font(.custom("ExoRoman-Black", size: 30))
            .foregroundColor(CustomColors.orange)
    }
    
    func requestAccessAndAddEvent() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                DispatchQueue.main.async {
                    addEventToCalendar(event: events[currentIndex])
                }
            } else {
                
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
        let eventId = events[currentIndex].id
        if let url = URL(string: "offwoodward://event/\(eventId)") {
            self.showingShareSheet = true
            shareSheetItems = [url]
        } else {
            print("Failed to create URL for sharing")
        }
    }
    
    func scheduleReminder(hoursBefore: Int) {
        let content = UNMutableNotificationContent()
        var time = "hours"
        if hoursBefore == 1 {
            time = "hour"
        }
        content.title = "Event Reminder"
        content.body = "\(events[currentIndex].name) is starting in \(hoursBefore) \(time)."
        content.sound = UNNotificationSound.default

        if let eventStart = events[currentIndex].eventStart {
            let triggerDate = Calendar.current.date(byAdding: .hour, value: -hoursBefore, to: eventStart)!
            let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling reminder: \(error)")
                }
            }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    @State static var events = [
        Event(name: "Art Fair", date: "8/25/23", location: "Detroit Institute of Arts", locationNarrowed: "DIA", address: "123 Woodward Ave", neighborhood: "Midtown", category: "Art", website: "www.google.com", image: nil, description: "It's gonna be a blast! Come on by", price: "5", timeStart: 700, timeEnd: 1100, rating: 5, type: "Concert", priceInt: 0),
        Event(name: "Music Concert", date: "8/26/23", location: "Fox Theatre", locationNarrowed: "Fox", address: "2310 Woodward Ave", neighborhood: "Downtown", category: "Music", website: "www.example.com", image: nil, description: "Join us for a night of music!", price: "10", timeStart: 800, timeEnd: 1200, rating: 4, type: "Concert", priceInt: 0)
    ]
    
    static var previews: some View {
        EventView(events: events, currentIndex: 0)
    }
}

