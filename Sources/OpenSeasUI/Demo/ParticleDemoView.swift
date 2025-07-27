//
//  ParticleDemoView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 25.07.25.
//

import SwiftUI

struct ParticleDemoView: View {

    @State private var particles: [Particle] = []
    @State private var showControls = true
    @State private var speed: Double = 20.0
    @State private var randomAngle = false
    @State private var selectedAngle: Angle = .degrees(0)
    @State private var numberOfParticles: Int = 100
    @State private var randomColor = false
    @State private var selectedColor: Color = .white
    @State private var selectedShape: ParticleShape = .circle

    private enum ParticleShape {
        case circle
        case arrow
        case fish
    }

    private let colors: [Color] = [
        .oceanBlue,
        .deepSeaBlue,
        .waveBlue,
        .iceBlue,
        .seafoamGreen,
        .sandBeige,
    ]

    private var pickerStyle: some PickerStyle {
#if os(watchOS)
        return .automatic
#else
        return .segmented
#endif
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Color.abyssBlue
                ForEach(particles) { particle in
                    let color = randomColor ? colors.randomElement() ?? .black : selectedColor
                    let angle = randomAngle ? Angle(degrees: Double.random(in: 0...360)) : selectedAngle

                    ParticleView(
                        particle: particle,
                        inFrame: proxy.frame(in: .global),
                        vector: .init(from: angle),
                        speed: speed
                    ) {
                        switch selectedShape {
                            case .circle:
                                Circle()
                                    .frame(width: 2, height: 2)
                            case .arrow:
                                Image(systemName: "arrow.right")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .rotationEffect(angle)
                            case .fish:
                                Image(systemName: "fish.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .rotationEffect(angle)
                        }
                    }
                    .foregroundStyle(color)
                }

                // Control panel
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                showControls.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Controls")
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(showControls ? 90 : 0))
                            }
                        }
                        Spacer()
                    }
                    if showControls {
                        ScrollView {
                            Text("Speed: \(speed, specifier: "%.1F")")
                            Slider(
                                value: $speed,
                                in: 0.0...1000.0,
                                label: { EmptyView() },
                                minimumValueLabel: { Text("0,0") },
                                maximumValueLabel: { Text("1000,0")}
                            )

                            Toggle("Random direction for each particle", isOn: $randomAngle)
                            if !randomAngle {
                                Text("Direction: \(selectedAngle.degrees, specifier: "%.1F°")")
                                Slider(
                                    value: $selectedAngle.degrees,
                                    in: 0.0...360.0,
                                    label: { EmptyView() },
                                    minimumValueLabel: { Text("0") },
                                    maximumValueLabel: { Text("360")}
                                )
                            }

                            Text("Number of particles: \(numberOfParticles)")
                            Picker("", selection: $numberOfParticles) {
                                Text("1").tag(1)
                                Text("10").tag(10)
                                Text("100").tag(100)
                                Text("1000").tag(1000)
                            }
                            .pickerStyle(self.pickerStyle)
                            .onChange(of: numberOfParticles) {
                                self.calculateParticleLocations(
                                    inFrame: proxy.frame(in: .local)
                                )
                            }

#if !os(watchOS)
                            Toggle("Random OpenSeasUI Color", isOn: $randomColor)
                            if !randomColor {
                                ColorPicker("Particle color", selection: $selectedColor)
                            }
#endif

                            Text("Shape")
                            Picker("", selection: $selectedShape) {
                                Image(systemName: "circle.fill").tag(ParticleShape.circle)
                                Image(systemName: "arrow.right").tag(ParticleShape.arrow)
                                Image(systemName: "fish").tag(ParticleShape.fish)
                            }
                            .pickerStyle(self.pickerStyle)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 15.0)
                .background(.thinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 15.0)
                )
                .padding(.horizontal)
            }
            .ignoresSafeArea()
            .onAppear {
                self.calculateParticleLocations(
                    inFrame: proxy.frame(in: .local)
                )
            }
        }
    }

    private func calculateParticleLocations(inFrame frame: CGRect) {
//        var randomNumberGenerator = SeededRandomNumberGenerator(seed: self.seed)
        self.particles = []
        for index in 0..<numberOfParticles {
            let x: CGFloat = CGFloat.random(in: 0...2)
            let y: CGFloat = CGFloat.random(in: 0...2)

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
    ParticleDemoView()
}
