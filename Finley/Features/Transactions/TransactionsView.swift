import SwiftUI
import SwiftData

struct TransactionsView: View {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "All", income = "Income", expenses = "Expenses"
        var id: String { rawValue }
    }

    @Environment(\.modelContext) private var context
    @Query(sort: \LedgerEntry.date, order: .reverse) private var transactions: [LedgerEntry]
    @State private var filter: Filter = .all
    @State private var search = ""

    private var filtered: [LedgerEntry] {
        transactions.filter { tx in
            switch filter {
            case .all: true
            case .income: tx.isIncome
            case .expenses: !tx.isIncome
            }
        }
        .filter { search.isEmpty || $0.title.localizedCaseInsensitiveContains(search) }
    }

    private var grouped: [(day: Date, items: [LedgerEntry])] {
        Dictionary(grouping: filtered) { $0.date.startOfDay }
            .map { (day: $0.key, items: $0.value) }
            .sorted { $0.day > $1.day }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Filter", selection: $filter) {
                        ForEach(Filter.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                ForEach(grouped, id: \.day) { group in
                    Section {
                        ForEach(group.items) { tx in
                            TransactionRow(transaction: tx)
                                .padding(.vertical, 4)
                        }
                        .onDelete { offsets in
                            for index in offsets { context.delete(group.items[index]) }
                        }
                    } header: {
                        Text(group.day, format: .dateTime.weekday(.wide).day().month())
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Activity")
            .searchable(text: $search, prompt: "Search transactions")
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView("No transactions", systemImage: "tray", description: Text("Tap + to add your first one."))
                }
            }
            .safeAreaPadding(.bottom, 60)
        }
    }
}
