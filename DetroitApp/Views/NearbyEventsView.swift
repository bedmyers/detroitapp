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
            
            if let location = locationManager.location {
                let nearbyEvents = viewModel.events.filter { event in
                    guard let eventLatitude = event.latitude,
                          let eventLongitude = event.longitude,
                          let eventDate = event.eventStart,
                          let eventEndTime = event.eventEnd else { return false }
                    
                    let eventLocation = CLLocation(latitude: eventLatitude, longitude: eventLongitude)
                    let distance = location.distance(from: eventLocation)
                    
                    let calendar = Calendar.current
                    let currentDate = Date()
                    
                    let isWithinDistance = distance <= 3209.34 // 1 mile in meters
                    let isSameDay = calendar.isDate(eventDate, inSameDayAs: currentDate)
                    let isBeforeEndTime = currentDate <= eventEndTime
                    
                    return isWithinDistance && isSameDay && isBeforeEndTime
                }
                
                VStack {
                    Text("Events happening today near you")
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
                        Text("No events today within a 1 mile radius")
                            .font(.custom("ExoRoman-Regular", size: 20))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    } else {
                        List {
                            ForEach(nearbyEvents, id: \.self) { event in
                                NavigationLink(destination: EventView(event: event)) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(event.name)
                                            .font(.custom("ExoRoman-Bold", size: 24))
                                        Text("      \(event.type ?? "")")
                                            .font(.custom("ExoRoman-Regular", size: 16))
                                        Text(Image(systemName: "location.circle")) + Text(" \(event.location)")
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
            }
        }
    }
}
