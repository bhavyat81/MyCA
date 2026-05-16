import SwiftUI

struct BusinessListView: View {
    @Environment(Store.self) private var store
    @State private var showingGlobalSettings = false

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingM) {
                    Text("My Businesses")
                        .font(Theme.titleFont())
                        .foregroundStyle(.white)
                    Text("Select a business to manage")
                        .foregroundStyle(.white.opacity(0.85))

                    ForEach(Business.all) { business in
                        NavigationLink(value: business) {
                            AppCard {
                                HStack(spacing: Theme.spacingM) {
                                    Text(business.emoji)
                                        .font(.system(size: 34))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(business.name)
                                            .font(.headline.weight(.bold))
                                            .foregroundStyle(.primary)
                                        Text(business.address)
                                            .foregroundStyle(.secondary)
                                            .font(.subheadline)
                                        Text(business.type)
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, Theme.spacingXS)
                                            .padding(.vertical, 4)
                                            .background(store.selectedTheme.accent.opacity(0.22))
                                            .clipShape(Capsule())
                                            .foregroundStyle(.primary)
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Theme.spacingL)
            }
            .navigationDestination(for: Business.self) { business in
                BusinessDashboardView(business: business)
                    .environment(store)
            }
            .navigationTitle("Businesses")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingGlobalSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingGlobalSettings) {
                NavigationStack {
                    GlobalSettingsView()
                        .environment(store)
                }
            }
        }
    }
}

// MARK: - Global (app-wide) settings
// Defined here (instead of a separate file) so it is picked up by the Xcode
// project without needing a pbxproj edit.
struct GlobalSettingsView: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetConfirm = false

    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            Form {
                Section("Theme") {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Button {
                            store.selectedTheme = theme
                            store.saveSettings()
                        } label: {
                            HStack {
                                Text(theme.emoji + " " + theme.displayName)
                                Spacer()
                                if store.selectedTheme == theme {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }

                Section("Data") {
                    Button(role: .destructive) {
                        showingResetConfirm = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash.fill")
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
        .confirmationDialog("Reset all data? This cannot be undone.",
                            isPresented: $showingResetConfirm,
                            titleVisibility: .visible) {
            Button("Reset Everything", role: .destructive) {
                store.resetAllData()
                Haptics.warning()
            }
        }
    }
}

#Preview {
    NavigationStack {
        BusinessListView()
            .environment(Store())
    }
}
