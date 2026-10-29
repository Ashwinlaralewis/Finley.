import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var isIncome = false
    @State private var amountText = ""
    @State private var title = ""
    @State private var category: TxCategory = .groceries
    @State private var date = Date.now
    @State private var saved = false
    @FocusState private var amountFocused: Bool

    private var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }
    private var canSave: Bool {
        guard let amount else { return false }
        return amount > 0 && !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    private var categories: [TxCategory] {
        isIncome ? [.salary, .other] : TxCategory.spending
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Picker("Type", selection: $isIncome) {
                        Text("Expense").tag(false)
                        Text("Income").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: isIncome) { _, newValue in
                        category = newValue ? .salary : .groceries
                    }

                    VStack(spacing: 6) {
                        Text("Amount").font(.footnote).foregroundStyle(.secondary)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(isIncome ? Theme.income : Theme.expense)
                            .focused($amountFocused)
                    }
                    .frame(maxWidth: .infinity)
                    .card()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category").font(.headline)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                            ForEach(categories) { cat in
                                Button {
                                    category = cat
                                } label: {
                                    VStack(spacing: 6) {
                                        CategoryIcon(category: cat, size: 46)
                                        Text(cat.title).font(.caption2).lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(category == cat ? cat.color : .clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .card()

                    VStack(spacing: 14) {
                        TextField("Title (e.g. Coffee)", text: $title)
                            .textInputAutocapitalization(.sentences)
                        Divider()
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }
                    .card()

                    Button(action: save) {
                        Text("Save")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSave ? AnyShapeStyle(Theme.heroGradient) : AnyShapeStyle(Color.gray.opacity(0.4)),
                                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(!canSave)
                    .sensoryFeedback(.success, trigger: saved)
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("New transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { amountFocused = true }
        }
    }

    private func save() {
        guard let amount, canSave else { return }
        let tx = LedgerEntry(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amount,
            isIncome: isIncome,
            category: category,
            date: date
        )
        context.insert(tx)
        try? context.save()
        saved.toggle()
        dismiss()
    }
}
