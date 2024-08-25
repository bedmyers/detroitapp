//
//  VenueEventsView.swift
//  DetroitApp
//
//  Created by Blair Myers on 6/8/24.
//

import SwiftUI

struct VenueEventsView: View {
    var venueName: String
    @EnvironmentObject var viewModel: EventViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let events = viewModel.events.filter { $0.location == venueName }
        let _ = print("$$$ \(events.count)")
        
        ZStack {
            Color(.limeGreen)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Events happening at \(venueName) this week")
                    .font(.custom("ExoRoman-Bold", size: 24))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Divider()
                    .frame(height: 4)
                    .background(Color(.mantis))
                    .padding(.horizontal, 20)

                if events.isEmpty {
                    Text("Nothing of note is happening here")
                        .font(.custom("ExoRoman-Regular", size: 20))
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(events.indices, id: \.self) { index in
                            NavigationLink(destination: EventView(events: events, currentIndex: index)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(events[index].name)
                                        .font(.custom("ExoRoman-Bold", size: 24))
                                    Text("      \(events[index].type ?? "")")
                                        .font(.custom("ExoRoman-Regular", size: 16))
                                    Text(Image(systemName: "location.circle")) + Text(" \(events[index].location)")
                                        .font(.custom("ExoRoman-Regular", size: 14))
                                }
                                .foregroundStyle(Color(.mantis))
                            }
                        }
                        .listRowBackground(Color(.offWhite))
                        .listRowSeparatorTint(colorScheme == .light ? CustomColors.offWhiteDark : CustomColors.offWhite)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .onAppear {
            print("viewModel.events: \(viewModel.events)")
        }
    }
}
