//
//  File.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 27.03.25.
//

import SwiftUI

public extension ShapeStyle where Self == Color {
    static var oceanBlue: Color {
        .init(red: 0, green: 157.0 / 255, blue: 196.0 / 255)
    }

    static var deepSeaBlue: Color {
        .init(red: 0, green: 100.0 / 255, blue: 150.0 / 255)
    }

    static var abyssBlue: Color {
        .init(red: 10.0 / 255, green: 30.0 / 255, blue: 80.0 / 255)
    }

    static var waveBlue: Color {
        .init(red: 0, green: 120.0 / 255, blue: 200.0 / 255)
    }

    static var iceBlue: Color {
        .init(red: 180.0 / 255, green: 220.0 / 255, blue: 255.0 / 255)
    }

    static var coralRed: Color {
        .init(red: 255.0 / 255, green: 77.0 / 255, blue: 64.0 / 255)
    }

    static var sunsetOrange: Color {
        .init(red: 255.0 / 255, green: 140.0 / 255, blue: 0)
    }

    static var seafoamGreen: Color {
        .init(red: 120.0 / 255, green: 220.0 / 255, blue: 180.0 / 255)
    }

    static var sandBeige: Color {
        .init(red: 210.0 / 255, green: 190.0 / 255, blue: 140.0 / 255)
    }
}
