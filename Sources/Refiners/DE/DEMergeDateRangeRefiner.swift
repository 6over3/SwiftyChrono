//
//  DEMergeDateRangeRefiner.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/16/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

class DEMergeDateRangeRefiner: MergeDateRangeRefiner {
    override var language: Language { .german }
    override var PATTERN: String { return "^\\s*(bis|\\-)\\s*$" }
    override var TAGS: TagUnit { return .deMergeDateRangeRefiner }
}
