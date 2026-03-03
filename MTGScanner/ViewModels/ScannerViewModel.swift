import Foundation
import SwiftUI

@MainActor
class ScannerViewModel: ObservableObject {
    @Published var scannedCards: [ScannedCard] = [] {
        didSet {
            saveCards()
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showShareSheet = false
    @Published var exportURL: URL?
    
    private let scryfallService = ScryfallService()
    private let csvExportService = CSVExportService()
    private var lastAddedCardName: String?
    private var lastAddedTime: Date = .distantPast
    
    // Debounce interval to prevent duplicate additions of the same card
    private let debounceInterval: TimeInterval = 3.0
    
    // UserDefaults key for persistence
    private let cardsStorageKey = "scannedCards"
    
    init() {
        loadCards()
    }
    
    private func saveCards() {
        do {
            let encoded = try JSONEncoder().encode(scannedCards)
            UserDefaults.standard.set(encoded, forKey: cardsStorageKey)
        } catch {
            print("Failed to save cards: \(error.localizedDescription)")
            // Note: We don't show UI error here as save happens automatically in background
            // and shouldn't interrupt user experience
        }
    }
    
    private func loadCards() {
        guard let data = UserDefaults.standard.data(forKey: cardsStorageKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode([ScannedCard].self, from: data)
            scannedCards = decoded
        } catch {
            print("Failed to load cards: \(error.localizedDescription)")
            // If load fails, start with empty collection rather than crashing
        }
    }
    
    func lookupAndAddCard(named cardName: String) {
        // Prevent duplicate rapid additions of the same card
        let now = Date()
        if cardName == lastAddedCardName && now.timeIntervalSince(lastAddedTime) < debounceInterval {
            return
        }
        
        lastAddedCardName = cardName
        lastAddedTime = now
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                if let scryfallCard = try await scryfallService.searchCard(named: cardName) {
                    let scannedCard = ScannedCard(
                        name: scryfallCard.name,
                        setName: scryfallCard.set_name,
                        setCode: scryfallCard.set,
                        tcgplayerId: scryfallCard.tcgplayer_id.map { String($0) }
                    )
                    
                    // Check if card already exists, if so increment quantity
                    if let existingIndex = scannedCards.firstIndex(where: { 
                        $0.name == scannedCard.name && 
                        $0.setCode == scannedCard.setCode &&
                        $0.condition == scannedCard.condition &&
                        $0.isFoil == scannedCard.isFoil
                    }) {
                        scannedCards[existingIndex].quantity += 1
                    } else {
                        scannedCards.insert(scannedCard, at: 0)
                    }
                    
                    isLoading = false
                } else {
                    errorMessage = "Card '\(cardName)' not found"
                    isLoading = false
                }
            } catch {
                errorMessage = "Failed to lookup card: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func updateCard(id: UUID, condition: CardCondition, isFoil: Bool, quantity: Int) {
        if let index = scannedCards.firstIndex(where: { $0.id == id }) {
            scannedCards[index].condition = condition
            scannedCards[index].isFoil = isFoil
            scannedCards[index].quantity = quantity
        }
    }
    
    func deleteCards(at offsets: IndexSet) {
        scannedCards.remove(atOffsets: offsets)
    }
    
    func clearAll() {
        scannedCards.removeAll()
        scryfallService.clearCache()
        errorMessage = nil
    }
    
    func exportToCSV() {
        csvExportService.exportToFile(cards: scannedCards) { [weak self] url in
            guard let self = self else { return }
            Task { @MainActor in
                if let url = url {
                    self.exportURL = url
                    self.showShareSheet = true
                } else {
                    self.errorMessage = "Failed to export CSV"
                }
            }
        }
    }
}
