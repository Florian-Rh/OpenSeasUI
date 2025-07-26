//
//  ColorDemoView.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 04.07.25.
//

import SwiftUI

#Preview("midnightAbyssGradient") {
    LinearGradient(gradient: .midnightAbyssGradient, startPoint: .top, endPoint: .bottom)
}

#Preview("Colors") {
    List {
        ZStack {
            Color.waveBlue
            Text("waveBlue").foregroundStyle(.white)
        }
        ZStack {
            Color.oceanBlue
            Text("oceanBlue").foregroundStyle(.white)
        }
        ZStack {
            Color.deepSeaBlue
            Text("deepSeaBlue").foregroundStyle(.white)
        }
        ZStack {
            Color.abyssBlue
            Text("abyssBlue").foregroundStyle(.white)
        }
        ZStack {
            Color.iceBlue
            Text("iceBlue").foregroundStyle(.white)
        }
        ZStack {
            Color.coralRed
            Text("coralRed").foregroundStyle(.white)
        }
        ZStack {
            Color.sunsetOrange
            Text("sunsetOrange").foregroundStyle(.white)
        }
        ZStack {
            Color.seafoamGreen
            Text("seafoamGreen").foregroundStyle(.white)
        }
        ZStack {
            Color.sandBeige
            Text("sandBeige").foregroundStyle(.white)
        }
    }
}
