import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case home, activity, budgets, insights
}

struct RootView: View {
    @State private var selection: AppTab = .home
    @State private var showAdd = false

    var body: some View {
        TabView(selection: $selection) {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppTab.home)

            TransactionsView()
                .tabItem { Label("Activity", systemImage: "list.bullet.rectangle.fill") }
                .tag(AppTab.activity)

            BudgetsView()
                .tabItem { Label("Budgets", systemImage: "chart.pie.fill") }
                .tag(AppTab.budgets)

            InsightsView()
                .tabItem { Label("Insights", systemImage: "sparkles") }
                .tag(AppTab.insights)
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(Theme.heroGradient, in: Circle())
                    .shadow(color: Theme.accent.opacity(0.4), radius: 14, y: 6)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 70)
            .sensoryFeedback(.impact(weight: .medium), trigger: showAdd)
            .accessibilityLabel("Add transaction")
        }
        .sheet(isPresented: $showAdd) {
            AddTransactionView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [LedgerEntry.self, Budget.self], inMemory: true)
}
