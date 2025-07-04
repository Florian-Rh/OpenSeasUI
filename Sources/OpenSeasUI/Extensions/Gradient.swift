//
//  Gradient.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 27.03.25.
//

import SwiftUI

public extension Gradient {
    static var deepOceanGradient: Gradient {
        Gradient(colors: [.abyssBlue, .deepSeaBlue, .oceanBlue, .waveBlue])
    }

    static var coralSunsetGradient: Gradient {
        Gradient(colors: [.deepSeaBlue, .oceanBlue, .sunsetOrange, .coralRed])
    }

    static var tropicalShoreGradient: Gradient {
        Gradient(colors: [.iceBlue, .seafoamGreen, .sandBeige])
    }

    static var midnightAbyssGradient: Gradient {
        Gradient(colors: [.oceanBlue, .deepSeaBlue, .abyssBlue, .black])
    }

    static var crystalLagoonGradient: Gradient {
        Gradient(colors: [.iceBlue, .seafoamGreen, .waveBlue])
    }

    static var nauticalGlowGradient: Gradient {
        Gradient(colors: [.oceanBlue, .waveBlue, .sunsetOrange])
    }
}
