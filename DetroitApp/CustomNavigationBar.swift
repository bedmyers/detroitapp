//
//  CustomNavigationBar.swift
//  DetroitApp
//
//  Created by Blair Myers on 6/21/23.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Binding var title: String
    @Binding var isPopoverPresented: Bool
    
    var body: some View {
        Button(action: {
            self.isPopoverPresented = true
        }) {
            HStack {
                Text(title)
                    .font(.system(size: 36, weight: .bold, design: .default))
                Image(systemName: "chevron.down")
            }
        }
        .foregroundColor(.black)
    }
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationBar(title: .constant("Detroit"), isPopoverPresented: .constant(false))
    }
}
