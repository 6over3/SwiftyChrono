// Derived from SwiftyChrono. Copyright © 2017 Potix. MIT license.
public enum ComponentUnit {
    case year, month, day, hour, minute, second, millisecond, weekday, meridiem
}

public enum TagUnit { case
    none,
    enCasualTimeParser,
    enCasualDateParser,
    enDeadlineFormatParser,
    enISOFormatParser,
    enMonthNameLittleEndianParser,
    enMonthNameMiddleEndianParser,
    enMonthNameParser,
    relativePeriodParser,
    enSlashDateFormatParser,
    enSlashDateFormatStartWithYearParser,
    enSlashMonthFormatParser,
    enTimeAgoFormatParser,
    enTimeExpressionParser,
    enWeekdayParser,
    
    esCasualDateParser,
    esDeadlineFormatParser,
    esMonthNameLittleEndianParser,
    esSlashDateFormatParser,
    esTimeAgoFormatParser,
    esTimeExpressionParser,
    esWeekdayParser,

    caCasualDateParser,
    caDeadlineFormatParser,
    caMonthNameLittleEndianParser,
    caSlashDateFormatParser,
    caTimeAgoFormatParser,
    caTimeExpressionParser,
    caWeekdayParser,

    frCasualDateParser,
    frDeadlineFormatParser,
    frMonthNameLittleEndianParser,
    frSlashDateFormatParser,
    frTimeAgoFormatParser,
    frTimeExpressionParser,
    frWeekdayParser,
    
    jpCasualDateParser,
    jpStandardParser,
    
    deCasualTimeParser,
    deCasualDateParser,
    deDeadlineFormatParser,
    deMonthNameLittleEndianParser,
    deSlashDateFormatParser,
    deTimeAgoFormatParser,
    deTimeExpressionParser,
    deWeekdayParser,
    deMorgenTimeParser,
    
    zhHantDateParser,
    zhHantDeadlineFormatParser,
    zhHantAgoFormatParser,
    zhHantTimeExpressionParser,
    zhHantWeekdayParser,
    zhHantRelationWeekdayParser,

    zhHansDateParser,
    zhHansDeadlineFormatParser,
    zhHansAgoFormatParser,
    zhHansTimeExpressionParser,
    zhHansWeekdayParser,
    zhHansRelationWeekdayParser,

    ruCasualTimeParser,
    ruCasualDateParser,
    ruDeadlineFormatParser,
    ruMonthNameLittleEndianParser,
    ruMonthNameParser,
    ruSlashDateFormatParser,
    ruTimeAgoFormatParser,
    ruTimeExpressionParser,
    ruWeekdayParser,

    extractTimeZoneRefiner,
    forwardDateRefiner,
    
    enMergeDateAndTimeRefiner,
    dateRangeRefiner,
    dateContextRefiner,
    
    frMergeDateAndTimeRefiner,
    
    deMergeDateAndTimeRefiner,

    ruMergeDateAndTimeRefiner
}
