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
        @State private var currentOffset: CGSize = .zero
        @State private var opacity: Double = 1

        init(particle: Particle, inFrame area: CGRect) {
            self.particle = particle
            self.area = area
        }

        var body: some View {
            Circle()
                .frame(width: 2, height: 2)
                .position(
                    x: particle.startPosition.x,
                    y: particle.startPosition.y
                )
                .offset(self.currentOffset)
                .opacity(opacity)
                .onAppear(perform: self.startAnimation)
        }

        func startAnimation() {
            let startX = self.area.minX - self.particle.startPosition.x + 2
            let endX = self.area.maxX - self.particle.startPosition.x - 2
            let distanceTraveled = self.area.maxX - self.particle.startPosition.x - currentOffset.width
            withAnimation(
                Animation
                    .linear(duration: distanceTraveled / 100)
                    .speed(1.9)
            ) {
                self.currentOffset = .init(width: endX, height: 0)
            } completion: {
                self.currentOffset = .init(width: startX, height: 0)
                Task {
                    self.opacity = 0.0
                    try await Task.sleep(for: .milliseconds(Int.random(in: 0...100)))
                    self.opacity = 1.0
                    self.startAnimation()
                }
            }
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

    private func startAnimation() {
        withAnimation(.linear) {

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
    SedimentView(seed: 4, numberOfParticles: 200)
        .ignoresSafeArea()
        .frame(width: 250, height: 250)
        .border(.red)
}
