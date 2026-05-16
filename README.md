# MyCA

Native iOS app (SwiftUI) for personal CA work.

## Run in Xcode
1. Clone: `git clone https://github.com/bhavyat81/MyCA.git`
2. Open `MyCA/MyCA.xcodeproj` in Xcode 15+
3. Select an iPhone simulator (e.g. iPhone 15) and press ⌘R

## Xcode Cloud
- Open the project in Xcode → Product → Xcode Cloud → Create Workflow
- Bundle id is already set to `com.bhavyat81.myca`
- Add your Apple Developer team in Signing & Capabilities

## Features
- Business-first launch flow: starts on Business List (Planet Rehab, 83 Kennedy, Meltwich)
- Tap a business to open its Business Hub with month/year selector and tiles:
  Revenue, Salary, Expenses, Mileage, Invoices, Reports, Settings
- Global app settings available from the gear icon on the Business List screen
- Salary tracker supports Contract vs Payroll:
  - Contract: full gross pay (no CPP/EI/tax deductions)
  - Payroll: CPP/EI/Federal/ON deductions and net pay breakdown
- Existing stored salary entries safely default to Contract during decode migration
- Expense calculator: custom expenses, per-month totals
- Local persistence via UserDefaults
