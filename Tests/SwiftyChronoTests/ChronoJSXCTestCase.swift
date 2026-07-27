//
//  ChronoJSXCTestCase.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 2/6/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import XCTest
import JavaScriptCore
@testable import SwiftyChrono

public protocol ChronoJSTestable {
    func evalJS(_ script: String, fileName: String)
}

public class ChronoJSXCTestCase: XCTestCase, ChronoJSTestable {
    
    let jsContext = JSContext()!
    let chrono = Chrono()
    var testTitle = ""
    
    /// we assign each js call from chrono parse to those variables, so the value while test fail occur will be the corresponding value
    var lastResultsForFailCase: [ParsedResult] = []
    var lastTextForFailCase: String = ""
    // current fail test in JS test file within same text source
    var nthTest = 0
    // used to calculate diff of [nthTest]
    var _lastText = ""
    
    public func evalJS(_ script: String, fileName: String) {
        print("start to test: \(fileName)")
        jsContext.evaluateScript(script)
    }
    
    override public func setUp() {
        super.setUp()
        
        Chrono.preferredLanguage = nil
        
        /// Handle Error
        jsContext.exceptionHandler = { context, exception in
            let stacktrace = exception?.objectForKeyedSubscript("stack").toString()
            let lineNumber = exception?.objectForKeyedSubscript("line").toString()
            let column = exception?.objectForKeyedSubscript("column")
            
            assertionFailure("error: \(String(describing: exception?.description))\n stack trace: \(String(describing: stacktrace))\n line number: \(lineNumber ?? "") \ncolumn: \(String(describing: column))")
        }
        
        /// register classs to js context
        //jsContext.setObject(TestParsedResult.self, forKeyedSubscript: "ParsedResult" as (NSCopying & NSObjectProtocol)!)
        //jsContext.setObject(TestParsedComponents.self, forKeyedSubscript: "ParsedComponents" as (NSCopying & NSObjectProtocol)!)
        
        /// set function callbacks
        //  setTestTitle(title: String)
        let setTestTitle: @convention(block) (String) -> Void = { title in
            self.testTitle = title
        }
        jsContext.setObject(unsafeBitCast(setTestTitle, to: AnyObject.self), forKeyedSubscript: "setTestTitle" as (NSCopying & NSObjectProtocol))
        
        /// set function callbacks
        //  clearTestTitle()
        let clearTestTitle: @convention(block) () -> Void = { () in
            self.testTitle = ""
        }
        jsContext.setObject(unsafeBitCast(clearTestTitle, to: AnyObject.self), forKeyedSubscript: "clearTestTitle" as (NSCopying & NSObjectProtocol))
        
        /// set function callbacks
        //  ok(passed: Bool, message: String)
        let ok: @convention(block) (Bool, String?) -> Void = { (passed, message) in
            if self._lastText != self.lastTextForFailCase {
                self._lastText = self.lastTextForFailCase
                self.nthTest = 1
            } else {
                self.nthTest += 1
            }
            
            if !passed {
                print("the \(self.nthTest) case of text:\"\(self.lastTextForFailCase)\", results: \(String(describing: self.lastResultsForFailCase.first?.start.date))")
            }
            
            if let message = message {
                XCTAssert(passed, message)
            } else {
                XCTAssert(passed)
            }
        }
        jsContext.setObject(unsafeBitCast(ok, to: AnyObject.self), forKeyedSubscript: "ok" as (NSCopying & NSObjectProtocol))
        
        func chrono(forMode mode: String) -> Chrono {
            switch mode {
            case "strict": return Chrono.strict
            case "casual": return Chrono.casual
            default: return self.chrono
            }
        }

        /// set function callbacks
        //  chronoParse()
        let chronoParse: @convention(block) (String, NSDate, NSDictionary, String) -> NSArray = { (text, ref, opt, mode) -> NSArray in
            let chrono = chrono(forMode: mode)
            self.lastTextForFailCase = text
            
            var opts = [OptionType: Int]()
            for o in opt {
                opts[OptionType(rawValue: o.key as! String)!] = o.value as? Int ?? 1
            }
            
            let parseResults = chrono.parse(text: text, refDate: ref as Date, opt: opts)
            let results = parseResults.map{ TestParsedResult($0) }
            self.lastResultsForFailCase = parseResults
            return results as NSArray
        }
        jsContext.setObject(unsafeBitCast(chronoParse, to: AnyObject.self), forKeyedSubscript: "chronoParse" as (NSCopying & NSObjectProtocol))
        
        /// set function callbacks
        //  chronoParseDate()
        let chronoParseDate: @convention(block) (String, NSDate, NSDictionary, String) -> NSDate = { (text, ref, opt, mode) in
            let chrono = chrono(forMode: mode)
            self.lastTextForFailCase = text
            
            var opts = [OptionType: Int]()
            for o in opt {
                opts[OptionType(rawValue: o.key as! String)!] = o.value as? Int ?? 1
            }
            
            //return (self.chrono.parseDate(text: text, refDate: ref as Date, opt: opts) ?? Date()) as NSDate
            // for debugging, we get the raw parse result and get the first start date.
            // make sure this logic didn't change in chrono's parseDate()
            let results = chrono.parse(text: text, refDate: ref as Date, opt: opts)
            self.lastResultsForFailCase = results
            return (results.first?.start.date ?? Date()) as NSDate
            
        }
        jsContext.setObject(unsafeBitCast(chronoParseDate, to: AnyObject.self), forKeyedSubscript: "chronoParseDate" as (NSCopying & NSObjectProtocol))
        
        
        /// expose test() at the top scope for using objectForKeyedSubscript
        jsContext.evaluateScript(
            "test = function(title, testFunc) {" +
                "    setTestTitle(title);" +
                "    testFunc();" +
                "    clearTestTitle();" +
            "};"
        )
        
        /// expose test() at the top scope for using objectForKeyedSubscript
        jsContext.evaluateScript(
            "chrono = {" +
                "    parse: function(text, ref, opt) {" +
                "        return chronoParse(text, ref, opt);" +
                "    }," +
                "    parseDate: function(text, ref, opt) {" +
                "        return chronoParseDate(text, ref, opt);" +
                "    }," +
                "    strict: {" +
                "        parse: function(text, ref, opt) {" +
                "            return chronoParse(text, ref, opt, 'strict');" +
                "        }," +
                "        parseDate: function(text, ref, opt) {" +
                "            return chronoParseDate(text, ref, opt, 'strict');" +
                "        }" +
                "    }," +
                "    casual: {" +
                "        parse: function(text, ref, opt) {" +
                "            return chronoParse(text, ref, opt, 'casual');" +
                "        }," +
                "        parseDate: function(text, ref, opt) {" +
                "            return chronoParseDate(text, ref, opt, 'casual');" +
                "        }" +
                "    }" +
            "};"
        )

        /// test helpers matching chrono.js test/test_util.ts, so upstream
        /// test cases can be ported near-verbatim
        jsContext.evaluateScript(
            "testSingleCase = function(c, text, arg1, arg2, arg3) {" +
            "    var ref = new Date(), opt = {}, check = null;" +
            "    if (typeof arg1 === 'function') {" +
            "        check = arg1;" +
            "    } else if (arg1 instanceof Date) {" +
            "        ref = arg1;" +
            "        if (typeof arg2 === 'function') { check = arg2; }" +
            "        else { opt = arg2 || {}; check = arg3; }" +
            "    } else {" +
            "        opt = arg1 || {};" +
            "        check = arg2;" +
            "    }" +
            "    var results = c.parse(text, ref, opt);" +
            "    ok(results.length == 1, 'testSingleCase: \"' + text + '\" => ' + results.length + ' results');" +
            "    if (results.length == 1 && check) { check(results[0], text); }" +
            "};" +
            "testUnexpectedResult = function(c, text, ref, opt) {" +
            "    var results = c.parse(text, ref || new Date(), opt || {});" +
            "    ok(results.length == 0, 'testUnexpectedResult: \"' + text + '\" => ' + results.length + ' results');" +
            "};" +
            "testWithExpectedDate = function(c, text, expectedDate) {" +
            "    testSingleCase(c, text, function(result) {" +
            "        ok(Math.abs(result.start.date().getTime() - expectedDate.getTime()) < 100000," +
            "           'testWithExpectedDate: \"' + text + '\" => ' + result.start.date());" +
            "    });" +
            "};"
        )
    }
}
