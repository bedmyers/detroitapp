//
//  ContentView.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/30/23.
//

import SwiftUI

struct ContentView: View {
    
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var event1 = Event(name: "Van Gogh in America", date: "Fri. 2 Jun - Sat. 3 Jun\n5:00 - 11:00PM", locationShortName: "DIA", location: "Detroit Institute of Arts\n5200 Woodward Ave\nDetroit, MI, 48202", website: "https://dia.org/events/exhibitions/van-gogh-america", image: Image("VanGogh"), description: "See Van Gogh in Detroit with the exhibition Van Gogh in America, which celebrates the Detroit Institute of Art’s status as the first public museum in the United States to purchase a painting by Vincent van Gogh, his Self-Portrait (1887). On the 100th anniversary of its acquisition, experience 74 authentic Van Gogh works from around the world and discover the fascinating story of America’s introduction to this iconic artist, in an exhibition only at the DIA.\n\nA full-length, illustrated catalogue with essays by the exhibition curator and Van Gogh scholars will accompany the exhibition. The Detroit Institute of Arts is the exclusive venue for this exhibition.\n\nThe exhibition will explore the considerable efforts made by early promoters of modernism in the United States—including dealers, collectors, private art organizations, public institutions, and the artist’s family—to introduce the artist, his biography, and his artistic production into the American consciousness.")
    var event2 = Event(name: "Detroit Tigers vs. Chicago Cubs", date: "7:00 PM", locationShortName: "Comerica Park", location: "Comerica Park", description: "Let's go Tigers!")
    var event3 = Event(name: "Fisher", date: "11 - 4 AM", locationShortName: "Spotlite", location: "Spotlite", description: "Come have fun")
    
    @State private var selectedDayIndex = 0
    @State private var categorieIndex = 0
    @State private var isFilterSheetPresented = false
    @State private var isFilterLocationSheetPresented = false
    @State private var isPopoverPresented = false
    @State private var selectedOption = "Detroit"
    @GestureState private var translation: CGFloat = 0
    let dropdownOptions = ["Downtown", "Midtown", "Corktown", "Eastern Market", "Northend", "Southwest", "University District"]
    
    var body: some View {
        let events = [event1, event2, event3]
        
        NavigationView {
            VStack {
                scrollView
                    .padding(10)
                List {
                    ForEach(events.indices, id: \.self) { index in
                        NavigationLink {
                            EventView(event: events[index])
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(events[index].name)
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                
                                Text(events[index].date)
                                // location.circle
                                Text(Image(systemName: "location.circle")) + Text(" \(events[index].locationShortName)")
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: CustomNavigationBar(title: $selectedOption, isPopoverPresented: $isPopoverPresented))
            .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
                List {
                    ForEach(dropdownOptions, id: \.self) { option in
                        Button(action: {
                            self.selectedOption = option
                            self.isPopoverPresented = false
                        }) {
                            Text(option)
                        }
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
                    Text("\(Image(systemName: "arrowtriangle.left.fill")) \(getDayName(after: selectedDayIndex)) \(Image(systemName: "arrowtriangle.right.fill"))") // + Text(Image(systemName: "arrowtriangle.right.fill"))
                        .foregroundColor(.gray)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .animation(nil)
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
            HStack(spacing: 20) {
                let categories = ["Music", "Shows", "Sports", "Food", "Art", "Festivals"]
                ForEach(0..<6) { index in
                    Button {
                        categorieIndex = index
                        // reloadData
                    } label: {
                        
                        Text(categories[index])
                            .font(.headline)
                            .padding()
                            .background(categorieIndex == index ? Color.orange : Color.gray)
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
