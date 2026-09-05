//
//  OverlapRemovalRefiner.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/24/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

class OverlapRemovalRefiner: Refiner {
    override public func refine(text: String, results: [ParsedResult], opt: [OptionType: Int]) throws -> [ParsedResult] {
        let resultsLength = results.count
        if resultsLength < 2 { return results }
        
        var filteredResults = [ParsedResult]()
        var previousResult: ParsedResult = results[0]
        
        var i = 1
        while i < resultsLength {
            let result = results[i]
            
            // If overlap, compare the length and discard the shorter one
            let previousTextLength = previousResult.text.utf16.count
            if result.index < previousResult.index + previousTextLength {
                if result.text.utf16.count > previousTextLength {
                    previousResult = result
                }
            } else {
                filteredResults.append(previousResult)
                previousResult = result
            }
            i += 1
        }
        
        // The last one
        filteredResults.append(previousResult)
        
        return filteredResults
    }
}
