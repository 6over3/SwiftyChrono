//
//  FRMergeDateTimeRefiner.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "^\\s*(T|à|a|vers|de|,|-)?\\s*$"

private func isDateOnly(result: ParsedResult) -> Bool {
    return !result.start.isCertain(component: .hour) || result.tags[.frCasualDateParser] != nil
}

private func isTimeOnly(result: ParsedResult) -> Bool {
    return !result.start.isCertain(component: .month) && !result.start.isCertain(component: .weekday)
}

private func isAbleToMerge(text: String, previousResult: ParsedResult, currentResult: ParsedResult) throws -> Bool {
    let (startIndex, endIndex) = sortTwoNumbers(previousResult.index + previousResult.text.utf16.count, currentResult.index)
    
    let textBetween = try text.substring(from: startIndex, to: endIndex)
    return try NSRegularExpression.isMatch(forPattern: PATTERN, in: textBetween)
}

private func mergeResult(refText text: String, dateResult: ParsedResult, timeResult: ParsedResult) throws -> ParsedResult {
    var dateResult = dateResult
    let beginDate = dateResult.start
    let beginTime = timeResult.start
    
    var beginDateTime = beginDate
    if let issue = beginDateTime.applyClock(from: beginTime) { dateResult.issues.append(issue) }
    
    if beginTime.isCertain(component: .meridiem) {
        beginDateTime.assign(.meridiem, value: beginTime[.meridiem]!)
    } else if let meridiem = beginTime[.meridiem], beginDateTime[.meridiem] == nil {
        beginDateTime.imply(.meridiem, to: meridiem)
    }
    
    if
        let meridiem = beginDateTime[.meridiem], meridiem == 1,
        let hour = beginDateTime[.hour], hour < 12
    {
        beginDateTime.assign(.hour, value: hour + 12)
    }
    
    if dateResult.end != nil || timeResult.end != nil {
        let endDate = dateResult.end ?? dateResult.start
        let endTime = timeResult.end ?? timeResult.start
        
        var endDateTime = endDate
        if let issue = endDateTime.applyClock(from: endTime) { dateResult.issues.append(issue) }
        
        if endTime.isCertain(component: .meridiem) {
            endDateTime.assign(.meridiem, value: endTime[.meridiem]!)
        } else if beginTime[.meridiem] != nil {
            endDateTime.imply(.meridiem, to: endTime[.meridiem])
        }
        
        if dateResult.end == nil && endDateTime.isDefinitelyBefore(beginDateTime) {
            // Ex. 9pm - 1am
            try endDateTime.shiftCalendarDays(1)
        }
        
        dateResult.end = endDateTime
    }
    
    dateResult.start = beginDateTime
    
    let startIndex = min(dateResult.index, timeResult.index)
    let endIndex = max(
        dateResult.index + dateResult.text.utf16.count,
        timeResult.index + timeResult.text.utf16.count)
    
    dateResult.index = startIndex
    dateResult.text = String(text[try text.range(ofStartIndex: startIndex, andEndIndex: endIndex)])
    
    for tag in timeResult.tags.keys {
        dateResult.tags[tag] = true
    }
    dateResult.tags[.frMergeDateAndTimeRefiner] = true
    dateResult.languages.formUnion(timeResult.languages)
    dateResult.languages.insert(.french)
    dateResult.issues += timeResult.issues
    return dateResult
}

class FRMergeDateTimeRefiner: Refiner {
    override var language: Language { .french }
    override public func refine(text: String, results: [ParsedResult], opt: [OptionType: Int]) throws -> [ParsedResult] {
        let resultsLength = results.count
        if resultsLength < 2 { return results }
        
        var mergedResults = [ParsedResult]()
        var currentResult: ParsedResult?
        var previousResult: ParsedResult
        
        
        var i = 1
        while i < resultsLength {
            currentResult = results[i]
            previousResult = results[i-1]
            
            if try isDateOnly(result: previousResult) && isTimeOnly(result: currentResult!) &&
                isAbleToMerge(text: text, previousResult: previousResult, currentResult: currentResult!) {
                
                previousResult = try mergeResult(refText: text, dateResult: previousResult, timeResult: currentResult!)
                currentResult = nil
                i += 1
            } else if try isDateOnly(result: currentResult!) && isTimeOnly(result: previousResult) &&
                isAbleToMerge(text: text, previousResult: previousResult, currentResult: currentResult!) {
                
                previousResult = try mergeResult(refText: text, dateResult: currentResult!, timeResult: previousResult)
                currentResult = nil
                i += 1
            }
            
            mergedResults.append(previousResult)
            i += 1
        }
        
        if let currentResult = currentResult {
            mergedResults.append(currentResult)
        }
        
        return mergedResults
    }
}







