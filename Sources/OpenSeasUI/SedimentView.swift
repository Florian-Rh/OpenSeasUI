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
        enum AnimationPhase: CaseIterable {
            case start
            case end
            case respawn
        }

        private let particle: Particle
        private let boundingArea: CGRect
        private let vector: CGVector
        @State private var currentDestination: CGPoint?
        @State private var animationStartTime: Date?
        @State private var id = UUID()

        /// The point at which the particle first appears
        @State private var startPosition: CGPoint

        /// The point the particle travels to after appearing.
        /// In the bounding area, this is the point where the particle hits the area when following the given vector
        @State private var endPosition: CGPoint

        /// The point at which the particle should respawn after it reached the end position.
        /// In the bounding area, this is the point opposite from the end position in the given direction
        @State private var respawnPosition: CGPoint

        init(particle: Particle, inFrame area: CGRect, vector: CGVector) {
            self.particle = particle
            self.boundingArea = area
            self.vector = vector
            self.startPosition = particle.startPosition

            self.endPosition = Geometry.intersectionPoint(
                in: boundingArea,
                from: particle.startPosition,
                direction: vector
            )
            self.respawnPosition = Geometry.intersectionPoint(
                in: boundingArea,
                from: particle.startPosition,
                direction: vector.inverted
            )
        }

        var body: some View {
            Circle()
                .frame(width: 2, height: 2)
                .phaseAnimator(
                    AnimationPhase.allCases,
                    content: { view, phase in
                        let position = getPosition(for: phase)

                        return view
                            .position(position)
                            .onChange(of: phase) {
                                self.animationStartTime = Date()
                                self.currentDestination = position
                            }
                    },
                    animation: { phase in
                        let position = getPosition(for: phase)
                        let duration = calculateDuration(forPosition: position)

                        return .linear(duration: duration)
                    }
                )
                .onChange(of: vector) {
                    print("Vector changed")
                    guard let currentDestination, let animationStartTime else { return }
                    let previousPosition: CGPoint
                    switch currentDestination {
                        case endPosition:
                            previousPosition = startPosition
                        case respawnPosition:
                            previousPosition = endPosition
                        case startPosition:
                            previousPosition = respawnPosition
                        default:
                            previousPosition = startPosition
                    }
                    print("Previous position: \(previousPosition)")
                    print("Destination position: \(currentDestination)")
                    print("Animation start: \(animationStartTime.timeIntervalSince1970)")
                    print("current time: \(Date().timeIntervalSince1970)")
                    let duration = calculateDuration(forPosition: currentDestination)
                    print("duration: \(duration)")
                    let approximatePosition = Geometry
                        .calculatePosition(
                            between: previousPosition,
                            and: currentDestination,
                            forTime: Date(),
                            startTime: animationStartTime,
                            duration: duration
                        )
                    print("Approx. current position: \(approximatePosition)")
                    self.startPosition = approximatePosition
                    self.endPosition = Geometry.intersectionPoint(
                        in: boundingArea,
                        from: approximatePosition,
                        direction: vector
                    )
                    self.respawnPosition = Geometry.intersectionPoint(
                        in: boundingArea,
                        from: approximatePosition,
                        direction: vector.inverted
                    )
                    self.id = UUID()
                }
                .id(id)
        }

        private func getPosition(for phase: AnimationPhase) -> CGPoint {
            switch phase {
                case .start:
                    self.startPosition
                case .end:
                    self.endPosition
                case .respawn:
                    self.respawnPosition
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
                    distance = 0
            }

            return distance / 30
        }
    }

    @Binding private var angle: Angle
    private let seed: Int
    private let numberOfParticles: Int
    @State private var particles: [Particle] = [] // [Particle(startPosition: .init(x: 125, y: 125), id: 1)]

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
        SedimentView(angle: $angle, seed: 1, numberOfParticles: 100)
            .ignoresSafeArea()
            .frame(width: 250, height: 250)
            .border(.red)

        Slider(value: $angle.degrees, in: 0...360)
        Button("Rotate 90°") {
            angle.degrees += 90
        }
    }
}
