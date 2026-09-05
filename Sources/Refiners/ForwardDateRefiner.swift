//
//  ForwardDateRefiner.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/24/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

class ForwardDateRefiner: Refiner {
    override public func refine(text: String, results: [ParsedResult], opt: [OptionType: Int]) throws -> [ParsedResult] {
        if !opt.keys.contains(.forwardDate) && !opt.keys.contains(.forwardDate) {
            return results
        }
        
        let resultsLength = results.count
        var newResults = [ParsedResult]()
        
        var i = 0
        while i < resultsLength {
            var result = results[i]
            var refMoment = result.ref
            
            if try result.start.isCertain(component: .day) && result.start.isCertain(component: .month) &&
                !result.start.isCertain(component: .year) && refMoment.isAfter((try result.start.date)) {
                // Adjust year into the future
                for _ in 0..<3 {
                    if try !refMoment.isAfter((result.start.date)) {
                        break
                    }
                    
                    result.start.imply(.year, to: result.start[.year]! + 1)
                    if result.end != nil && !result.end!.isCertain(component: .year) {
                        result.end!.imply(.year, to: result.end![.year]! + 1)
                    }
                }
                
                result.tags[.forwardDateRefiner] = true
            }
            
            if try !result.start.isCertain(component: .day) && !result.start.isCertain(component: .month) &&
                !result.start.isCertain(component: .year) && result.start.isCertain(component: .weekday) &&
                refMoment.isAfter((try result.start.date))
            {
                // Adjust date to the coming week
                let weekday = result.start[.weekday]!
                refMoment = try refMoment.setOrAdded(refMoment.weekday > weekday ? weekday + 7 : weekday, .weekday)
                
                result.start.imply(.day, to: refMoment.day)
                result.start.imply(.month, to: refMoment.month)
                result.start.imply(.year, to: refMoment.year)
                result.tags[.forwardDateRefiner] = true
            }
            
            newResults.append(result)
            i += 1
        }
        
        return newResults
    }
}
