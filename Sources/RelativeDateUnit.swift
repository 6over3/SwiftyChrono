import Foundation

enum RelativeDateUnit {
  case second, minute, hour, day, week, month, year

  /// Called only for the unit capture admitted by the corresponding language grammar.
  init(text: String, language: Language) throws {
    let stems: [(String, Self)]
    switch language {
    case .english:
      stems = [
        ("second", .second), ("min", .minute), ("hour", .hour), ("day", .day),
        ("week", .week), ("month", .month), ("year", .year),
      ]
    case .french:
      stems = [
        ("second", .second), ("min", .minute), ("heure", .hour), ("jour", .day),
        ("semaine", .week), ("mois", .month), ("an", .year),
      ]
    case .german:
      stems = [
        ("sekund", .second), ("minut", .minute), ("stund", .hour), ("tag", .day),
        ("woch", .week), ("monat", .month), ("jahr", .year),
      ]
    case .spanish:
      stems = [
        ("segund", .second),
        ("minut", .minute), ("hora", .hour), ("día", .day), ("dia", .day),
        ("semana", .week), ("mes", .month), ("año", .year),
      ]
    case .catalan:
      stems = [
        ("segon", .second),
        ("minut", .minute), ("hor", .hour), ("di", .day), ("setman", .week),
        ("mes", .month), ("any", .year),
      ]
    case .russian:
      stems = [
        ("секунд", .second), ("минут", .minute), ("час", .hour), ("дн", .day),
        ("день", .day), ("недел", .week), ("месяц", .month), ("год", .year), ("лет", .year),
      ]
    case .chinese, .chineseSimplified:
      stems = [
        ("秒", .second), ("分", .minute), ("小", .hour), ("鐘", .hour), ("钟", .hour),
        ("日", .day), ("天", .day), ("星", .week), ("禮", .week), ("礼", .week),
        ("周", .week), ("週", .week), ("月", .month), ("年", .year),
      ]
    case .japanese:
      stems = [
        ("秒", .second), ("分", .minute), ("時", .hour), ("日", .day),
        ("週", .week), ("月", .month), ("か月", .month), ("ヶ月", .month),
        ("ケ月", .month), ("箇月", .month), ("年", .year),
      ]
    case .neutral: throw ChronoError.invalidDate
    }
    let value = text.lowercased()
    guard let unit = stems.first(where: { value.hasPrefix($0.0) })?.1
    else { throw ChronoError.invalidDate }
    self = unit
  }

  var calendarComponent: Calendar.Component {
    switch self {
    case .second: return .second
    case .minute: return .minute
    case .hour: return .hour
    case .day: return .day
    case .week: return .weekOfYear
    case .month: return .month
    case .year: return .year
    }
  }
}
