//
//  TestZH.swift
//  SwiftyChrono
//
//  Tests for the combined ZH configuration and the Hans/Hant split,
//  ported from chrono.js test/zh/zh.test.ts plus Swift-only checks.
//

import Foundation
import XCTest
import JavaScriptCore
@testable import SwiftyChrono

class TestZH: ChronoJSXCTestCase {
    override func tearDown() {
        Chrono.preferredLanguage = nil
        super.tearDown()
    }

    func testExample() {
        Chrono.sixMinutesFixBefore1900 = true

        let fileName = "test_zh"
        let url = Bundle.module.url(forResource: fileName, withExtension: "js", subdirectory: "JS/zh")!
        let js = try! String(contentsOf: url)
        evalJS(js, fileName: fileName)
    }

    // 2012-08-10 12:00 (JS-compatible init: month is 0 ~ 11)
    private let ref = Date(2012, 7, 10, 12)

    func testScriptSpecificParserTags() {
        let hans = Chrono.casual.parse("后天", ref)
        XCTAssertEqual(hans.count, 1)
        XCTAssertEqual(hans.first?.start[.day], 12)
        XCTAssertEqual(hans.first?.tags[.zhHansCasualDateParser], true)

        let hant = Chrono.casual.parse("後天", ref)
        XCTAssertEqual(hant.count, 1)
        XCTAssertEqual(hant.first?.start[.day], 12)
        XCTAssertEqual(hant.first?.tags[.zhHantCasualDateParser], true)
    }

    func testScriptNeutralTextYieldsSingleResult() {
        // 今天 matches both the Hans and Hant parsers; overlap removal
        // must collapse the duplicate into one result.
        let results = Chrono.casual.parse("今天", ref)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.start[.day], 10)
    }

    func testPreferredLanguageChineseFallsBackToSimplified() {
        // .chinese selects only the ZHHant* parsers in the preferred phase;
        // simplified-only input parses through the second-phase fallback
        // (Chrono.parse runs all other parsers when the preferred phase
        // produced no result).
        Chrono.preferredLanguage = .chinese

        let hans = Chrono.casual.parse("后天", ref)
        XCTAssertEqual(hans.first?.start[.day], 12)

        let hant = Chrono.casual.parse("後天", ref)
        XCTAssertEqual(hant.first?.start[.day], 12)
    }

    func testPreferredLanguageSimplified() {
        Chrono.preferredLanguage = .chineseSimplified

        let results = Chrono.casual.parse("后天", ref)
        XCTAssertEqual(results.first?.start[.day], 12)
    }
}
