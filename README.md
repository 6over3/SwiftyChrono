# SwiftyChrono — 6over3 fork

A deterministic natural-language date parser in Swift, derived from
[quire-io/SwiftyChrono](https://github.com/quire-io/SwiftyChrono), itself a port of
[chrono.js](https://github.com/wanasit/chrono). MIT license; see LICENSE.

## Explicit query context

This fork requires the caller to capture the reference instant and civil calendar.
It never substitutes the process's current date, calendar, or time zone during
parsing. The supplied calendar must be Gregorian; its time zone and week settings
travel with every intermediate date and parsed component.

```swift
import Foundation
import SwiftyChrono

func parsedDates(
    in text: String,
    reference: Date,
    calendar: Calendar
) throws -> [Date] {
    let parser = Chrono()
    let results = try parser.parse(
        text: text,
        refDate: reference,
        calendar: calendar
    )
    return try results.map { try $0.start.date.instant }
}
```

Use `Chrono(strict: true)` for the inherited strict grammar mode. The parser's
language tags describe which grammars contributed to a result; callers must
still decide which languages are admissible for their query. This fork does not
provide general language understanding or equivalent date coverage in every language.

## Result and error contracts

- `ParsedResult.index` is a UTF-16 offset into the original input, matching
  `NSRegularExpression`. Convert it with `Range(NSRange(...), in: text)`;
  do not interpret it as a Character or UTF-8 offset.
- `ParsedComponents` retains known versus implied fields and the captured calendar.
  A date-only expression uses a civil-noon anchor; callers can derive its calendar
  interval from field certainty.
- `try components.date` returns a `ChronoDate` containing both the instant and
  its effective calendar. An explicitly parsed zone overrides the captured zone.
- Invalid civil components and nonexistent wall times are not silently rolled
  into a different date. Calendar-day shifts carry month/year rollover.
- Source-coordinate and calendar errors throw instead of fabricating a reference
  date or continuing with a different time zone.
- Regex extraction and slicing use one UTF-16 coordinate contract, including
  preceding-character checks at the beginning of input and beside emoji.

The previous global preferred-language/implied-time switches, static shared
parser instances, and implicit-reference `parseDate` API are removed. Callers
must use explicit context. There is no compatibility adapter.

## Dependency

Use `https://github.com/6over3/SwiftyChrono.git` as a Swift package dependency and
pin an exact reviewed revision. Do not vendor the source tree into the application.

## Verification boundary

Production-source compilation is checked separately from runtime behavior. The
inherited tests have not been updated to the explicit-context API or run as part
of this patch. Temporal ambiguity (including repeated DST wall times), grammar
coverage, and caller-specific interval composition require further validation;
a successful build does not establish those behaviors.
