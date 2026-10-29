import SwiftUI
import SwiftData

struct BudgetsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Budget.categoryRaw) private var budgets: [Budget]
    @Query private var transactions: [LedgerEntry]
    @State private var showAdd = false

    private func spent(in category: TxCategory) -> Double {
        transactions
            .filter { !$0.isIncome && $0.category == category && $0.date.isSameMonth(as: .now) }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(budgets) { budget in
                        BudgetCard(budget: budget, spent: spent(in: budget.category))
                            .contextMenu {
                                Button("Delete budget", role: .destructive) {
                                    context.delete(budget)
                                }
                            }
                    }
                    if budgets.isEmpty {
                        ContentUnavailableView("No budgets yet", systemImage: "chart.pie", description: Text("Set a monthly limit for a category."))
                            .padding(.top, 60)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .background(Theme.background)
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus.circle.fill") }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddBudgetView(existing: Set(budgets.map(\.category)))
                    .presentationDetents([.medium])
            }
        }
    }
}

struct BudgetCard: View {
    let budget: Budget
    let spent: Double

    private var progress: Double { budget.limit > 0 ? spent / budget.limit : 0 }
    private var tint: Color {
        switch progress {
        case ..<0.75: budget.category.color
        case ..<1.0: .orange
        default: Theme.expense
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                CategoryIcon(category: budget.category, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(budget.category.title)
                        .font(.system(.headline, design: .rounded))
                    Text("\(spent.currencyCompact) of \(budget.limit.currencyCompact)")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(Int(min(progress, 9.99) * 100))%")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(tint)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(tint.opacity(0.15))
                    Capsule().fill(tint)
                        .frame(width: max(8, geo.size.width * min(progress, 1)))
                }
            }
            .frame(height: 10)
            .animation(.spring(duration: 0.6), value: progress)

            if progress >= 1 {
                Label("Over budget by \((spent - budget.limit).currency)", systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.expense)
            } else {
                Text("\((budget.limit - spent).currency) left")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .card()
    }
}

struct AddBudgetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let existing: Set<TxCategory>

    @State private var category: TxCategory = .groceries
    @State private var limitText = ""

    private var available: [TxCategory] { TxCategory.spending.filter { !existing.contains($0) } }

    var body: some View {
        NavigationStack {
            Form {
                if available.isEmpty {
                    Text("Every category already has a budget.")
                } else {
                    Picker("Category", selection: $category) {
                        ForEach(available) { Text($0.title).tag($0) }
                    }
                    TextField("Monthly limit", text: $limitText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let limit = Double(limitText.replacingOccurrences(of: ",", with: ".")), limit > 0 {
                            context.insert(Budget(category: category, limit: limit))
                            dismiss()
                        }
                    }
                    .disabled(available.isEmpty)
                }
            }
            .onAppear { if let first = available.first { category = first } }
        }
    }
}
