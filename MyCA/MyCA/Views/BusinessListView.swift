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

#Preview {
    NavigationStack {
        BusinessListView()
            .environment(Store())
    }
}
