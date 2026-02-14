import Foundation

class ScryfallService {
    private let baseURL = "https://api.scryfall.com"
    private var cardCache: [String: ScryfallCard] = [:]
    
    func searchCard(named name: String) async throws -> ScryfallCard? {
        // Check cache first
        if let cached = cardCache[name.lowercased()] {
            return cached
        }
        
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let urlString = "\(baseURL)/cards/search?q=!\"\(encodedName)\"&unique=prints"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let response = try JSONDecoder().decode(ScryfallResponse.self, from: data)
            if let firstCard = response.data.first {
                // Cache the result
                cardCache[name.lowercased()] = firstCard
                return firstCard
            }
        } catch {
            print("Scryfall decode error: \(error)")
        }
        
        return nil
    }
    
    func clearCache() {
        cardCache.removeAll()
    }
}