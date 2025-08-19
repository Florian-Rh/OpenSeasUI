//
//  File.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 19.08.25.
//

import Foundation

extension CGPoint {
    public static func random(in frame: CGRect) -> Self {
        .init(
            x: CGFloat.random(in: frame.minX...frame.maxX),
            y: CGFloat.random(in: frame.minY...frame.maxY)
        )
    }

    public static func random(in frame: CGRect, using generator: inout some RandomNumberGenerator) -> Self {
        .init(
            x: CGFloat.random(in: frame.minX...frame.maxX, using: &generator),
            y: CGFloat.random(in: frame.minY...frame.maxY, using: &generator)
        )
    }
}
