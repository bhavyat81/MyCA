import Foundation

struct HSTResult {
    let base: Double
    let hst: Double
    let total: Double
}

enum HST {
    /// Split a total that already includes HST
    static func split(total: Double, rate: Double = 0.13) -> HSTResult {
        let base = total / (1 + rate)
        let hst  = total - base
        return HSTResult(base: base, hst: hst, total: total)
    }

    /// Add HST on top of a base amount
    static func add(base: Double, rate: Double = 0.13) -> HSTResult {
        let hst = base * rate
        return HSTResult(base: base, hst: hst, total: base + hst)
    }

    /// Net HST owed = collected − paid
    static func owed(collected: Double, paid: Double) -> Double {
        collected - paid
    }
}
