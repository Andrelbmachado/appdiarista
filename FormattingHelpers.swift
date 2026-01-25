import Foundation

enum CurrencyFormatter {
    static let brl: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = true
        return formatter
    }()
    
    static func string(from decimal: Decimal) -> String {
        let number = NSDecimalNumber(decimal: decimal)
        return brl.string(from: number) ?? "R$ 0,00"
    }
    
    static func decimal(from string: String) -> Decimal? {
        brl.number(from: string)?.decimalValue
    }
}

extension String {
    var normalized: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}
