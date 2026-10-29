import SwiftUI
import SwiftData

enum TxCategory: String, Codable, CaseIterable, Identifiable {
    case groceries, dining, transport, rent, shopping, entertainment, health, salary, other

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .groceries: "cart.fill"
        case .dining: "fork.knife"
        case .transport: "tram.fill"
        case .rent: "house.fill"
        case .shopping: "bag.fill"
        case .entertainment: "film.fill"
        case .health: "heart.fill"
        case .salary: "banknote.fill"
        case .other: "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .groceries: Color(red: 0.20, green: 0.78, blue: 0.55)
        case .dining: Color(red: 0.98, green: 0.60, blue: 0.20)
        case .transport: Color(red: 0.25, green: 0.60, blue: 0.98)
        case .rent: Color(red: 0.62, green: 0.40, blue: 0.95)
        case .shopping: Color(red: 0.96, green: 0.36, blue: 0.62)
        case .entertainment: Color(red: 0.95, green: 0.30, blue: 0.35)
        case .health: Color(red: 0.15, green: 0.78, blue: 0.80)
        case .salary: Color(red: 0.40, green: 0.80, blue: 0.30)
        case .other: Color(red: 0.55, green: 0.58, blue: 0.65)
        }
    }

    /// Categories that make sense for spending (everything except salary).
    static var spending: [TxCategory] { allCases.filter { $0 != .salary } }
}

@Model
final class LedgerEntry {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double          // always positive
    var isIncome: Bool
    var categoryRaw: String
    var date: Date
    var note: String

    var category: TxCategory {
        get { TxCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    /// Signed amount: income positive, expense negative.
    var signedAmount: Double { isIncome ? amount : -amount }

    init(title: String, amount: Double, isIncome: Bool, category: TxCategory, date: Date = .now, note: String = "") {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.isIncome = isIncome
        self.categoryRaw = category.rawValue
        self.date = date
        self.note = note
    }
}

@Model
final class Budget {
    @Attribute(.unique) var categoryRaw: String
    var limit: Double

    var category: TxCategory {
        get { TxCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(category: TxCategory, limit: Double) {
        self.categoryRaw = category.rawValue
        self.limit = limit
    }
}
