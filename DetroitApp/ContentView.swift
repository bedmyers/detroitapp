//
//  ContentView.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI

struct ContentView: View {
    
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
    @GestureState private var translation: CGFloat = 0
    let dropdownOptions = ["Detroit", "Downtown", "Midtown", "Corktown", "Eastern Market", "Northend", "Southwest", "University District"]
    
    var body: some View {
        let events = viewModel.events
        
        NavigationView {
            VStack {
                scrollView
                    .padding(10)
                List {
                    ForEach(events.filter { event in
                        let matchesCategory = selectedCategory == "All" || event.category == selectedCategory
                        let matchesLocation = selectedOption == "Detroit" ||
                                             (selectedOption != "Detroit" && event.neighborhood == selectedOption)

                        return event.dayOfWeek == getDayName(after: selectedDayIndex) &&
                               event.date == getDayDate(after: selectedDayIndex) &&
                               matchesCategory &&
                               matchesLocation
                    }, id: \.self) { event in
                        NavigationLink {
                            EventView(event: event)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(event.name)
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                Text(Image(systemName: "location.circle")) + Text( " \(event.location)")
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: CustomNavigationBar(title: $selectedOption, isPopoverPresented: $isPopoverPresented))
            .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
                ZStack {
                    Color(UIColor.systemBackground)
                        .ignoresSafeArea()
                    
                    VStack {
                        ForEach(dropdownOptions, id: \.self) { option in
                            if option != selectedOption {
                                Button(action: {
                                    self.selectedOption = option
                                    self.isPopoverPresented = false
                                }) {
                                    Text(option)
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 24)
                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.accentColor))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .toolbar {
                /*ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isFilterSheetPresented = true
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }*/
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 20) {
                        Button(action: {
                            selectedDayIndex = (selectedDayIndex - 1) % days.count
                        }) {
                            Image(systemName: "arrowtriangle.left.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                        }
                        
                        Text("\(getDayName(after: selectedDayIndex))")
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .animation(nil)
                        
                        Button(action: {
                            selectedDayIndex = (selectedDayIndex + 1) % days.count
                        }) {
                            Image(systemName: "arrowtriangle.right.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                        }
                    }
                }
            }
            .actionSheet(isPresented: $isFilterSheetPresented) {
                ActionSheet(title: Text("Filter Options"), buttons: [
                    .default(Text("Location"), action: {
                        isFilterLocationSheetPresented = true
                    }),
                    .default(Text("Cost")),
                    .cancel()])
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
                        let threshold = UIScreen.main.bounds.width / 2
                        if value.translation.width < -threshold {
                            // Swiped left
                            selectedDayIndex = (selectedDayIndex + 1) % days.count
                        } else if value.translation.width > threshold {
                            // Swiped right
                            selectedDayIndex = (selectedDayIndex + days.count - 1) % days.count
                        }
                    }
            )
        }
    }
    
    var scrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                let categories = ["All", "Music", "Shows", "Sports", "Food", "Art", "Festivals"]
                ForEach(0..<7) { index in
                    Button {
                        selectedCategory = categories[index]
                    } label: {
                        ZStack {
                            if selectedCategory == categories[index] {
                                Color.purple
                                    .cornerRadius(10)
                            } else {
                                Color.white
                                    .cornerRadius(10)
                            }
                            Image(categories[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .frame(width: 45, height: 45)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(modeColor(), lineWidth: 5))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                    }
                }
            }
        }
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
        dateFormatter.dateFormat = "M/dd/yy"
        
        guard let date = Calendar.current.date(byAdding: .day, value: days, to: Date()) else {
            return ""
        }
        
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
        
    }
    
    func modeColor() -> Color {
        return colorScheme == .dark ? .white : .black
    }
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
