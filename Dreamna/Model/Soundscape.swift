//
//  Soundscape.swift
//  Dream
//

import Foundation

struct Soundscape: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let tagline: String
    let generator: SoundGenerator
}

enum SoundGeneratorKind: String, Codable {
    case whiteNoise
    case waves
    case rain
    case forest
    case fireplace
}

struct SoundGenerator: Codable, Equatable {
    let kind: SoundGeneratorKind
    let baseAmplitude: Float
    let modulationAmplitude: Float
    let secondaryAmplitude: Float
    let phaseStep: Float
    let secondaryPhaseStep: Float
    let smoothing: Float
    let accentThreshold: Float
    let accentRange: ClosedRange<Float>

    private enum CodingKeys: String, CodingKey {
        case kind
        case baseAmplitude
        case modulationAmplitude
        case secondaryAmplitude
        case phaseStep
        case secondaryPhaseStep
        case smoothing
        case accentThreshold
        case accentRange
    }

    init(
        kind: SoundGeneratorKind,
        baseAmplitude: Float,
        modulationAmplitude: Float,
        secondaryAmplitude: Float,
        phaseStep: Float,
        secondaryPhaseStep: Float,
        smoothing: Float,
        accentThreshold: Float,
        accentRange: ClosedRange<Float>
    ) {
        self.kind = kind
        self.baseAmplitude = baseAmplitude
        self.modulationAmplitude = modulationAmplitude
        self.secondaryAmplitude = secondaryAmplitude
        self.phaseStep = phaseStep
        self.secondaryPhaseStep = secondaryPhaseStep
        self.smoothing = smoothing
        self.accentThreshold = accentThreshold
        self.accentRange = accentRange
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(SoundGeneratorKind.self, forKey: .kind)
        baseAmplitude = try container.decode(Float.self, forKey: .baseAmplitude)
        modulationAmplitude = try container.decode(
            Float.self,
            forKey: .modulationAmplitude
        )
        secondaryAmplitude = try container.decode(
            Float.self,
            forKey: .secondaryAmplitude
        )
        phaseStep = try container.decode(Float.self, forKey: .phaseStep)
        secondaryPhaseStep = try container.decode(
            Float.self,
            forKey: .secondaryPhaseStep
        )
        smoothing = try container.decode(Float.self, forKey: .smoothing)
        accentThreshold = try container.decode(
            Float.self,
            forKey: .accentThreshold
        )

        let range = try container.decode([Float].self, forKey: .accentRange)
        guard range.count == 2 else {
            throw DecodingError.dataCorruptedError(
                forKey: .accentRange,
                in: container,
                debugDescription: "accentRange requires exactly two values."
            )
        }
        accentRange = range[0]...range[1]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(baseAmplitude, forKey: .baseAmplitude)
        try container.encode(modulationAmplitude, forKey: .modulationAmplitude)
        try container.encode(secondaryAmplitude, forKey: .secondaryAmplitude)
        try container.encode(phaseStep, forKey: .phaseStep)
        try container.encode(secondaryPhaseStep, forKey: .secondaryPhaseStep)
        try container.encode(smoothing, forKey: .smoothing)
        try container.encode(accentThreshold, forKey: .accentThreshold)
        try container.encode(
            [accentRange.lowerBound, accentRange.upperBound],
            forKey: .accentRange
        )
    }
}
