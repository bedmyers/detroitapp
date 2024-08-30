//
//  EventView.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI
import EventKit

struct EventView: View {
    // MARK: - Properties
    let events: [Event]
    
    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - State
    @State private var currentIndex: Int
    @State private var showingShareSheet = false
    @State private var isOptionSheetPresented = false
    @State private var showingReminderOptions = false
    @State private var eventStore = EKEventStore()
    @State private var shareSheetItems: [Any] = []
    
    // MARK: - Private Properties
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    // MARK: - Initialization
    init(events: [Event], currentIndex: Int) {
        self.events = events
        _currentIndex = State(initialValue: currentIndex)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color(.offWhite).ignoresSafeArea()
            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    headerView
                    contentView
                }
                .actionSheet(isPresented: $isOptionSheetPresented) { optionActionSheet }
                .sheet(isPresented: $showingShareSheet) { ShareSheet(items: shareSheetItems) }
            }
            .gesture(swipeGesture)
        }
    }
     
    // MARK: - View Components
    var headerView: some View {
        VStack(spacing: 10) {
            HStack {
                Text(dateString)
                    .font(.custom("ExoRoman-Bold", size: 20))
                    .foregroundColor(Color(CustomColors.orange))
                Spacer()
                moreButton
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                Divider()
                    .frame(width: geometry.size.width * 4/5, height: 4)
                    .background(Color(CustomColors.orange))
            }
            .frame(height: 4)
            
            scrollDotView
                .padding(.horizontal)
        }
        .padding(.top)
    }
     
     var contentView: some View {
         VStack {
             titleView
             imageView
             dateView
             locationView
             priceView
             if events[currentIndex].processedDescription != "" {
                 descriptionView
             }
             if events[currentIndex].website?.count ?? 6 > 5 {
                 linkView
             }
         }
     }
     
    var moreButton: some View {
        Button(action: { isOptionSheetPresented = true }) {
            Image(systemName: "slider.horizontal.3")
                .imageScale(.large)
                .foregroundColor(CustomColors.orange)
        }
    }
    
    var scrollDotView: some View {
        HStack(spacing: 8) {
            ForEach(0..<events.count, id: \.self) { index in
                if index == currentIndex {
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color(.mantis))
                        .font(.system(size: 8))
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(Color(.mantis))
                        .font(.system(size: 8))
                }
            }
        }
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Text(events[currentIndex].name.uppercased())
                .font(.custom("ExoRoman-Bold", size: 36))
                .foregroundColor(Color(.mantis))
        }
        .frame(alignment: .leading)
        .padding(.leading, 10)
        .padding(.trailing, 25)
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
        .padding(.horizontal, 25)
    }
    
    var dateView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("TIME")
                .font(.custom("ExoRoman-Black", size: 24))
            HorizontalDivider()
            Text(events[currentIndex].formattedDate)
                .font(.custom("ExoRoman-Regular", size: 16))
            Text("\(events[currentIndex].formattedTimes.0) - \(events[currentIndex].formattedTimes.1)")
                .font(.custom("ExoRoman-Regular", size: 16))
        }
        .foregroundColor(Color(.mantis))
        .padding(10)
        .padding(.horizontal, 25)
    }
    
    var locationView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("LOCATION")
                .font(.custom("ExoRoman-Black", size: 24))
            HorizontalDivider()
            Text(events[currentIndex].location)
                .font(.custom("ExoRoman-Regular", size: 16))
            Link(events[currentIndex].address, destination: mapsURL)
                .font(.custom("ExoRoman-Bold", size: 16))
                .foregroundColor(CustomColors.orange)
            Text(events[currentIndex].neighborhood)
                .font(.custom("ExoRoman-Regular", size: 16))
        }
        .foregroundColor(Color(.mantis))
        .padding(10)
        .padding(.horizontal, 25)
    }
    
    var priceView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("PRICE")
                .font(.custom("ExoRoman-Black", size: 24))
            HorizontalDivider()
            Text(events[currentIndex].price == "Free" ? "Free" : (events[currentIndex].price ?? ""))
                .font(.custom("ExoRoman-Regular", size: 16))
        }
        .foregroundColor(Color(.mantis))
        .padding(10)
        .padding(.horizontal, 25)
    }
    
    var descriptionView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ABOUT")
                .font(.custom("ExoRoman-Black", size: 24))
            HorizontalDivider()
            Text(events[currentIndex].processedDescription)
                .font(.custom("ExoRoman-Regular", size: 16))
        }
        .foregroundColor(Color(.mantis))
        .fixedSize(horizontal: false, vertical: true)
        .padding(10)
        .padding(.horizontal, 25)
        .padding(.bottom, 25)
    }
    
    var linkView: some View {
        Link("LINK", destination: URL(string: events[currentIndex].website ?? "")!)
            .font(.custom("ExoRoman-Black", size: 30))
            .foregroundColor(CustomColors.orange)
            .padding(.bottom, 10)
    }
    
    // MARK: - Computed Properties
    private var mapsURL: URL {
        URL(string: "http://maps.apple.com/?address=\(events[currentIndex].address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
    }
    
    private var optionActionSheet: ActionSheet {
        ActionSheet(title: Text("Options"), buttons: [
            .default(Text("Share"), action: shareEvent),
            .default(Text("Add to Calendar"), action: requestAccessAndAddEvent),
            .default(Text("Remind Me 1 Hour Before"), action: { scheduleReminder(hoursBefore: 1) }),
            .default(Text("Remind Me 24 Hours Before"), action: { scheduleReminder(hoursBefore: 24) }),
            .cancel()
        ])
    }
    
    private var swipeGesture: some Gesture {
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
    }
    
    private var dateString: String {
        guard let date = events[currentIndex].eventStart else { return "" }
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Methods
    private func requestAccessAndAddEvent() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                DispatchQueue.main.async {
                    addEventToCalendar(event: events[currentIndex])
                }
            } else {
                // Handle error or access denied
            }
        }
    }
    
    private func addEventToCalendar(event: Event) {
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
    
    private func shareEvent() {
        let eventId = events[currentIndex].id
        if let url = URL(string: "offwoodward://event/\(eventId)") {
            self.showingShareSheet = true
            shareSheetItems = [url]
        } else {
            print("Failed to create URL for sharing")
        }
    }
    
    private func scheduleReminder(hoursBefore: Int) {
        let content = UNMutableNotificationContent()
        let time = hoursBefore == 1 ? "hour" : "hours"
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

// MARK: - Preview
struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(events: sampleEvents, currentIndex: 0)
    }
    
    static var sampleEvents: [Event] = [
        Event(name: "Art Fair", date: "8/25/23", location: "Detroit Institute of Arts", locationNarrowed: "DIA", address: "123 Woodward Ave", neighborhood: "Midtown", category: "Art", website: "www.google.com", image: nil, description: "It's gonna be a blast! Come on by", price: "5", timeStart: 700, timeEnd: 1100, rating: 5, type: "Concert", priceInt: 0),
        Event(name: "Music Concert", date: "8/26/23", location: "Fox Theatre", locationNarrowed: "Fox", address: "2310 Woodward Ave", neighborhood: "Downtown", category: "Music", website: "www.example.com", image: nil, description: "Join us for a night of music!", price: "10", timeStart: 800, timeEnd: 1200, rating: 4, type: "Concert", priceInt: 0)
    ]
}
