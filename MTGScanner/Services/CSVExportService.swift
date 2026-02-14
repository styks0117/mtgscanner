import Foundation
import UIKit

class CSVExportService {
    
    func generateCSV(from cards: [ScannedCard]) -> String {
        var csvString = "Card Name,Set Name,Set Code,SKU,Quantity,Condition,Finish\n"
        
        for card in cards {
            let sku = escapeCSV(card.tcgplayerId ?? "")
            let finish = escapeCSV(card.isFoil ? "Foil" : "Normal")
            // Escape CSV values to prevent formula injection
            let row = "\(escapeCSV(card.name)),\(escapeCSV(card.setName)),\(escapeCSV(card.setCode)),\(sku),\(card.quantity),\(escapeCSV(card.condition.rawValue)),\(finish)\n"
            csvString.append(row)
        }
        
        return csvString
    }
    
    private func escapeCSV(_ value: String) -> String {
        // Prevent CSV injection by escaping special characters
        var escaped = value
        
        // Remove leading characters that could trigger formula injection
        let dangerousChars: [Character] = ["=", "+", "-", "@", "\t", "\r"]
        while let first = escaped.first, dangerousChars.contains(first) {
            escaped.removeFirst()
        }
        
        // Always escape double quotes and wrap string fields in quotes for safety
        escaped = escaped.replacingOccurrences(of: "\"", with: "\"\"")
        escaped = "\"\(escaped)\""
        
        return escaped
    }
    
    func exportToFile(cards: [ScannedCard], completion: @escaping (URL?) -> Void) {
        let csvString = generateCSV(from: cards)
        
        let fileName = "mtg-collection-\(Date().timeIntervalSince1970).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            completion(path)
        } catch {
            print("Failed to write CSV: \(error)")
            completion(nil)
        }
    }
}