//
//  SoundLibrary.swift
//  Dream
//

import Foundation

enum SoundLibrary {
    static let soundscapes: [Soundscape] = load()
    static let defaultSound: Soundscape = soundscapes.first ?? fallbackSound

    private static let fallbackSound = Soundscape(
        id: "rain",
        title: "Regen",
        subtitle: "Sanftes Tropfen mit ruhigem Hintergrundrauschen",
        tagline: "Soft Rain",
        generator: SoundGenerator(
            kind: .rain,
            baseAmplitude: 0.14,
            modulationAmplitude: 0.04,
            secondaryAmplitude: 0,
            phaseStep: 0.12,
            secondaryPhaseStep: 0,
            smoothing: 0.76,
            accentThreshold: 0.992,
            accentRange: 0.08...0.18
        )
    )

    private static func load() -> [Soundscape] {
        guard
            let url = Bundle.main.url(
                forResource: "Soundscapes",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let soundscapes = try? JSONDecoder().decode(
                [Soundscape].self,
                from: data
            ),
            !soundscapes.isEmpty
        else {
            return [fallbackSound]
        }

        return soundscapes
    }
}
