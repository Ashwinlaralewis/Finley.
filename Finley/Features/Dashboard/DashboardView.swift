import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query(sort: \LedgerEntry.date, order: .reverse) private var transactions: [LedgerEntry]

    private var monthTx: [LedgerEntry] {
        transactions.filter { $0.date.isSameMonth(as: .now) }
    }
    private var income: Double { monthTx.filter(\.isIncome).reduce(0) { $0 + $1.amount } }
    private var spent: Double { monthTx.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount } }
    private var balance: Double { transactions.reduce(0) { $0 + $1.signedAmount } }

    private struct DayPoint: Identifiable {
        let id = UUID()
        let date: Date
        let total: Double
    }

    private var last7Days: [DayPoint] {
        (0..<7).reversed().map { offset in
            let d = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!.startOfDay
            let total = transactions
                .filter { !$0.isIncome && $0.date.startOfDay == d }
                .reduce(0) { $0 + $1.amount }
            return DayPoint(date: d, total: total)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    heroCard
                    weekChart
                    recent
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .background(Theme.background)
            .navigationTitle("Finley")
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Total balance")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
            Text(balance.currency)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack(spacing: 12) {
                pill(title: "Income", value: income, symbol: "arrow.down.left")
                pill(title: "Spent", value: spent, symbol: "arrow.up.right")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Theme.heroGradient, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Theme.accent.opacity(0.35), radius: 20, y: 10)
    }

    private func pill(title: String, value: Double, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.footnote.weight(.bold))
                .frame(width: 30, height: 30)
                .background(.white.opacity(0.2), in: Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption).opacity(0.8)
                Text(value.currencyCompact)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var weekChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Last 7 days")
            Chart(last7Days) { point in
                BarMark(
                    x: .value("Day", point.date, unit: .day),
                    y: .value("Spent", point.total)
                )
                .foregroundStyle(Theme.heroGradient)
                .cornerRadius(6)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 150)
        }
        .card()
    }

    private var recent: some View {
        VStack(spacing: 14) {
            SectionHeader(title: "Recent")
            VStack(spacing: 16) {
                ForEach(transactions.prefix(5)) { tx in
                    TransactionRow(transaction: tx)
                }
            }
            .card()
        }
    }
}
