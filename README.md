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
- Select business: Planet Rehab (200 County Court, Brampton), 83 Kennedy, Meltwich
- Salary tracker: name + hours + pay rate, auto totals, per month
- Expense calculator: custom expenses, per-month totals
- Local persistence via UserDefaults
