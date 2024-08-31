//
//  NearbyEventsView.swift
//  DetroitApp
//
//  Created by Blair Myers on 6/13/24.
//

import SwiftUI
import CoreLocation

struct NearbyEventsView: View {
    @EnvironmentObject var viewModel: EventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(.limeGreen)
                .edgesIgnoringSafeArea(.all)
            
            if let userNeighborhood = viewModel.userNeighborhood {
                let nearbyEvents = viewModel.events.filter { event in
                    event.neighborhood == userNeighborhood && event.isHappeningToday
                }
                
                VStack {
                    Text("Upcoming events happening today near you")
                        .font(.custom("ExoRoman-Regular", size: 24))
                        .foregroundColor(Color(.mantis))
                        .padding(.top, 20)
                    
                    GeometryReader { geometry in
                        Divider()
                            .frame(width: geometry.size.width * 4/5, height: 4)
                            .background(Color(.mantis))
                    }
                    .frame(height: 4)
                    
                    if nearbyEvents.isEmpty {
                        Text("No events today in \(userNeighborhood)")
                            .font(.custom("ExoRoman-Regular", size: 20))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    } else {
                        List {
                            ForEach(nearbyEvents.indices, id: \.self) { index in
                                NavigationLink(destination: EventView(events: nearbyEvents, currentIndex: index)) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(nearbyEvents[index].name)
                                            .font(.custom("ExoRoman-Bold", size: 24))
                                        Text("      \(nearbyEvents[index].type ?? "")")
                                            .font(.custom("ExoRoman-Regular", size: 16))
                                        Text(Image(systemName: "location.circle")) + Text(" \(nearbyEvents[index].location)")
                                            .font(.custom("ExoRoman-Regular", size: 14))
                                    }
                                    .foregroundStyle(Color(.mantis))
                                }
                            }
                            .listRowBackground(Color(.offWhite))
                            .listRowSeparatorTint(colorScheme == .light ? CustomColors.offWhiteDark : CustomColors.offWhite)
                        }
                        .scrollContentBackground(.hidden)
                        .listRowBackground(Color(.limeGreen))
                    }
                }
            } else {
                Text("Fetching location...")
                    .foregroundColor(.white)
                    .font(.custom("ExoRoman-Regular", size: 20))
                    .padding()
            }
        }
    }
}

extension Event {
    var isHappeningToday: Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        
        if let start = eventStart, let end = eventEnd {
            
            return calendar.isDate(start, inSameDayAs: currentDate) &&
            currentDate <= end
        } else {
            return false
        }
    }
}

