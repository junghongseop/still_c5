//
//  SeatSelection.swift
//  Still
//

nonisolated struct SeatSelection: Hashable, Sendable {
    static let availableRows = (65...90).compactMap {
        UnicodeScalar($0).map { String(Character($0)) }
    }
    static let availableNumbers = Array(1...99)
    static let defaultSelection = SeatSelection(row: "A", number: 1)

    let row: String
    let number: Int

    init?(storedValue: String) {
        let normalizedValue = storedValue.uppercased()
        guard
            let row = normalizedValue.first.map(String.init),
            let number = normalizedValue
                .split(whereSeparator: { !$0.isNumber })
                .compactMap({ Int($0) })
                .first,
            Self.availableRows.contains(row),
            Self.availableNumbers.contains(number)
        else {
            return nil
        }

        self.init(row: row, number: number)
    }

    init?(selectedRow: String?, selectedNumber: Int?) {
        guard
            let selectedRow,
            let selectedNumber,
            Self.availableRows.contains(selectedRow),
            Self.availableNumbers.contains(selectedNumber)
        else {
            return nil
        }

        self.init(row: selectedRow, number: selectedNumber)
    }

    var storedValue: String {
        "\(row)열 \(number)번"
    }

    private init(row: String, number: Int) {
        self.row = row
        self.number = number
    }
}
