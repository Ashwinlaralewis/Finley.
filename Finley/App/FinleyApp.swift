import SwiftUI
import SwiftData

@main
struct FinleyApp: App {
    @State private var showSplash = true

    let container: ModelContainer = {
        let schema = Schema([LedgerEntry.self, Budget.self])
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .tint(Theme.accent)
                    .task { SeedData.insertIfNeeded(into: container.mainContext) }

                if showSplash {
                    SplashView {
                        showSplash = false
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
        .modelContainer(container)
    }
}
