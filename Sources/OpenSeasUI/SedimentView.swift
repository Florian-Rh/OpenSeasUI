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
        private let boundingArea: CGRect
        private let vector: CGVector
        @State private var currentFrame: CGRect?
        @State private var id = UUID()

        /// The point at which the partivle first appears
        private var startPosition: CGPoint {
            // TODO: startPosition ändert sich nicht mit einer Änderung des Vectors, daher wird die Animation nicht geändert, wenn der Punkt in der Animationsphase startPosition ist
            particle.startPosition
        }

        /// The point the particle travels to after appearing.
        /// In the bounding area, this is the point where the particle hits the area when following the given vector
        private var endPosition: CGPoint {
            Geometry.intersectionPoint(
                in: boundingArea,
                from: startPosition,
                direction: vector
            )
        }

        /// The point at which the particle should respawn after it reached the end position.
        /// In the bounding area, this is the point opposite from the end position in the given direction
        private var respawnPosition: CGPoint {
            Geometry.intersectionPoint(
                in: boundingArea,
                from: startPosition,
                direction: vector.inverted
            )
        }

        init(particle: Particle, inFrame area: CGRect, vector: CGVector) {
            self.particle = particle
            self.boundingArea = area
            self.vector = vector
        }

        var body: some View {
            Circle()
                .frame(width: 2, height: 2)
                .phaseAnimator(
                    [startPosition, endPosition, respawnPosition],
                    content: { view, position in
                        view.position(position)
                    },
                    animation: { position in
                        let duration = calculateDuration(forPosition: position)

                        return Animation
                            .linear(duration: duration)
                    }
                )
                .onChange(of: vector) {
                    // TODO: aktuelle position bestimmen und startPosition überschreiben
                }
        }

        private func calculateDuration(forPosition position: CGPoint) -> Double {
            let distance: Double
            switch position {
                case endPosition:
                    distance = Geometry.calculateDistance(
                        a: startPosition,
                        b: endPosition
                    )
                case respawnPosition:
                    distance = 0  // Moving to the respawn point is instantaneous
                case startPosition:
                    distance = Geometry.calculateDistance(
                        a: respawnPosition,
                        b: startPosition
                    )
                default:
                    fatalError("unexpected position for particle: \(position)")
            }

            return distance / 30
        }
    }

    @Binding private var angle: Angle
    private let seed: Int
    private let numberOfParticles: Int
    @State private var particles: [Particle] = []

    init(
        angle: Binding<Angle>,
        seed: Int = .random(in: 0...Int.max),
        numberOfParticles: Int = 100
    ) {
        self._angle = angle
        self.seed = seed
        self.numberOfParticles = numberOfParticles
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(particles) { particle in
                    ParticleView(
                        particle: particle,
                        inFrame: proxy.frame(in: .local),
                        vector: .init(from: self.angle)
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
    @Previewable @State var angle: Angle = .zero

    VStack {
        SedimentView(angle: $angle, seed: 1, numberOfParticles: 1)
            .ignoresSafeArea()
            .frame(width: 250, height: 250)
            .border(.red)

        Slider(value: $angle.degrees, in: 0...360)
        Button("Rotate 90°") {
            angle.degrees += 90
        }
    }
}
