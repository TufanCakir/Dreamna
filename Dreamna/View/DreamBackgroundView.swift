//
//  DreamBackgroundView.swift
//  Dream
//

import SwiftUI

struct DreamBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.03, blue: 0.10),
                Color(red: 0.08, green: 0.10, blue: 0.23),
                Color(red: 0.01, green: 0.01, blue: 0.06),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
