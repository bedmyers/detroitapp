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
        HStack(spacing: 4) {
            // Calculate the start and end index for the visible dots
            let maxDots = 7
            let halfMaxDots = maxDots / 2
            let start = max(currentIndex - halfMaxDots, 0)
            let end = min(start + maxDots - 1, events.count - 1)

            let adjustedStart = max(min(start, events.count - maxDots), 0)
            let adjustedEnd = min(adjustedStart + maxDots - 1, events.count - 1)
            
            ForEach(adjustedStart...adjustedEnd, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color(.mantis) : Color.gray.opacity(0.3))
                    .scaleEffect(index == adjustedStart || index == adjustedEnd ? 0.5 : index == currentIndex ? 1.2 : 1.0)
                    .frame(width: index == currentIndex ? 10 : 4, height: index == currentIndex ? 10 : 4)
                    .animation(.spring(), value: currentIndex)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    
    private var visibleIndices: [Int] {
        let start = max(0, currentIndex - 2)
        let end = min(events.count - 1, currentIndex + 2)
        return Array(start...end)
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
                     //.shadow(color: .gray, radius: 2, x: 2, y: 2)
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
        Link(destination: URL(string: events[currentIndex].website ?? "")!) {
            Text("LINK")
                .font(.custom("ExoRoman-Black", size: 24))
                .foregroundColor(.white)
                .padding()
                .background(CustomColors.orange)
                .cornerRadius(10)
        }
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
                let threshold: CGFloat = 30
                if value.translation.width < -threshold {
                    withAnimation {
                        if currentIndex < events.count - 1 {
                            currentIndex += 1
                        }
                    }
                } else if value.translation.width > threshold {
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
        let eventName = events[currentIndex].name
        
        let shareText = "Check out this event! \(eventName)"
        
        var itemsToShare: [Any] = [shareText]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let screenshot = self.captureScreenshot() {
                print("Screenshot captured successfully. Size: \(screenshot.size)")
                itemsToShare.append(screenshot)
            } else {
                print("Failed to capture screenshot")
            }
        }
        
        if let url = URL(string: "offwoodward://event/\(eventId)") {
            itemsToShare.append(url)
        }
        
        print("Items to share: \(itemsToShare.count)")
        for (index, item) in itemsToShare.enumerated() {
            print("Item \(index): \(type(of: item))")
        }
        
        shareSheetItems = itemsToShare
        self.showingShareSheet = true
    }

    private func captureScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: UIScreen.main.bounds)
        return renderer.image { ctx in
            UIApplication.shared.windows.first?.rootViewController?.view.drawHierarchy(in: UIScreen.main.bounds, afterScreenUpdates: true)
        }
    }
    
    private func addTextToImage(_ image: UIImage, text: String) -> UIImage? {
            let imageSize = image.size
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
            
            guard let context = UIGraphicsGetCurrentContext() else {
                print("Failed to create graphics context")
                return nil
            }
            
            image.draw(in: CGRect(origin: .zero, size: imageSize))
            
            let rect = CGRect(origin: .zero, size: imageSize)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white,
                .backgroundColor: UIColor.black.withAlphaComponent(0.5)
            ]
            
            let textRect = CGRect(x: 20, y: 20, width: imageSize.width - 40, height: 100)
            text.draw(in: textRect, withAttributes: attributes)
            
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
                print("Failed to get image from graphics context")
                UIGraphicsEndImageContext()
                return nil
            }
            
            UIGraphicsEndImageContext()
            
            print("Text added to image. New image size: \(newImage.size)")
            return newImage
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
