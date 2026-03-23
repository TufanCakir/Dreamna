//
//  BreathingScreen.swift
//  Dream
//

import SwiftUI

struct BreathingScreen: View {
    let title: String
    let subtitle: String
    let breathingScale: CGFloat
    let breathingText: String
    let isSessionRunning: Bool
    let remainingTimeText: String
    let onEndSession: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            DreamHeaderView(title: title, subtitle: subtitle)

            Spacer()

            ZStack {
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 260, height: 260)
                    .blur(radius: 14)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                Color(red: 0.68, green: 0.79, blue: 1.0)
                                    .opacity(0.92),
                                Color(red: 0.18, green: 0.25, blue: 0.45)
                                    .opacity(0.78),
                            ],
                            center: .center,
                            startRadius: 16,
                            endRadius: 140
                        )
                    )
                    .frame(width: 210, height: 210)
                    .scaleEffect(breathingScale)
                    .shadow(color: .white.opacity(0.18), radius: 30)
            }

            Text(breathingText)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            if isSessionRunning {
                VStack(spacing: 8) {
                    Text(remainingTimeText)
                        .font(
                            .system(
                                size: 18,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.white.opacity(0.92))

                    Text("Auto Fade Out aktiv")
                        .font(
                            .system(size: 14, weight: .medium, design: .rounded)
                        )
                        .foregroundStyle(.white.opacity(0.62))
                }
            }

            Spacer()

            Button(action: onEndSession) {
                Text("End Session")
                    .font(
                        .system(size: 18, weight: .semibold, design: .rounded)
                    )
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white.opacity(0.12))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .transition(.opacity)
    }
}

struct DreamHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
