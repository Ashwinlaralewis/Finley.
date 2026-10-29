import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query private var transactions: [LedgerEntry]

    private struct Slice: Identifiable {
        let category: TxCategory
        let total: Double
        var id: String { category.rawValue }
    }

    private var thisMonth: [LedgerEntry] { transactions.filter { $0.date.isSameMonth(as: .now) } }
    private var lastMonth: [LedgerEntry] {
        let prev = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
        return transactions.filter { $0.date.isSameMonth(as: prev) }
    }

    private func spend(_ list: [LedgerEntry]) -> Double {
        list.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    private func income(_ list: [LedgerEntry]) -> Double {
        list.filter(\.isIncome).reduce(0) { $0 + $1.amount }
    }

    private var slices: [Slice] {
        Dictionary(grouping: thisMonth.filter { !$0.isIncome }, by: \.category)
            .map { Slice(category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    private var totalSpent: Double { spend(thisMonth) }
    private var savingsRate: Double {
        let inc = income(thisMonth)
        return inc > 0 ? max(0, (inc - totalSpent) / inc) : 0
    }
    private var monthChange: Double? {
        let prev = spend(lastMonth)
        guard prev > 0 else { return nil }
        return (totalSpent - prev) / prev
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    donut
                    statGrid
                    topCategories
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .background(Theme.background)
            .navigationTitle("Insights")
        }
    }

    private var donut: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Spending this month")
            if slices.isEmpty {
                Text("No spending recorded yet.").foregroundStyle(.secondary)
            } else {
                Chart(slices) { slice in
                    SectorMark(
                        angle: .value("Spent", slice.total),
                        innerRadius: .ratio(0.62),
                        angularInset: 2
                    )
                    .cornerRadius(6)
                    .foregroundStyle(slice.category.color)
                }
                .frame(height: 220)
                .chartBackground { _ in
                    VStack(spacing: 2) {
                        Text("Total").font(.caption).foregroundStyle(.secondary)
                        Text(totalSpent.currencyCompact)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                    }
                }
            }
        }
        .card()
    }

    private var statGrid: some View {
        HStack(spacing: 14) {
            statTile(
                title: "Savings rate",
                value: "\(Int(savingsRate * 100))%",
                symbol: "leaf.fill",
                color: Theme.income
            )
            statTile(
                title: "vs last month",
                value: monthChange.map { String(format: "%+.0f%%", $0 * 100) } ?? "–",
                symbol: (monthChange ?? 0) > 0 ? "arrow.up.right" : "arrow.down.right",
                color: (monthChange ?? 0) > 0 ? Theme.expense : Theme.income
            )
        }
    }

    private func statTile(title: String, value: String, symbol: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.14), in: Circle())
            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))
            Text(title).font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private var topCategories: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Top categories")
            VStack(spacing: 14) {
                ForEach(slices.prefix(4)) { slice in
                    HStack(spacing: 12) {
                        CategoryIcon(category: slice.category, size: 38)
                        Text(slice.category.title).font(.system(.body, design: .rounded, weight: .medium))
                        Spacer()
                        Text(slice.total.currency)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .monospacedDigit()
                    }
                }
            }
        }
        .card()
    }
}
