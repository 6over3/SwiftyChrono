//
//  RUMergeDateRangeRefiner.swift
//  SwiftyChrono
//
//  Created by Nickolay Truhin on 06.04.2021.
//

import Foundation

class RUMergeDateRangeRefiner: MergeDateRangeRefiner {
    override var language: Language { .russian }
    override var PATTERN: String { "^\\s*(до|\\-)\\s*$" }
    override var TAGS: TagUnit { .ruMergeDateRangeRefiner }
}
