//
//  SoundSelectionScreen.swift
//  Dream
//

import SwiftUI

struct SoundSelectionScreen: View {
    let soundscapes: [Soundscape]
    let selectedSoundIDs: Set<String>
    let selectedSounds: [Soundscape]
    let selectedSoundTitle: String
    let selectedSoundTaglines: String
    @Binding var selectedDuration: TimeInterval
    @Binding var volume: Double
    let canStartSession: Bool
    let onToggleSound: (Soundscape) -> Void
    let onClearMix: () -> Void
    let onStartSession: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            DreamHeaderView(
                title: "Sleep Sounds",
                subtitle: "Wähle mehrere Sounds aus und mische sie."
            )
            .padding(.horizontal)

            MixSummaryView(
                selectedSounds: selectedSounds,
                selectedSoundTitle: selectedSoundTitle,
                onClearMix: onClearMix
            )

            if selectedSounds.count > 1 {
                Text(selectedSoundTaglines)
                    .font(
                        .system(size: 13, weight: .semibold, design: .rounded)
                    )
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.horizontal)
            }

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(soundscapes) { sound in
                        SoundscapeRow(
                            sound: sound,
                            isSelected: selectedSoundIDs.contains(sound.id),
                            selectedSoundTitle: selectedSoundTitle
                        ) {
                            onToggleSound(sound)
                        }
                    }
                }
                .padding()
            }

            VStack(spacing: 20) {
                VolumeControlView(volume: $volume)
                DurationPickerView(selectedDuration: $selectedDuration)

                Button(action: onStartSession) {
                    Text("Begin Session")
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .disabled(!canStartSession)
                .opacity(canStartSession ? 1 : 0.55)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
    }
}

private struct MixSummaryView: View {
    let selectedSounds: [Soundscape]
    let selectedSoundTitle: String
    let onClearMix: () -> Void

    @ViewBuilder
    var body: some View {
        if selectedSounds.count > 1 {
            HStack {
                Text("Mix: \(selectedSoundTitle)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                Button(action: onClearMix) {
                    Text("Clear")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.15), in: Capsule())
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct SoundscapeRow: View {
    let sound: Soundscape
    let isSelected: Bool
    let selectedSoundTitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(sound.title)
                        .font(
                            .system(
                                size: 20,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.white)

                    Text(sound.subtitle)
                        .font(
                            .system(size: 14, weight: .medium, design: .rounded)
                        )
                        .foregroundStyle(.white.opacity(0.62))

                    Text("Mix: \(selectedSoundTitle)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(sound.tagline)
                        .font(
                            .system(size: 12, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(.white.opacity(0.72))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.10), in: Capsule())

                    Image(
                        systemName: isSelected
                            ? "checkmark.circle.fill" : "circle"
                    )
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.35))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        isSelected ? .white.opacity(0.16) : .white.opacity(0.08)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct VolumeControlView: View {
    @Binding var volume: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Lautstärke")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Slider(value: $volume, in: 0...1)
                .tint(.white)
        }
        .padding()
        .background(
            .white.opacity(0.08),
            in: RoundedRectangle(cornerRadius: 24)
        )
    }
}

private struct DurationPickerView: View {
    @Binding var selectedDuration: TimeInterval

    private let durations = [10, 20, 30]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(durations, id: \.self) { minutes in
                let duration = TimeInterval(minutes * 60)

                Button {
                    selectedDuration = duration
                } label: {
                    Text("\(minutes) min")
                        .foregroundStyle(
                            selectedDuration == duration ? .black : .white
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            selectedDuration == duration
                                ? .white : .white.opacity(0.08)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
        }
    }
}
