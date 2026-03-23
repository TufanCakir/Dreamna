//
//  ContentView.swift
//  Dream
//
//  Created by Tufan Cakir on 22.03.26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentScreen: Screen = .start
    @State private var selectedSoundIDs: Set<String> = [
        SoundLibrary.defaultSound.id
    ]
    @State private var selectedDuration: TimeInterval = 20 * 60
    @State private var volume: Double = 0.55
    @State private var audioManager = AudioManager()
    @State private var breathingScale: CGFloat = 0.84
    @State private var breathingText = "Breathe in..."
    @State private var breathTask: Task<Void, Never>?

    private let soundscapes = SoundLibrary.soundscapes

    private var selectedSounds: [Soundscape] {
        let sounds = soundscapes.filter { selectedSoundIDs.contains($0.id) }
        return sounds.isEmpty ? [SoundLibrary.defaultSound] : sounds
    }

    private var selectedSoundTitle: String {
        let titles = selectedSounds.map(\.title)
        if titles.count <= 2 {
            return titles.joined(separator: " + ")
        }

        return
            "\(titles.prefix(2).joined(separator: " + ")) + \(titles.count - 2)"
    }

    private var selectedSoundSubtitle: String {
        if selectedSounds.count == 1, let sound = selectedSounds.first {
            return
                "Folge dem Kreis und lass \(sound.tagline.lowercased()) tragen."
        }

        return "Folge dem Kreis und lass deinen Sound-Mix tragen."
    }

    private var selectedSoundTaglines: String {
        selectedSounds.map(\.tagline).joined(separator: " • ")
    }

    private var canStartSession: Bool {
        !selectedSounds.isEmpty
    }

    var body: some View {
        ZStack {
            DreamBackgroundView()

            switch currentScreen {
            case .start:
                StartScreenView {
                    currentScreen = .sound
                }
            case .sound:
                SoundSelectionScreen(
                    soundscapes: soundscapes,
                    selectedSoundIDs: selectedSoundIDs,
                    selectedSounds: selectedSounds,
                    selectedSoundTitle: selectedSoundTitle,
                    selectedSoundTaglines: selectedSoundTaglines,
                    selectedDuration: $selectedDuration,
                    volume: $volume,
                    canStartSession: canStartSession,
                    onToggleSound: toggleSound,
                    onClearMix: clearMix,
                    onStartSession: startRelaxSession
                )
            case .breathing:
                BreathingScreen(
                    title: selectedSoundTitle,
                    subtitle: selectedSoundSubtitle,
                    breathingScale: breathingScale,
                    breathingText: breathingText,
                    isSessionRunning: audioManager.isSessionRunning,
                    remainingTimeText: audioManager.remainingTimeText,
                    onEndSession: endSession
                )
                .onAppear {
                    startBreathingAnimation()
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: volume) { _, newValue in
            audioManager.setVolume(Float(newValue))
        }
        .onChange(of: currentScreen) { _, newValue in
            if newValue != .breathing {
                stopBreathingAnimation()
            }
        }
        .onDisappear {
            stopBreathingAnimation()
            audioManager.stop()
        }
    }

    private func toggleSound(_ sound: Soundscape) {
        if selectedSoundIDs.contains(sound.id) {
            if selectedSoundIDs.count > 1 {
                selectedSoundIDs.remove(sound.id)
            }
        } else {
            selectedSoundIDs.insert(sound.id)
        }

        audioManager.setSoundscapes(selectedSounds)
    }

    private func clearMix() {
        selectedSoundIDs = [SoundLibrary.defaultSound.id]
        audioManager.setSoundscapes(selectedSounds)
    }

    private func startRelaxSession() {
        audioManager.start(
            soundscapes: selectedSounds,
            volume: Float(volume),
            duration: selectedDuration
        )
        currentScreen = .breathing
    }

    private func endSession() {
        audioManager.stop()
        currentScreen = .sound
    }

    private func startBreathingAnimation() {
        stopBreathingAnimation()
        breathingScale = 0.84
        breathingText = "Breathe in..."

        breathTask = Task {
            while !Task.isCancelled && currentScreen == .breathing {
                await MainActor.run {
                    breathingText = "Breathe in..."
                    withAnimation(.easeInOut(duration: 4)) {
                        breathingScale = 1.14
                    }
                }

                try? await Task.sleep(for: .seconds(4))
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    breathingText = "Breathe out..."
                    withAnimation(.easeInOut(duration: 4)) {
                        breathingScale = 0.84
                    }
                }

                try? await Task.sleep(for: .seconds(4))
            }
        }
    }

    private func stopBreathingAnimation() {
        breathTask?.cancel()
        breathTask = nil
    }
}

#Preview {
    ContentView()
}
