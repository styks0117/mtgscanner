import Foundation
import UIKit

class CSVExportService {
    
    func generateCSV(from cards: [ScannedCard]) -> String {
        var csvString = "Card Name,Set Name,Set Code,SKU,Quantity,Condition,Finish\n"
        
        for card in cards {
            let sku = card.tcgplayerId ?? ""
            let finish = card.isFoil ? "Foil" : "Normal"
            let row = "\"
            + "\(card.name)\",\"\(card.setName)\",\"\(card.setCode)\",\(sku),\(card.quantity),\(card.condition.rawValue),\(finish)\n"
            csvString.append(row)
        }
        
        return csvString
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