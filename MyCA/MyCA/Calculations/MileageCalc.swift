import Foundation

enum MileageCalc {
    static let craRate2025: Double = 0.72   // $/km

    static func deductible(km: Double, rate: Double = craRate2025) -> Double {
        km * rate
    }

    static func totalDeductible(entries: [MileageEntry]) -> Double {
        entries.reduce(0) { $0 + $1.deductible }
    }
}
