//
//  ContentView.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI

struct ContentView: View {
    
    enum SortingCriteria: String, CaseIterable {
        case price = "Price"
        case timeStart = "Start Time"
        case rating = "None"
    }
    
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = EventViewModel()
    @State private var eventData: [Event]?
    @State private var selectedDayIndex = 0
    @State private var isFilterSheetPresented = false
    @State private var isFilterLocationSheetPresented = false
    @State private var isPopoverPresented = false
    @State private var selectedOption = "Detroit"
    @State private var selectedCategory = "All"
    @State private var sortingCriteria: SortingCriteria = .rating
    @State private var animateCategoryChange = false
    @GestureState private var translation: CGFloat = 0
    let dropdownOptions = ["Detroit", "Downtown", "Midtown", "Corktown", "Eastern Market", "New Center", "Southwest", "University District", "Greektown", "Rivertown Warehouse", "East Detroit"]
    
    var body: some View {
        let events = viewModel.events
        
        var sortedEvents: [Event] {
            let filteredEvents = events.filter { event in
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
        
        NavigationView {
            VStack(spacing: 7) {
                headerView
                
                List {
                    ForEach(sortedEvents, id: \.self) { event in
                         NavigationLink {
                             EventView(event: event)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(event.name)
                                    .font(.custom("ExoRoman-Bold", size: 24))
                                Text("      \(event.type ?? "")")
                                    .font(.custom("ExoRoman-Regular", size: 16))
                                Text(Image(systemName: "location.circle")) + Text( " \(event.location)")
                                    .font(.custom("ExoRoman-Regular", size: 14))
                            }
                            .foregroundStyle(Color(.mantis))
                        }
                    }
                    .listRowBackground(Color(.offWhite))
                    .listRowSeparatorTint(colorScheme == .light ? CustomColors.offWhiteDark : CustomColors.offWhite)
                }
                .id(animateCategoryChange ? UUID() : nil)
            }
            .background(Color(.limeGreen))
            .scrollContentBackground(.hidden)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: navigationTitleButton)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isFilterSheetPresented = true
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .tint(CustomColors.orange)
                }
            }
            .actionSheet(isPresented: $isFilterSheetPresented) {
                ActionSheet(title: Text("Filter Options"), buttons: [
                    .default(Text("Sort by Time"), action: {
                        sortingCriteria = .timeStart
                    }),
                    .default(Text("Sort by Price"), action: {
                        sortingCriteria = .price
                    }),
                    .default(Text("Sort by Rating"), action: {
                        sortingCriteria = .rating
                    }),
                    .cancel()
                ])
            }
            .onAppear {
                if !viewModel.eventsLoaded {
                    viewModel.listentoRealtimeDatabase()
                }
            }
            .onDisappear {
                viewModel.stopListening()
            }
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = UIScreen.main.bounds.width / 6
                        withAnimation {
                            if value.translation.width < -threshold {
                                // Swiped left
                                selectedDayIndex = (selectedDayIndex + 1) % days.count
                            } else if value.translation.width > threshold {
                                // Swiped right
                                selectedDayIndex = (selectedDayIndex + days.count - 1) % days.count
                            }
                        }
                    }
            )
            .transition(.slide) // Apply slide transition
        }
    }
    
    var titleDateView: some View {
        HStack {
            Text(getDateString(after: selectedDayIndex))
                .font(.custom("ExoRoman-Bold", size: 24))
        }
        .foregroundColor(Color(.mantis))
    }
    
    var scrollDotView: some View {
        HStack(spacing: 8) { // Add spacing between dots if needed
            ForEach(0..<7) { index in
                if index == selectedDayIndex {
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color(.mantis))
                        .font(.system(size: 8)) // Adjust the size as per your preference
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(Color(.mantis))
                        .font(.system(size: 8)) // Adjust the size as per your preference
                }
            }
        }
    }
    
    var headerView: some View {
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
            scrollDotView
        }
        .background(Color(.limeGreen))
    }
    
    var scrollView: some View {
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
                                Image(systemName: iconsDict[categories[index]] ?? "hello")
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
    
    var navigationTitleButton: some View {
        Menu {
            GeometryReader { geometry in
                ZStack {
                    Color(.offWhite)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("Select a Neighborhood")
                            .font(.custom("ExoRoman-Bold", size: geometry.size.width * 0.08))
                            .foregroundStyle(Color.red)
                            .padding(.top, geometry.size.height * 0.02) // Dynamic padding
                            .padding(.horizontal)

                        Divider() // Divider under the title

                        ForEach(dropdownOptions, id: \.self) { option in
                            if option != selectedOption {
                                Button(action: {
                                    self.selectedOption = option
                                    self.isPopoverPresented = false
                                }) {
                                    Text(option)
                                        .font(.custom("ExoRoman-Regular", size: geometry.size.width * 0.06))
                                        .accentColor(.red)
                                        .foregroundColor(Color(.mantis))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal)
                                        .cornerRadius(5)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .background(selectedOption == option ? Color(.limeGreen) : Color.clear)
                                .padding(.horizontal, geometry.size.width * 0.04) // Dynamic padding
                                .padding(.bottom, 8)
                                if option != dropdownOptions.last {
                                    //Divider()
                                      //  .foregroundColor(Color(.limeGreen))
                                }
                            }
                        }
                    }
                    .background(Color.red)
                    .padding(.horizontal)
                }
            }
        } label: {
            HStack {
                Text(selectedOption)
                    .font(.custom("ExoRoman-Bold", size: 36))
                    .foregroundColor(Color(.mantis))
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(.mantis))
            }
        }
        .foregroundColor(Color(.mantis))
    }
    
    func getDayName(after days: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let nextDay = calendar.date(byAdding: .day, value: days, to: today)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: nextDay)
    }
    
    private func updateNavigationTitle(_ option: String) {
        print("Hello")
    }
    
    func getDayDate(after days: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        guard let date = Calendar.current.date(byAdding: .day, value: days, to: Date()) else {
            return ""
        }
        
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
        
    }
    
    func getDateString(after days: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let nextDay = calendar.date(byAdding: .day, value: days, to: today)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: nextDay)
    }
    
    func modeColor() -> Color {
        return colorScheme == .dark ? .white : .black
    }
    
    /*func mapsURL(for address: String) -> URL {
        let formattedAddress = address + ", Detroit, MI"
         let encodedAddress = formattedAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
         return URL(string: "http://maps.apple.com/?address=\(encodedAddress)")!
     }*/
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
