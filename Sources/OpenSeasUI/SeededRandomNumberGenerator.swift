//
//  File.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 02.05.25.
//

import Foundation

public class SeededRandomNumberGenerator: RandomNumberGenerator {
    public init(seed: Int) {
        srand48(seed)
    }

    public func next() -> UInt64 {
        return UInt64(drand48() * Double(UInt64.max))
    }
}
