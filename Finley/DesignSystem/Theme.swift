import SwiftUI

enum Theme {
    static let accent = Color(red: 0.36, green: 0.35, blue: 0.95)
    static let accentSoft = Color(red: 0.55, green: 0.40, blue: 0.98)
    static let income = Color(red: 0.16, green: 0.76, blue: 0.48)
    static let expense = Color(red: 0.96, green: 0.33, blue: 0.38)

    static let heroGradient = LinearGradient(
        colors: [accent, accentSoft, Color(red: 0.85, green: 0.35, blue: 0.80)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let background = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
}

// MARK: - Card style

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
}

// MARK: - Formatting

extension Double {
    var currency: String {
        formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    var currencyCompact: String {
        formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
    }
}

extension Date {
    var startOfMonth: Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: self)) ?? self
    }

    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    func isSameMonth(as other: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: other, toGranularity: .month)
    }
}

// MARK: - Reusable components

struct CategoryIcon: View {
    let category: TxCategory
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: category.symbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(category.color)
            .frame(width: size, height: size)
            .background(category.color.opacity(0.14), in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
    }
}

struct TransactionRow: View {
    let transaction: LedgerEntry

    var body: some View {
        HStack(spacing: 14) {
            CategoryIcon(category: transaction.category)
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text(transaction.category.title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text((transaction.isIncome ? "+" : "-") + transaction.amount.currency)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(transaction.isIncome ? Theme.income : .primary)
                .monospacedDigit()
        }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(.title3, design: .rounded, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
