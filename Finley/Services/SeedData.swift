import Foundation
import SwiftData

enum SeedData {
    /// Inserts realistic demo data on first launch only.
    @MainActor
    static func insertIfNeeded(into context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<LedgerEntry>())) ?? 0
        guard existing == 0 else { return }

        let cal = Calendar.current
        let today = Date.now

        func day(_ offset: Int) -> Date {
            cal.date(byAdding: .day, value: -offset, to: today) ?? today
        }

        // (title, amount, category, daysAgo)
        let expenses: [(String, Double, TxCategory, Int)] = [
            ("Tesco Groceries", 54.20, .groceries, 0),
            ("Costa Coffee", 4.60, .dining, 0),
            ("Metro Pass", 18.50, .transport, 1),
            ("Netflix", 10.99, .entertainment, 2),
            ("Sainsbury's", 37.85, .groceries, 3),
            ("Nandos", 22.40, .dining, 3),
            ("Zara", 64.00, .shopping, 4),
            ("Pharmacy", 12.30, .health, 5),
            ("Uber", 14.75, .transport, 6),
            ("Lidl", 29.10, .groceries, 7),
            ("Cinema", 13.50, .entertainment, 8),
            ("Monthly Rent", 650.00, .rent, 9),
            ("Amazon", 42.99, .shopping, 10),
            ("Gym Membership", 24.00, .health, 11),
            ("Pizza Express", 26.80, .dining, 12),
            ("Aldi", 33.45, .groceries, 14),
            ("Train Ticket", 31.20, .transport, 16),
            ("Spotify", 10.99, .entertainment, 18),
            ("H&M", 48.50, .shopping, 20),
            ("Waitrose", 61.30, .groceries, 22),
            ("Monthly Rent", 650.00, .rent, 39),
            ("Tesco Groceries", 71.10, .groceries, 36),
            ("Concert Tickets", 58.00, .entertainment, 33),
            ("Dentist", 45.00, .health, 31),
            ("Black Friday Shopping", 120.00, .shopping, 29)
        ]

        for e in expenses {
            context.insert(LedgerEntry(title: e.0, amount: e.1, isIncome: false, category: e.2, date: day(e.3)))
        }

        context.insert(LedgerEntry(title: "Part-time Salary", amount: 1450.00, isIncome: true, category: .salary, date: day(12)))
        context.insert(LedgerEntry(title: "Part-time Salary", amount: 1450.00, isIncome: true, category: .salary, date: day(42)))
        context.insert(LedgerEntry(title: "Freelance Project", amount: 320.00, isIncome: true, category: .other, date: day(5)))

        let budgets: [(TxCategory, Double)] = [
            (.groceries, 250), (.dining, 120), (.transport, 90),
            (.shopping, 150), (.entertainment, 60), (.health, 80)
        ]
        for b in budgets {
            context.insert(Budget(category: b.0, limit: b.1))
        }

        try? context.save()
    }
}
