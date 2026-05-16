import Foundation

/// Personal income tax estimator — CRA 2025, Ontario, single filer
struct TaxEstimateResult {
    let federalTax: Double
    let provincialTax: Double
    let totalTax: Double
    let marginalRate: Double
    let averageRate: Double
    let afterTaxIncome: Double
}

enum Tax {
    static func estimate(annualIncome: Double) -> TaxEstimateResult {
        guard annualIncome > 0 else {
            return TaxEstimateResult(federalTax: 0, provincialTax: 0, totalTax: 0,
                                     marginalRate: 0, averageRate: 0, afterTaxIncome: 0)
        }
        let fedBPA = 15_705.0
        let onBPA  = 11_865.0
        let fedTaxable = max(0, annualIncome - fedBPA)
        let onTaxable  = max(0, annualIncome - onBPA)

        let fedTax = Payroll.federalTax(on: fedTaxable)
        let onTax  = Payroll.ontarioTax(on: onTaxable)
        let total  = fedTax + onTax

        let marginal = marginalRate(for: annualIncome)
        let average  = annualIncome > 0 ? total / annualIncome : 0

        return TaxEstimateResult(
            federalTax: fedTax,
            provincialTax: onTax,
            totalTax: total,
            marginalRate: marginal,
            averageRate: average,
            afterTaxIncome: annualIncome - total
        )
    }

    private static func marginalRate(for income: Double) -> Double {
        // Combined federal + Ontario marginal rate at given income
        let fedMarginal: Double
        switch income {
        case ..<55_867:  fedMarginal = 0.15
        case ..<111_733: fedMarginal = 0.205
        case ..<173_205: fedMarginal = 0.26
        case ..<246_752: fedMarginal = 0.29
        default:         fedMarginal = 0.33
        }
        let onMarginal: Double
        switch income {
        case ..<51_446:  onMarginal = 0.0505
        case ..<102_894: onMarginal = 0.0915
        case ..<150_000: onMarginal = 0.1116
        case ..<220_000: onMarginal = 0.1216
        default:         onMarginal = 0.1316
        }
        return fedMarginal + onMarginal
    }
}
