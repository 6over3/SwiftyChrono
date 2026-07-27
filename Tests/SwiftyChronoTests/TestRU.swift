//
//  TestRU.swift
//  SwiftyChrono
//
//  Ported from PR #18 (https://github.com/quire-io/SwiftyChrono/pull/18) by Nikolai Trukhin.
//

import XCTest
@testable import SwiftyChrono

class TestRU: XCTestCase {
    override func setUp() {
        super.setUp()
        Chrono.preferredLanguage = .russian
    }

    override func tearDown() {
        Chrono.preferredLanguage = nil
        super.tearDown()
    }

    func testRussian() {
        XCTAssertFalse(Chrono().parse(text: "25 Мая").isEmpty)
        XCTAssertFalse(Chrono().parse(text: "Через неделю").isEmpty)
        XCTAssertFalse(Chrono().parse(text: "В следующий понедельник").isEmpty)
        XCTAssertFalse(Chrono().parse(text: "1 февраля").isEmpty)
        XCTAssertFalse(Chrono().parse(text: "Первого февраля").isEmpty)
        XCTAssertFalse(Chrono().parse(text: "Двадцать первого февраля").isEmpty)
        XCTAssertFalse(Chrono().parse(text: "Вторник").isEmpty)
        XCTAssertFalse(Chrono().parse(text: "12:30").isEmpty)
        XCTAssertFalse(Chrono().parse(text: "Завтра в полдень").isEmpty)
        XCTAssertFalse(Chrono().parse(text: "Завтра в 19:30").isEmpty)
    }

    /// Regression cases for crashes confirmed in PR #18's original Russian parsers —
    /// force-unwraps on capture groups the regexes can legitimately leave empty or absent,
    /// and a parser reading number/unit from the wrong capture-group indices. These join
    /// the *default* parser list (not just the Russian one), so they used to crash on any
    /// `Chrono().parse(...)` call, regardless of `preferredLanguage`.
    func testCrashRegressions() {
        // RUMonthNameLittleEndianParser: day captured as an ordinal word ("Первое"),
        // not a number — `Int(...)!` on the whole capture used to crash.
        XCTAssertFalse(Chrono().parse(text: "Первое февраля").isEmpty)

        // RUMonthNameLittleEndianParser: day capture includes the "е" suffix ("25е"),
        // which also isn't `Int`-parseable as-is.
        XCTAssertFalse(Chrono().parse(text: "25е мая").isEmpty)

        // RUMonthNameLittleEndianParser: the regex accepts the abbreviation "Сент", but
        // RU_MONTH_OFFSET only had "сен"/"сен."/"сентября" — `RU_MONTH_OFFSET[...]!` crashed.
        XCTAssertFalse(Chrono().parse(text: "5 сент").isEmpty)

        // RUMonthNameParser: the regex accepts "Мая.", but RU_MONTH_OFFSET lacked that
        // trailing-dot spelling — same forced dictionary lookup crash.
        XCTAssertFalse(Chrono().parse(text: "в мая.").isEmpty)

        // RUTimeAgoFormatParser: number/unit were read from the wrong capture-group
        // indices, so `Int(numberText)!` received the whole phrase ("5 дней ") and crashed.
        XCTAssertFalse(Chrono().parse(text: "5 дней назад").isEmpty)

        // RUTimeExpressionParser: the hour-text check compared against the typo "вечерв"
        // instead of "вечера", so `Int(hourText)!` crashed on the real word "вечера".
        XCTAssertFalse(Chrono().parse(text: "вечера").isEmpty)
    }
}
