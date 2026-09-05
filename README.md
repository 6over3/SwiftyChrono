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

func parsedExpressions(
    in text: String,
    reference: Date,
    calendar: Calendar,
    languages: Set<Language>
) throws -> [ParsedResult] {
    let parser = Chrono()
    return try parser.parse(
        text: text,
        refDate: reference,
        calendar: calendar,
        languages: languages
    )
}
```

Use `Chrono(strict: true)` for the inherited strict grammar mode. The parser's
typed `languages` describe which grammars contributed to a result. Callers supply
the admissible languages, including `.neutral` for ISO syntax. Admitted grammars
are refined independently so registration order does not choose between languages.
Results may share a source span; consumers retain their distinct interpretations.
This fork does not
provide general language understanding or equivalent date coverage in every language.

Numeric timezone offsets are validated as complete values, including minute
ranges and Foundation's representable offsets. ISO-shaped timestamps are captured
before field validation so a malformed clock or offset cannot become a shorter
valid date. Explicit endpoint offsets are attached before date/range merging and
are not overwritten by a trailing abbreviation. For a date without a clock, use
an explicit UTC/GMT prefix; a bare hyphen remains available for date-range grammar.

Timezone abbreviations still use inherited, incomplete mappings; ambiguity and
historical-offset handling are not yet repaired. Numeric offsets do not imply
that these abbreviations or all date-range grammars are production-validated.

Relative amounts use shared checked arithmetic across the supported offset
grammars. An overflowing number is not one; indefinite quantities are not three;
half is not an integer sentinel. Weeks use calendar addition, and half-month
expressions remain unresolved rather than assuming a 30-day month. Sub-second
relative offsets are reported as unsupported precision.

In the English relative-period grammar, unquantified `last`/`next` names an
adjacent complete calendar period; quantified forms and `past` name a rolling
range ending/starting at the reference instant, captured at second precision.
Range endpoints are inclusive buckets, including the final bucket inside the
period but not the following one. Relative-day words advance/subtract calendar
days regardless of the hour at which the query is made.
Other languages do not yet have equivalent period grammar. Deadline words such
as `within`, day-part meanings, and relative ranges combined with explicit
time zones still need a complete semantic audit; this is not a claim of full
natural-language date coverage.

## Result and error contracts

- `ParsedResult.index` is a UTF-16 offset into the original input, matching
  `NSRegularExpression`. Convert it with `Range(NSRange(...), in: text)`;
  do not interpret it as a Character or UTF-8 offset.
- `ParsedComponents` retains known versus implied fields and the captured calendar.
  A date-only expression uses a civil-noon anchor; callers can derive its calendar
  interval from field certainty.
- `components.dateResolution` returns `.unique`, `.repeated(earlier:later:)`, or
  `.invalid`. Each valid occurrence carries its instant and effective calendar.
  An explicitly parsed zone overrides the captured zone. ISO timestamps without
  a zone use the supplied calendar; they do not silently assume UTC.
- Check `result.issues` before resolving endpoints. Recognized invalid input and
  unsupported precision stay attached to the complete source expression, not a
  fabricated usable date. ISO fractional seconds support up to three digits.
- Invalid civil components and nonexistent wall times are not silently rolled
  into a different date. Calendar-day shifts carry month/year rollover.
- Invalid input stays a typed outcome; invalid supplied context and source-coordinate
  errors throw. Calendar fields are not reordered to make a backwards range valid.
- Regex extraction and slicing use one UTF-16 coordinate contract, including
  preceding-character checks at the beginning of input and beside emoji.

There is no singular date accessor that arbitrarily chooses one repeated clock
time. Callers must handle its occurrences and invalid outcomes explicitly.

## Dependency

Use `https://github.com/6over3/SwiftyChrono.git` as a Swift package dependency and
pin an exact reviewed revision. Do not vendor the source tree into the application.

## Verification boundary

Production-source compilation is checked separately from runtime behavior. The
inherited tests have not been updated to the explicit-context API or run as part
of this patch. Repeated/nonexistent DST wall times, ISO offsets, language grammar
coverage, and caller-specific interval composition still require runtime validation;
a successful build does not establish those behaviors.
