//
//  ContentView.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Enums
    enum SortingCriteria: String, CaseIterable {
        case price = "Price"
        case timeStart = "Start Time"
        case rating = "None"
    }
    
    // MARK: - Properties
    let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let dropdownOptions = ["Detroit", "Downtown", "Midtown", "Corktown", "Eastern Market", "North End", "Southwest", "East Side", "Hamtramck"]
    let iconsDict = [
        "All": "star.fill",
        "Music": "music.note",
        "Shows": "theatermasks.fill",
        "Sports": "sportscourt.fill",
        "Food": "fork.knife",
        "Art": "paintpalette.fill",
        "Events": "calendar",
        "Museum": "building.columns.fill"
    ]
    
    // MARK: - Environment and StateObjects
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @EnvironmentObject private var viewModel: EventViewModel
    @StateObject private var locationManager = LocationManager.shared
    
    // MARK: - State variables
    @State private var selectedDayIndex = 0
    @State private var isFilterSheetPresented = false
    @State private var isPopoverPresented = false
    @State private var selectedOption = "Detroit"
    @State private var selectedCategory = "All"
    @State private var sortingCriteria: SortingCriteria = .rating
    @State private var animateCategoryChange = false
    @State private var deepLinkEventId: String? = nil
    @State private var shouldNavigateToEvent = false
    @State private var showBuildingRecognitionView = false
    @State private var showNearbyEventsView = false
    @GestureState private var translation: CGFloat = 0
    @State private var titleSize: CGFloat = 36
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 7) {
                deepLinkNavigation
                headerView
                eventList
            }
            .background(Color(.limeGreen))
            .scrollContentBackground(.hidden)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    navigationTitleButton
                }
                toolbarItems
            }
             .actionSheet(isPresented: $isFilterSheetPresented) { filterActionSheet }
             .sheet(isPresented: $showBuildingRecognitionView) { buildingRecognitionSheet }
             .sheet(isPresented: $showNearbyEventsView) { nearbyEventsSheet }
             .onAppear(perform: {
                 viewModel.listentoRealtimeDatabase()
             })
             .onChange(of: deepLinkManager.deepLinkEventId, perform: handleDeepLink)
             .gesture(dragGesture)
             .transition(.slide)
         }
     }
    
    // MARK: - Computed Properties
    private var sortedEvents: [Event] {
        let filteredEvents = viewModel.events.filter { event in
            let matchesCategory = selectedCategory == "All" || event.category == selectedCategory
            let matchesLocation = selectedOption == "Detroit" || (selectedOption != "Detroit" && event.neighborhood == selectedOption)
            
            return event.dayOfWeek == getDayName(after: selectedDayIndex) &&
                   event.fullDate == getDayDate(after: selectedDayIndex) &&
                   matchesCategory &&
                   matchesLocation
        }

        switch sortingCriteria {
        case .price:
            return filteredEvents.sorted { $0.priceInt ?? 0 < $1.priceInt ?? 0 }
        case .timeStart:
            return filteredEvents.sorted { $0.timeStart ?? 0 < $1.timeStart ?? 0 }
        case .rating:
            return filteredEvents.sorted { $0.rating > $1.rating }
        }
    }
    
    private var deepLinkNavigation: some View {
        Group {
            if let index = sortedEvents.firstIndex(where: { $0.id == deepLinkEventId }) {
                NavigationLink(destination: EventView(events: sortedEvents, currentIndex: index), isActive: $shouldNavigateToEvent) {
                    EmptyView()
                }
            } else {
                EmptyView()
            }
        }.hidden()
    }
    
    // MARK: - View Components
    private var headerView: some View {
        VStack {
            scrollView
                .padding(5)
            GeometryReader { geometry in
                Divider()
                    .frame(width: geometry.size.width * 4/5, height: 4)
                    .background(Color(.mantis))
            }
            .frame(height: 4)
            titleDateView
                .padding(.vertical, 4)
            dayButtonsView
        }
        .background(Color(.limeGreen))
    }
    
    private var scrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                let categories = ["All", "Music", "Shows", "Sports", "Food", "Art", "Events", "Museum"]
                ForEach(0..<8) { index in
                    Button {
                        selectedCategory = categories[index]
                    } label: {
                        VStack(spacing: 0) {
                            ZStack {
                                if selectedCategory == categories[index] {
                                    CustomColors.orange
                                        .cornerRadius(10)
                                } else {
                                    Color(.limeGreen)
                                        .cornerRadius(10)
                                }
                                Image(systemName: iconsDict[categories[index]] ?? "star.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(Color(.mantis))
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(10)
                            }
                            .frame(width: 45, height: 45)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.offWhite), lineWidth: 5))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 5)
                            Text(categories[index])
                                .font(.custom("ExoRoman-Regular", size: 12))
                        }
                    }
                }
            }
        }
    }
    
    private var titleDateView: some View {
        HStack {
            Text(getDateString(after: selectedDayIndex))
                .font(.custom("ExoRoman-Bold", size: 24))
        }
        .foregroundColor(Color(.mantis))
    }
    
    private var dayButtonsView: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { index in
                let dayText = index == 0 ? "Today" : getDayAbbreviation(after: index)
                Button(action: {
                    selectedDayIndex = index
                }) {
                    Text(dayText)
                        .font(.custom("ExoRoman-Bold", size: 12))
                        .frame(minWidth: 36)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(selectedDayIndex == index ? CustomColors.orange : Color(.limeGreen))
                        .foregroundColor(selectedDayIndex == index ? Color.white : Color(.mantis))
                        .cornerRadius(6)
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private func getDayAbbreviation(after days: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let nextDay = calendar.date(byAdding: .day, value: days, to: today)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E" // Abbreviation (e.g., Mon, Tue)
        return dateFormatter.string(from: nextDay)
    }
    
    private var navigationTitleButton: some View {
        Menu {
            ForEach(dropdownOptions, id: \.self) { option in
                Button(action: {
                    self.selectedOption = option
                }) {
                    Text(option)
                        .foregroundColor(Color(.mantis))
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedOption)
                    .font(.custom("ExoRoman-Bold", size: 36))
                    .foregroundColor(Color(.mantis))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(.mantis))
                    .font(.system(size: 14))
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, alignment: .leading)
        .padding(.leading, 8)
    }

    
    private var eventList: some View {
        List {
            ForEach(sortedEvents.indices, id: \.self) { index in
                NavigationLink {
                    EventView(events: sortedEvents, currentIndex: index)
                } label: {
                    eventRow(for: sortedEvents[index])
                }
                .listRowBackground(Color(.offWhite))
                .listRowSeparatorTint(colorScheme == .light ? CustomColors.offWhiteDark : CustomColors.offWhite)
            }
        }
        .id(animateCategoryChange ? UUID() : nil)
    }
    
    private func eventRow(for event: Event) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.name)
                .font(.custom("ExoRoman-Bold", size: 24))
            Text("      \(event.type ?? "")")
                .font(.custom("ExoRoman-Regular", size: 14))
            Text(Image(systemName: "location.circle")) + Text(" \(event.locationNarrowed ?? "") @ \(event.formattedTimes.0)")
                .font(.custom("ExoRoman-Regular", size: 14))
        }
        .foregroundStyle(Color(.mantis))
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    Button { showNearbyEventsView = true } label: {
                        Image(systemName: "location.fill")
                    }
                    Button { showBuildingRecognitionView = true } label: {
                        Image(systemName: "camera.fill")
                    }
                    Button { isFilterSheetPresented = true } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    }
                }
                .font(.system(size: 20))
                .foregroundColor(CustomColors.orange)
            }
        }
    }
    
    private var filterActionSheet: ActionSheet {
        ActionSheet(title: Text("Filter Options"), buttons: [
            .default(Text("Sort by Time"), action: { sortingCriteria = .timeStart }),
            .default(Text("Sort by Price"), action: { sortingCriteria = .price }),
            .default(Text("Sort by Rating"), action: { sortingCriteria = .rating }),
            .cancel()
        ])
    }
    
    private var buildingRecognitionSheet: some View {
        NavigationView {
            BuildingRecognitionView()
        }
    }
    
    private var nearbyEventsSheet: some View {
        NavigationView {
            NearbyEventsView()
                .environmentObject(viewModel)
                .environmentObject(locationManager)
        }
    }
    
    // MARK: - Methods
    private func handleDeepLink(_ newEventId: String?) {
        if let eventId = newEventId {
            self.deepLinkEventId = eventId
            self.shouldNavigateToEvent = (findEventById(eventId) != nil)
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($translation) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let threshold = UIScreen.main.bounds.width / 10
                withAnimation {
                    if value.translation.width < -threshold {
                        selectedDayIndex = (selectedDayIndex + 1) % days.count
                    } else if value.translation.width > threshold {
                        selectedDayIndex = (selectedDayIndex + days.count - 1) % days.count
                    }
                }
            }
    }
    
    private func getDayName(after days: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let nextDay = calendar.date(byAdding: .day, value: days, to: today)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: nextDay)
    }
    
    private func getDayDate(after days: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yy"
        
        guard let date = Calendar.current.date(byAdding: .day, value: days, to: Date()) else {
            return ""
        }
        
        return dateFormatter.string(from: date)
    }
    
    private func getDateString(after days: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let nextDay = calendar.date(byAdding: .day, value: days, to: today)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: nextDay)
    }
    
    private func findEventById(_ id: String?) -> Event? {
        guard let id = id else { return nil }
        return viewModel.events.first(where: { $0.id == id })
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(EventViewModel())
            .environmentObject(DeepLinkManager())
    }
}
