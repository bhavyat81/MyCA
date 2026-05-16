import SwiftUI

struct RootTabView: View {
    @Environment(Store.self) private var store
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
                .tag(0)

            SalaryView()
                .tabItem { Label("Salary", systemImage: "person.2.fill") }
                .tag(1)

            ExpenseView()
                .tabItem { Label("Expenses", systemImage: "cart.fill") }
                .tag(2)

            RevenueView()
                .tabItem { Label("Revenue", systemImage: "dollarsign.circle.fill") }
                .tag(3)

            ReportsView()
                .tabItem { Label("Reports", systemImage: "chart.bar.fill") }
                .tag(4)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(5)
        }
        .onChange(of: selectedTab) { _, _ in
            Haptics.impact(.light)
        }
        .tint(store.selectedTheme.accent)
    }
}

#Preview {
    RootTabView()
        .environment(Store())
}
