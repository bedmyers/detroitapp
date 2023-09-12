//
//  ContentView.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI

struct ContentView: View {
    
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    @StateObject private var viewModel = EventViewModel()
    @State private var eventData: [Event]?
    @State private var selectedDayIndex = 0
    @State private var categoryIndex = 0
    @State private var isFilterSheetPresented = false
    @State private var isFilterLocationSheetPresented = false
    @State private var isPopoverPresented = false
    @State private var selectedOption = "Detroit"
    @GestureState private var translation: CGFloat = 0
    let dropdownOptions = ["Downtown", "Midtown", "Corktown", "Eastern Market", "Northend", "Southwest", "University District"]
    
    var body: some View {
        let events = viewModel.events
        
        NavigationView {
            VStack {
                scrollView
                    .padding(10)
                List {
                    ForEach(events.filter { $0.dayOfWeek == getDayName(after: selectedDayIndex) && $0.date ==  getDayDate(after: selectedDayIndex) }, id: \.self) { event in
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
                VStack {
                    ForEach(dropdownOptions, id: \.self) { option in
                        Button(action: {
                            self.selectedOption = option
                            self.isPopoverPresented = false
                        }) {
                            Text(option)
                                .font(.system(size: 30))
                        }
                        Spacer()
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isFilterSheetPresented = true
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
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
                ForEach(0..<6) { index in
                    Button {
                        categoryIndex = index
                        // reloadData
                    } label: {
                        
                        Text(categories[index])
                            .font(.headline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 25)
                            .background(categoryIndex == index ? Color.orange : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    func getDayName(after days: Int) -> String {
        if days == 0 {
            return "Today"
        }
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
        print("$$$ \(formattedDate)")
        return formattedDate
        
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
