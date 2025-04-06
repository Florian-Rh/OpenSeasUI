//
//  WaveView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 27.03.25.
//

import SwiftUI

@available(iOS 17.0, *)
public struct WaveView: View {
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

    let amplitude: Double
    let waveLength: Double
    let waterLevel: Double
    let animationBehaviour: AnimationBahaviour
    let rotation: Double
    private let startPhase: Double
    @State private var phase: Double

    public init(
        amplitude: Double,
        waveLength: Double,
        waterLevel: Double = 0.5,
        animationBehaviour: AnimationBahaviour = .backAndForth(duration: 2.5),
        rotation: Double = 0.0,
        startPhase: Double = 1
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

@available(iOS 17.0, *)
#Preview {
    WaveView(
        amplitude: 50,
        waveLength: 0.5,
        waterLevel: 0.5,
        animationBehaviour: .continuous(duration: 1.0),
        startPhase: 1
    )
}
