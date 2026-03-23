//
//  AudioManager.swift
//  Dream
//

import AVFoundation
import Observation

@Observable
final class AudioManager {
    var isSessionRunning = false
    var remainingTimeText = "20:00"

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var sessionTimer: Timer?
    private var endDate: Date?
    private var fadeTask: Task<Void, Never>?

    private var activeGenerators: [ActiveGenerator] = [
        ActiveGenerator(soundscape: SoundLibrary.defaultSound)
    ]
    private var volume: Float = 0.55
    private var currentLevel: Float = 0.55
    private var previousSample: Float = 0

    func start(soundscapes: [Soundscape], volume: Float, duration: TimeInterval)
    {
        setSoundscapes(soundscapes)
        self.volume = volume
        currentLevel = volume
        remainingTimeText = Self.format(duration)
        endDate = Date().addingTimeInterval(duration)

        configureAudioSession()
        installSourceNodeIfNeeded()

        if !engine.isRunning {
            try? engine.start()
        }

        engine.mainMixerNode.outputVolume = currentLevel
        isSessionRunning = true
        scheduleTimer()
    }

    func stop() {
        fadeTask?.cancel()
        fadeTask = nil
        sessionTimer?.invalidate()
        sessionTimer = nil
        endDate = nil
        isSessionRunning = false
        remainingTimeText = "00:00"

        engine.mainMixerNode.outputVolume = 0
        engine.stop()
    }

    func setVolume(_ volume: Float) {
        self.volume = volume
        currentLevel = volume
        if isSessionRunning {
            engine.mainMixerNode.outputVolume = volume
        }
    }

    func setSoundscapes(_ soundscapes: [Soundscape]) {
        let sounds =
            soundscapes.isEmpty ? [SoundLibrary.defaultSound] : soundscapes
        activeGenerators = sounds.map(ActiveGenerator.init(soundscape:))
        previousSample = 0
    }

    private func configureAudioSession() {
        #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try? session.setActive(true)
        #endif
    }

    private func installSourceNodeIfNeeded() {
        guard sourceNode == nil else { return }

        let format = engine.outputNode.outputFormat(forBus: 0)
        let channels = Int(format.channelCount)

        let node = AVAudioSourceNode {
            [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }

            let ablPointer = UnsafeMutableAudioBufferListPointer(
                audioBufferList
            )

            for frame in 0..<Int(frameCount) {
                let sample = self.nextMixedSample()

                for channel in 0..<channels {
                    let buffer = ablPointer[channel]
                    let pointer = buffer.mData?.assumingMemoryBound(
                        to: Float.self
                    )

                    let left = sample * 0.98
                    let right = sample * 1.02

                    if channel == 0 {
                        pointer?[frame] = left
                    } else {
                        pointer?[frame] = right
                    }
                }
            }

            return noErr
        }

        sourceNode = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
    }

    private func scheduleTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true)
        { [weak self] _ in
            self?.tick()
        }

        if let sessionTimer {
            RunLoop.main.add(sessionTimer, forMode: .common)
        }
    }

    private func tick() {
        guard let endDate else { return }

        let remaining = max(0, endDate.timeIntervalSinceNow)
        remainingTimeText = Self.format(remaining)

        if remaining <= 0 {
            sessionTimer?.invalidate()
            sessionTimer = nil
            startFadeOut()
        }
    }

    private func startFadeOut() {
        fadeTask?.cancel()
        fadeTask = Task {
            let startVolume = currentLevel
            let steps = 24

            for step in 0...steps {
                let progress = Float(step) / Float(steps)
                let newVolume = startVolume * (1 - progress)

                await MainActor.run {
                    self.engine.mainMixerNode.outputVolume = newVolume
                    self.remainingTimeText = "00:00"
                }

                try? await Task.sleep(for: .milliseconds(250))
            }

            await MainActor.run {
                self.stop()
            }
        }
    }

    private func nextMixedSample() -> Float {
        guard !activeGenerators.isEmpty else { return 0 }

        var mixed: Float = 0

        for index in activeGenerators.indices {
            mixed += renderSample(
                for: &activeGenerators[index].state,
                generator: activeGenerators[index].soundscape.generator
            )
        }

        let normalized = mixed / sqrt(Float(activeGenerators.count))
        let smooth = (normalized + previousSample) * 0.5
        previousSample = smooth

        let limited = max(min(smooth, 0.8), -0.8)
        return limited * 0.9
    }

    private func renderSample(
        for state: inout GeneratorState,
        generator: SoundGenerator
    ) -> Float {
        let white = Float.random(in: -1...1)
        let smoothing = generator.smoothing == 0 ? 0.98 : generator.smoothing

        state.lowPass = state.lowPass * smoothing + white * (1 - smoothing)
        state.pink0 = 0.997 * state.pink0 + state.lowPass * 0.099
        state.pink1 = 0.963 * state.pink1 + state.lowPass * 0.296
        state.pink2 = 0.570 * state.pink2 + state.lowPass * 1.052

        let pink =
            state.pink0 + state.pink1 + state.pink2 + state.lowPass * 0.184

        switch generator.kind {
        case .whiteNoise:
            return pink * generator.baseAmplitude
        case .waves:
            state.primaryPhase += generator.phaseStep
            let swell = (sin(state.primaryPhase) + 1) * 0.5
            return pink
                * (generator.baseAmplitude * 0.4 + swell
                    * generator.modulationAmplitude * 0.35)
        case .rain:
            state.primaryPhase += generator.phaseStep
            let shimmer =
                sin(state.primaryPhase) * generator.modulationAmplitude * 0.25
            let drop =
                Float.random(in: 0...1) > generator.accentThreshold
                ? Float.random(in: generator.accentRange)
                : 0
            return pink * generator.baseAmplitude * 0.45 + shimmer + drop
        case .forest:
            state.primaryPhase += generator.phaseStep
            state.secondaryPhase += generator.secondaryPhaseStep
            let wind =
                sin(state.primaryPhase) * generator.modulationAmplitude * 0.6
            let leaves = pink * generator.baseAmplitude * 0.5
            let accent =
                Float.random(in: 0...1) > generator.accentThreshold
                ? Float.random(in: generator.accentRange)
                : 0
            return leaves + wind + accent
        case .fireplace:
            state.primaryPhase += generator.phaseStep
            state.secondaryPhase += generator.secondaryPhaseStep
            let ember = pink * generator.baseAmplitude * 0.45
            let warmth =
                cos(state.secondaryPhase) * generator.modulationAmplitude * 0.35
            let crackle =
                Float.random(in: 0...1) > generator.accentThreshold
                ? Float.random(in: generator.accentRange)
                : 0
            return ember + warmth + crackle
        }
    }

    private static func format(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct ActiveGenerator {
    let soundscape: Soundscape
    var state = GeneratorState()

    nonisolated init(soundscape: Soundscape) {
        self.soundscape = soundscape
    }
}

private struct GeneratorState {
    var primaryPhase: Float = 0
    var secondaryPhase: Float = 0
    var lowPass: Float = 0
    var pink0: Float = 0
    var pink1: Float = 0
    var pink2: Float = 0
}
