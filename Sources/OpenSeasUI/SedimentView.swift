//
//  SedimentView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 02.05.25.
//

import SwiftUI

struct SedimentView: View {

    private struct Particle: Identifiable {
        let startPosition: CGPoint
        let id: Int
    }

    private struct ParticleView: View {
        private let particle: Particle
        private let area: CGRect
        @State private var opacity: Double = 1
        let direction: CGVector = .init(dx: 1, dy: 1)

        private var spawnPosition: CGPoint {
            let x = 0.0
            let y = particle.startPosition.y

            return .init(x: x, y: y)
        }

        private var endPosition: CGPoint {
            let x = area.maxX
            let y = particle.startPosition.y

            return .init(x: x, y: y)
        }

        private var gradient: Double {
            direction.dy / direction.dx
        }

        init(particle: Particle, inFrame area: CGRect) {
            self.particle = particle
            self.area = area
        }

        private func calculateDuration(forPosition position: CGPoint) -> Double {
            let distanceTraveled: Double
            if position == spawnPosition {
                distanceTraveled = 0
            } else if position == endPosition {
                distanceTraveled = area.maxX - particle.startPosition.x
            } else {
                distanceTraveled = particle.startPosition.x
            }

            return distanceTraveled / 30
        }

        var body: some View {
            Circle()
                .frame(width: 2, height: 2)
                .phaseAnimator(
                    [particle.startPosition, endPosition, spawnPosition],
                    content: { view, position in
                        view.position(position)
                    },
                    animation: { position in
                        let duration = calculateDuration(forPosition: position)

                        return Animation
                            .linear(duration: duration)
                    }
                )
        }
    }


    private let seed: Int
    private let numberOfParticles: Int
    private let vector: CGVector = CGVector(dx: 1, dy: 1)
    @State private var particles: [Particle] = []

    init(
        seed: Int = .random(in: 0...Int.max),
        numberOfParticles: Int = 100
    ) {
        self.seed = seed
        self.numberOfParticles = numberOfParticles
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(particles) { particle in
                    ParticleView(
                        particle: particle,
                        inFrame: proxy.frame(in: .local)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .onAppear {
                self.calculateParticleLocations(
                    inFrame: proxy.frame(in: .local)
                )
            }
        }
    }

    private func calculateParticleLocations(inFrame frame: CGRect) {
        var randomNumberGenerator = SeededRandomNumberGenerator(seed: self.seed)
        for index in 0..<numberOfParticles {
            let x: CGFloat = CGFloat.random(in: 0...2, using: &randomNumberGenerator)
            let y: CGFloat = CGFloat.random(in: 0...2, using: &randomNumberGenerator)
            self.particles.append(
                Particle(
                    startPosition: .init(x: frame.midX * x, y: frame.midY * y),
                    id: index
                )
            )
        }
    }
}

#Preview {
    SedimentView(seed: 1, numberOfParticles: 100)
        .ignoresSafeArea()
        .frame(width: 250, height: 250)
        .border(.red)
}

