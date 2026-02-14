import Foundation

struct ScannedCard: Identifiable, Codable {
    let id: UUID
    let name: String
    let setName: String
    let setCode: String
    let tcgplayerId: String?
    var condition: CardCondition
    var isFoil: Bool
    var quantity: Int
    let scannedAt: Date
    
    init(name: String, setName: String, setCode: String, tcgplayerId: String?, condition: CardCondition = .nearMint, isFoil: Bool = false, quantity: Int = 1) {
        self.id = UUID()
        self.name = name
        self.setName = setName
        self.setCode = setCode
        self.tcgplayerId = tcgplayerId
        self.condition = condition
        self.isFoil = isFoil
        self.quantity = quantity
        self.scannedAt = Date()
    }
}

struct ScryfallCard: Codable {
    let name: String
    let set_name: String
    let set: String
    let tcgplayer_id: Int?
    let finishes: [String]?
}

struct ScryfallResponse: Codable {
    let data: [ScryfallCard]
}