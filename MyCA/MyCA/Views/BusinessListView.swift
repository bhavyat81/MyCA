import SwiftUI

struct BusinessListView: View {
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
                                    Text(business.icon)
                                        .font(.system(size: 34))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(business.name)
                                            .font(.headline.weight(.bold))
                                            .foregroundStyle(.white)
                                        Text(business.address)
                                            .foregroundStyle(.white.opacity(0.85))
                                            .font(.subheadline)
                                        Text(business.type)
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, Theme.spacingXS)
                                            .padding(.vertical, 4)
                                            .background(Theme.accent.opacity(0.22))
                                            .clipShape(Capsule())
                                            .foregroundStyle(.white)
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.white.opacity(0.8))
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
            }
        }
    }
}

#Preview {
    NavigationStack {
        BusinessListView()
    }
}
