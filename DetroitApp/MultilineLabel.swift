//
//  MultilineLabel.swift
//  DetroitApp
//
//  Created by Blair Myers on 8/14/23.
//

import SwiftUI
import UIKit

struct MultilineLabel: UIViewRepresentable {
    var text: String

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = text
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
    }
}
