//
//  UnlikelyFormatFilter.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/24/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "^\\d*(\\.\\d*)?$"
private let regex = try! NSRegularExpression(pattern: PATTERN, options: NSRegularExpression.Options.caseInsensitive)

class UnlikelyFormatFilter: Filter {
    override func isValid(text: String, result: ParsedResult, opt: [OptionType: Int]) throws -> Bool {
        let textToMatch = result.text.replacingOccurrences(of: " ", with: "")
        return regex.firstMatch(in: textToMatch, range: NSRange(location: 0, length: textToMatch.utf16.count)) == nil
    }
}
