//
//  ReminderOptionsView.swift
//  DetroitApp
//
//  Created by Blair Myers on 3/24/24.
//

import SwiftUI

struct ReminderOptionsView: View {
    var scheduleReminder: (Int) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose when you'd like to be reminded about the event.")
                .font(.headline)
            
            Button("1 Day Before") {
                scheduleReminder(24)
            }

            Button("3 Hours Before") {
                scheduleReminder(3)
            }

            Button("1 Hour Before") {
                scheduleReminder(1)
            }
        }
        .padding()
    }
}
