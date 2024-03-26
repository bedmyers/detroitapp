//
//  HorizontalDivider.swift
//  DetroitApp
//
//  Created by Blair Myers on 6/2/23.
//

import SwiftUI

struct HorizontalDivider: View {
    @State var color: Color = Color(.limeGreen)
    @State var height: CGFloat = 1
    @State var horizontalPadding: CGFloat = 1
    
    var body: some View {
        Divider()
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, horizontalPadding)
            .background(color)
    }
}
