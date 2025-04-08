//
//  WaveView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 27.03.25.
//

import SwiftUI

public struct WaveView: View {
    /// Describes how the waves should be animated. Options are:
    ///  -  `.continuous(duration: Double)`: Waves move continously in one direction using the `linear` animation. The `duration` parameter describes, in seconds, how long ot takes to complete one animation.
    ///  - `.backAndForth(duration: Double, distance: Int)`: Waves move back and forth using the `easeInOut` animation. The `duration` parameter describes, in seconds, how long ot takes to complete one animation. The `distance` parameter describes how many waves pass in one direction before the direction is reversed
    ///  - `.none`: Waves are not animated
    public enum AnimationBahaviour: Hashable {
        case continuous(duration: Double)
        case backAndForth(duration: Double, distance: Int = 2)
        case none

        fileprivate var endPhase: Double {
            switch self {
                case .continuous:
                    return 2 * .pi
                case let .backAndForth(_, distance):
                    return max(Double(distance * 2), 2) * .pi
                case .none:
                    return 0.0
            }
        }

        fileprivate var animation: Animation? {
            switch self {
                case let .continuous(duration):
                    return
                        .linear(duration: duration)
                        .repeatForever(autoreverses: false)
                case let .backAndForth(duration, _):
                    return
                        .easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                case .none:
                    return nil
            }
        }
    }

    private let amplitude: Double
    private let waveLength: Double
    private let waterLevel: Double
    private let animationBehaviour: AnimationBahaviour
    private let rotation: Double
    private let startPhase: Double
    @State private var phase: Double

    /// Initializes a new wave view. The view consists of a sine wave and a filled area under the wave.
    /// - Parameters:
    ///   - amplitude: The height of the wave
    ///   - waveLength: The length of the wave. Note: This value must be greater than Zero. If it is smaller or equal to zero, the initializer will fallback to `Double.leastNormalMagnitude`
    ///   - waterLevel: Level in fraction of the surrounding rectangle, where the water line should be drawn.
    ///   - animationBehavior: Describes how the waves should be animated.
    ///   - rotation: Rotation of the water surface in radians. Note: Rotation can only defined between -.pi/4 and .pi/4 (or -45° and 45°). Past 45°, the device oriantation changes. The initializer will fallback to -.pi/4 if the passed value is smaller, and it will fallback to .pi/4 if the passed value is greater.
    ///   - startPhase: The phase of the sine wave function in which the wave should start. Accepts values between 0.0 and 1.0.
    public init(
        amplitude: Double,
        waveLength: Double,
        waterLevel: Double = 0.5,
        animationBehaviour: AnimationBahaviour = .backAndForth(duration: 2.5),
        rotation: Double = 0.0,
        startPhase: Double = 0.0
    ) {
        self.amplitude = amplitude
        self.waveLength = waveLength
        self.waterLevel = waterLevel
        self.animationBehaviour = animationBehaviour
        self.rotation = rotation
        self.startPhase = startPhase * .pi
        self.phase = startPhase * .pi
    }

    public var body: some View {
        WaveShape(
            amplitude: amplitude,
            waveLength: waveLength,
            waterLevel: waterLevel,
            phase: phase,
            rotation: rotation
        )
        .onAppear(perform: self.startAnimation)
    }

    private func startAnimation() {
        guard let animation = self.animationBehaviour.animation else {
            return
        }

        self.phase = self.startPhase

        withAnimation(animation) {
            self.phase = self.startPhase + self.animationBehaviour.endPhase
        }
    }
}

#Preview {
    WaveView(
        amplitude: 50,
        waveLength: 0.5,
        waterLevel: 0.5,
        animationBehaviour: .continuous(duration: 1.0),
        startPhase: 1
    )
}
