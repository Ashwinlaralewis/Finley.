Finley

A personal finance app for iPhone, built with SwiftUI and SwiftData. Track spending, set monthly budgets, and see where your money goes. Everything is stored on the device, so it works offline with no account.

<!-- Add screenshots here after you run the app: ![Home](screenshots/home.png) -->
Features
Home dashboard: total balance, monthly income and spending, and a 7-day spending chart
Activity: all transactions grouped by day, with search, filters and swipe to delete
Add transaction: expense or income, category picker, date, and haptic feedback
Budgets: monthly limit per category with progress bars and over-budget warnings
Insights: spending donut chart, savings rate, and change compared with last month
Face ID lock: optional lock with Face ID, Touch ID or device passcode, which also hides the app in the app switcher
Launch animation: a custom cinematic intro (light beams, letters rising in, zoom-through)
Accessibility: Reduce Motion support and VoiceOver labels
Tech stack
Area	Technology
UI	SwiftUI
Data	SwiftData (local, offline)
Charts	Swift Charts
Security	LocalAuthentication (Face ID)
Project setup	XcodeGen
Minimum iOS	17.0

No third-party libraries are used.

Run it

You need a Mac with Xcode 15 or newer.

bash
brew install xcodegen
git clone https://github.com/Ashwinlaralewis/Finley.git
cd Finley
xcodegen generate
open Finley.xcodeproj

Then choose an iPhone simulator (for example iPhone 16) at the top of Xcode and press Run (Cmd + R). Demo data loads on first launch.

To try the Face ID lock in the simulator: Features → Face ID → Enrolled, then turn on the lock with the gear icon on the Home screen.

Project structure
Finley/
├── App/            App entry point and database setup
├── Models/         LedgerEntry, Budget, TxCategory
├── DesignSystem/   Colours, gradients, card style, shared components
├── Services/       Demo data, app lock (Face ID)
└── Features/
    ├── Root/           Tab bar and launch animation
    ├── Dashboard/      Home screen
    ├── Transactions/   Activity list and add form
    ├── Budgets/        Budget cards and add form
    ├── Insights/       Charts and statistics
    ├── Lock/           Lock screen
    └── Settings/       App settings
How it works
Data is saved with SwiftData. Screens read it with @Query, so every screen updates automatically when a transaction is added or deleted.
Colours, spacing and card style live in one place (DesignSystem/Theme.swift), so the look can change from a single file.
The project file is generated from project.yml with XcodeGen, so it stays clean in version control.
Roadmap
 Recurring bills
 Savings goals
 Export to PDF or CSV
 Home-screen widget
 Budget notifications
 iCloud sync
 Unit tests
Author

Built by Ashwin Lara Lewis.
