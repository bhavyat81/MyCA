import SwiftUI

struct TaxEstimatorView: View {
    @State private var incomeText = ""

    private var income: Double { Double(incomeText) ?? 0 }
    private var result: TaxEstimateResult? {
        income > 0 ? Tax.estimate(annualIncome: income) : nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Personal Tax Estimator", systemImage: "person.text.rectangle")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Ontario 2025 • Simplified, Claim Code 1")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Annual Income", text: $incomeText)
                        .keyboardType(.decimalPad)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                }
            }

            if let r = result {
                GlassCard {
                    VStack(spacing: 0) {
                        TaxRow(label: "Gross Income",    value: Theme.currency(income),         color: .primary, bold: true)
                        Divider()
                        TaxRow(label: "Federal Tax",     value: Theme.currency(r.federalTax),   color: .red)
                        TaxRow(label: "Ontario Tax",     value: Theme.currency(r.provincialTax),color: .orange)
                        TaxRow(label: "Total Tax",       value: Theme.currency(r.totalTax),     color: .red, bold: true)
                        Divider()
                        TaxRow(label: "After-Tax Income",value: Theme.currency(r.afterTaxIncome),color: .green, bold: true)
                        Divider()
                        TaxRow(label: "Marginal Rate",   value: "\(Int(r.marginalRate * 100))%",  color: .primary)
                        TaxRow(label: "Average Rate",    value: String(format: "%.1f%%", r.averageRate * 100), color: .secondary)
                    }
                }

                // Quick benchmarks
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Benchmarks (CRA 2025)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        ForEach([50_000.0, 100_000.0, 200_000.0], id: \.self) { i in
                            let b = Tax.estimate(annualIncome: i)
                            HStack {
                                Text(Theme.currency(i)).font(.caption).foregroundStyle(.primary)
                                Spacer()
                                Text("Tax: \(Theme.currency(b.totalTax))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Net: \(Theme.currency(b.afterTaxIncome))")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct TaxRow: View {
    let label: String; let value: String
    var color: Color = .primary; var bold: Bool = false
    var body: some View {
        HStack {
            Text(label).font(bold ? .headline : .subheadline).foregroundStyle(.primary)
            Spacer()
            Text(value).font(bold ? .headline : .subheadline).foregroundStyle(color)
        }
        .padding(.vertical, 6)
    }
}
