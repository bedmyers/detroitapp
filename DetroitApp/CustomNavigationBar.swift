//
//  CustomNavigationBar.swift
//  DetroitApp
//
//  Created by Blair Myers on 6/21/23.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var title: String
    @Binding var isPopoverPresented: Bool
    
    var body: some View {
        Button(action: {
            self.isPopoverPresented = true
        }) {
            HStack {
                Text(title)
                    .font(.custom("ExoRoman-Bold", size: 36))
                    .foregroundColor(Color(.mantis))
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(.mantis))
            }
        }
        .foregroundColor(colorScheme == .dark ? .white : .black)
    }
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationBar(title: .constant("Detroit"), isPopoverPresented: .constant(false))
    }
}
