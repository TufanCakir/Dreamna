//
//  StartScreenView.swift
//  Dream
//

import SwiftUI

struct StartScreenView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 180, height: 180)

                Image(systemName: "moon.fill")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 0.62, green: 0.74, blue: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 16) {
                Text("Dreamna")
                    .font(
                        .system(size: 42, weight: .semibold, design: .rounded)
                    )
                    .foregroundStyle(.white)

                Text(
                    "Entspanne dich mit Sound, Atemrhythmus und sanftem Ausklang."
                )
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
                .multilineTextAlignment(.center)
            }

            Spacer()

            Button(action: onStart) {
                Text("Start Relax")
                    .font(
                        .system(size: 18, weight: .semibold, design: .rounded)
                    )
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                    )
            }
            .padding()
        }
        .transition(.opacity)
    }
}
