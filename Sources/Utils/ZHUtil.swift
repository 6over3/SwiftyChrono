//
//  ZHUtil.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

// ported from chrono.js src/locales/zh/hans/constants.ts
let ZH_HANS_NUMBER = [
    "零": 0,
    "〇": 0,
    "一": 1,
    "二": 2,
    "两": 2,
    "三": 3,
    "四": 4,
    "五": 5,
    "六": 6,
    "七": 7,
    "八": 8,
    "九": 9,
    "十": 10,
]

// ported from chrono.js src/locales/zh/hant/constants.ts
let ZH_HANT_NUMBER = [
    "零": 0,
    "一": 1,
    "二": 2,
    "兩": 2,
    "三": 3,
    "四": 4,
    "五": 5,
    "六": 6,
    "七": 7,
    "八": 8,
    "九": 9,
    "十": 10,
    "廿": 20,
    "卅": 30,
]

let ZH_HANS_NUMBER_PATTERN = "[" + ZH_HANS_NUMBER.keys.joined(separator: "") + "]"
let ZH_HANT_NUMBER_PATTERN = "[" + ZH_HANT_NUMBER.keys.joined(separator: "") + "]"

// WEEKDAY_OFFSET is identical in both scripts
let ZH_WEEKDAY_OFFSET = [
    "天": 0,
    "日": 0,
    "一": 1,
    "二": 2,
    "三": 3,
    "四": 4,
    "五": 5,
    "六": 6,
]

let ZH_WEEKDAY_OFFSET_PATTERN = "(?:" + ZH_WEEKDAY_OFFSET.keys.joined(separator: "|") + ")"

func ZHStringToNumber(text: String, map: [String: Int]) -> Int {
    var number = 0

    for char in text.map({ String($0) }) {
        let n = map[char] ?? 0
        if char == "十" {
            number = number == 0 ? n : number * n
        } else {
            number += n
        }
    }

    return number
}

func ZHStringToYear(text: String, map: [String: Int]) -> Int {
    var string = ""

    for char in text.map({ String($0) }) {
        string += "\(map[char] ?? 0)"
    }

    return Int(string) ?? 0
}
