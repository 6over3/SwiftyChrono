# Unreleased — 6over3 explicit-context fork

* Require a captured reference instant and Gregorian civil calendar for parsing.
* Carry calendar/time-zone context through arithmetic and parsed endpoints.
* Replace global date configuration and implicit reference dates with explicit APIs.
* Unify regex and source coordinates as UTF-16, including Unicode boundaries.
* Propagate date/source errors and preserve month/year rollover in calendar-day shifts.
* Split parsed values, date arithmetic, and component units into focused files.
* Production sources compile; inherited tests are not updated or executed in this patch.

# 2.0.0

* Swift 5.10+
* Fully supports Swift Package Manager
* Catalan support (#16, Thanks @hectr)
* Russian support (#18, Thanks @CoolONEOfficial)
* Re-ported the Chinese locale from current chrono.js v2, splitting the ZH parsers into
  Simplified (`ZHHans*`) and Traditional (`ZHHant*`) parser sets
  * New relative-day keywords: 前天 (−2), 大前天 (−3), 后天/後天 (+2), 大后天/大後天 (+3), and 现在
  * New parsers: `ZHHansAgoFormatParser`/`ZHHantAgoFormatParser` (e.g. 三天前, 半小時前) and
    `ZHHansRelationWeekdayParser`/`ZHHantRelationWeekdayParser` (上/下/這/呢/今 + weekday);
    weekday parsing now also accepts 周/週
  * Fixed end-date calculation for ranges where the end names its own day
    (明天3点到后天5点 no longer stacks day offsets)
  * `Language` gains `.chineseSimplified` (the `ZHHans*` parsers); `.chinese` remains the
    Traditional set. With `Chrono.preferredLanguage = .chinese`, simplified-only input still
    parses via the second-phase fallback. New `TagUnit` cases were added (breaks exhaustive
    `switch` over these enums, if any)
  * The old `ZHCasualDateParser`, `ZHDateParser`, `ZHDeadlineFormatParser`,
    `ZHTimeExpressionParser` and `ZHWeekdayParser` classes were replaced by the
    `ZHHant*`/`ZHHans*` classes
  * Replaced the chrono.js-v1-based zh test suites with ports of current upstream `test/zh`

# 1.1.0

* Old release since 2018
