import XCTest
@testable import MyCA

final class MyCATests: XCTestCase {}

// MARK: - Payroll Tests
final class PayrollTests: XCTestCase {
    func testZeroHours() {
        let r = Payroll.calculate(hours: 0, rate: 25)
        XCTAssertEqual(r.gross, 0)
        XCTAssertEqual(r.net, 0)
    }

    func testBasicPayroll() {
        // 160h × $25/h = $4,000 gross (monthly)
        let r = Payroll.calculate(hours: 160, rate: 25)
        XCTAssertEqual(r.gross, 4_000, accuracy: 0.01)
        XCTAssertGreaterThan(r.cpp, 0)
        XCTAssertGreaterThan(r.ei, 0)
        XCTAssertGreaterThan(r.fedTax, 0)
        XCTAssertGreaterThan(r.onTax, 0)
        XCTAssertGreaterThan(r.net, 0)
        XCTAssertLessThan(r.net, r.gross)
    }

    func testBonus() {
        let withoutBonus = Payroll.calculate(hours: 80, rate: 20)
        let withBonus    = Payroll.calculate(hours: 80, rate: 20, bonus: 500)
        XCTAssertEqual(withBonus.gross, withoutBonus.gross + 500, accuracy: 0.01)
        XCTAssertGreaterThan(withBonus.fedTax, withoutBonus.fedTax)
    }

    func testCPPExemption() {
        // Very low income should have 0 CPP (below annual $3,500 threshold)
        let r = Payroll.calculate(hours: 10, rate: 10)
        // 10 × 10 = $100/month, $1,200/year < $3,500 exemption
        XCTAssertEqual(r.cpp, 0, accuracy: 0.01)
    }

    func testNetIsPositive() {
        let r = Payroll.calculate(hours: 40, rate: 20)
        XCTAssertGreaterThan(r.net, 0)
    }

    func testFederalBrackets() {
        // $60,000 (just above first bracket $55,867)
        let tax = Payroll.federalTax(on: 60_000)
        let expected = 55_867 * 0.15 + (60_000 - 55_867) * 0.205
        XCTAssertEqual(tax, expected, accuracy: 0.01)
    }

    func testOntarioBrackets() {
        let tax = Payroll.ontarioTax(on: 60_000)
        let expected = 51_446 * 0.0505 + (60_000 - 51_446) * 0.0915
        XCTAssertEqual(tax, expected, accuracy: 0.01)
    }
}

// MARK: - HST Tests
final class HSTTests: XCTestCase {
    func testSplit() {
        let r = HST.split(total: 113, rate: 0.13)
        XCTAssertEqual(r.base,  100, accuracy: 0.01)
        XCTAssertEqual(r.hst,    13, accuracy: 0.01)
        XCTAssertEqual(r.total, 113, accuracy: 0.01)
    }

    func testAdd() {
        let r = HST.add(base: 100, rate: 0.13)
        XCTAssertEqual(r.base,  100, accuracy: 0.01)
        XCTAssertEqual(r.hst,    13, accuracy: 0.01)
        XCTAssertEqual(r.total, 113, accuracy: 0.01)
    }

    func testOwed() {
        XCTAssertEqual(HST.owed(collected: 200, paid: 50), 150, accuracy: 0.01)
    }

    func testRefund() {
        XCTAssertEqual(HST.owed(collected: 50, paid: 200), -150, accuracy: 0.01)
    }
}

// MARK: - Tax Estimator Tests
final class TaxEstimatorTests: XCTestCase {
    func test50k() {
        let r = Tax.estimate(annualIncome: 50_000)
        // Rough check: tax should be between 15% and 25% of income
        XCTAssertGreaterThan(r.totalTax, 50_000 * 0.10)
        XCTAssertLessThan(r.totalTax,    50_000 * 0.30)
        XCTAssertEqual(r.afterTaxIncome, 50_000 - r.totalTax, accuracy: 0.01)
    }

    func test100k() {
        let r = Tax.estimate(annualIncome: 100_000)
        XCTAssertGreaterThan(r.totalTax, 100_000 * 0.15)
        XCTAssertLessThan(r.totalTax,    100_000 * 0.40)
    }

    func test200k() {
        let r = Tax.estimate(annualIncome: 200_000)
        XCTAssertGreaterThan(r.marginalRate, 0.40)
    }

    func testZeroIncome() {
        let r = Tax.estimate(annualIncome: 0)
        XCTAssertEqual(r.totalTax, 0)
        XCTAssertEqual(r.marginalRate, 0)
    }
}

// MARK: - Mileage Tests
final class MileageCalcTests: XCTestCase {
    func testBasic() {
        XCTAssertEqual(MileageCalc.deductible(km: 100), 72.0, accuracy: 0.01)
    }

    func testCustomRate() {
        XCTAssertEqual(MileageCalc.deductible(km: 100, rate: 0.50), 50.0, accuracy: 0.01)
    }

    func testEntries() {
        let entries = [
            MileageEntry(businessId: "a", date: Date(), km: 50, purpose: "Client visit"),
            MileageEntry(businessId: "a", date: Date(), km: 100, purpose: "Supply run")
        ]
        XCTAssertEqual(MileageCalc.totalDeductible(entries: entries),
                       150 * MileageCalc.craRate2025, accuracy: 0.01)
    }
}

