# Finley – personal finance app (SwiftUI, iOS 17+)

Stack: SwiftUI, SwiftData (local-first, offline), Swift Charts, no third-party dependencies.

## Run it (needs a Mac with Xcode 15+)
1. `brew install xcodegen`
2. In this folder: `xcodegen generate`
3. `open Finley.xcodeproj`, pick an iPhone simulator, press Run.
4. Optional: set your Team and bundle ID (project.yml → PRODUCT_BUNDLE_IDENTIFIER) to run on a device.

Demo data loads on first launch (see Services/SeedData.swift).

## Structure
- App/ – entry point and SwiftData container
- Models/ – LedgerEntry, Budget, TxCategory
- DesignSystem/ – colours, gradients, card style, shared components
- Features/ – Dashboard, Transactions (+ add), Budgets, Insights
