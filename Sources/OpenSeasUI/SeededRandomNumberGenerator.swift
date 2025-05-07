//
//  File.swift
//  OpenSeasUI
//
//  Created by Florian Rhein on 02.05.25.
//

import Foundation

class SeededRandomNumberGenerator: RandomNumberGenerator, ObservableObject {
    
    init(seed: Int) {
        srand48(seed)
    }

    func next() -> UInt64 {
//        let randomDouble: Double = drand48()
//        print(randomDouble)
        return UInt64(drand48() * Double(UInt64.max))
//        return withUnsafeBytes(of: drand48()) { bytes in
//            bytes.load(as: UInt64.self)
//        }
    }
}
