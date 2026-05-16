import Foundation

/// CRA 2025 payroll calculator — Ontario, Claim Code 1, monthly pay periods
struct PayrollResult {
    let gross: Double
    let cpp: Double
    let ei: Double
    let fedTax: Double
    let onTax: Double
    let net: Double

    var totalDeductions: Double { cpp + ei + fedTax + onTax }
}

enum Payroll {
    // Assumes monthly pay period (12 per year)
    static func calculate(hours: Double, rate: Double, bonus: Double = 0) -> PayrollResult {
        let periodGross = hours * rate + bonus
        guard periodGross > 0 else {
            return PayrollResult(gross: 0, cpp: 0, ei: 0, fedTax: 0, onTax: 0, net: 0)
        }
        let annualGross = periodGross * 12

        // CPP: 5.95% on earnings $3,500–$68,500 annual
        let annualCPPExemption = 3_500.0
        let annualCPPMax = 68_500.0
        let annualCPPEarnings = max(0, min(annualGross - annualCPPExemption,
                                           annualCPPMax - annualCPPExemption))
        let annualCPP = annualCPPEarnings * 0.0595
        let periodCPP = annualCPP / 12

        // EI: 1.66% up to $63,200 annual insurable
        let annualEIMax = 63_200.0
        let annualEI = min(annualGross, annualEIMax) * 0.0166
        let periodEI = annualEI / 12

        // Federal tax — basic personal amount $15,705
        let fedBPA = 15_705.0
        let fedTaxableIncome = max(0, annualGross - fedBPA)
        let annualFedTax = federalTax(on: fedTaxableIncome)
        let fedCPPEICredit = (annualCPP + annualEI) * 0.15
        let annualFedTaxNet = max(0, annualFedTax - fedCPPEICredit)
        let periodFedTax = annualFedTaxNet / 12

        // Ontario tax — basic personal amount $11,865
        let onBPA = 11_865.0
        let onTaxableIncome = max(0, annualGross - onBPA)
        let annualONTax = ontarioTax(on: onTaxableIncome)
        let onCPPEICredit = (annualCPP + annualEI) * 0.0505
        let annualONTaxNet = max(0, annualONTax - onCPPEICredit)
        let periodONTax = annualONTaxNet / 12

        let net = max(0, periodGross - periodCPP - periodEI - periodFedTax - periodONTax)
        return PayrollResult(
            gross: periodGross,
            cpp: periodCPP,
            ei: periodEI,
            fedTax: periodFedTax,
            onTax: periodONTax,
            net: net
        )
    }

    static func federalTax(on income: Double) -> Double {
        applyBrackets(income: income, brackets: [
            (55_867,   0.15),
            (111_733,  0.205),
            (173_205,  0.26),
            (246_752,  0.29),
            (.infinity, 0.33)
        ])
    }

    static func ontarioTax(on income: Double) -> Double {
        applyBrackets(income: income, brackets: [
            (51_446,   0.0505),
            (102_894,  0.0915),
            (150_000,  0.1116),
            (220_000,  0.1216),
            (.infinity, 0.1316)
        ])
    }

    private static func applyBrackets(
        income: Double,
        brackets: [(limit: Double, rate: Double)]
    ) -> Double {
        var tax = 0.0
        var prev = 0.0
        for (limit, rate) in brackets {
            guard income > prev else { break }
            let taxable = min(income, limit) - prev
            tax += taxable * rate
            prev = limit
        }
        return tax
    }
}
