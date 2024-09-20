import SwiftUI

class CSVParser {
    func parseCSV(_ csvData: String) -> [DataPoint] {
        let rows = csvData.components(separatedBy: "\n")
        return rows.compactMap { row in
            let columns = row.split(separator: ",").map(String.init)
            if columns.count == 3,
               let time = Int(columns[0]),
               let voltage = Double(columns[1]),
               let current = Double(columns[2]) {
                return DataPoint(time: time, voltage: voltage, current: current)
            }
            return nil
        }
    }
}

