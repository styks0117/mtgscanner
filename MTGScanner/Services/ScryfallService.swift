import Foundation

class ScryfallService {
    private let baseURL = "https://api.scryfall.com"
    private var cardCache: [String: ScryfallCard] = [:]
    private let maxCacheSize = 500 // Limit cache to prevent unbounded growth
    private var cacheKeys: [String] = [] // Track insertion order for LRU eviction
    
    func searchCard(named name: String) async throws -> ScryfallCard? {
        // Check cache first
        let cacheKey = name.lowercased()
        if let cached = cardCache[cacheKey] {
            return cached
        }
        
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let urlString = "\(baseURL)/cards/search?q=!\"\(encodedName)\"&unique=prints"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Configure URLSession with timeout
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0 // 10 second timeout
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            let response = try JSONDecoder().decode(ScryfallResponse.self, from: data)
            if let firstCard = response.data.first {
                // Add to cache with LRU eviction
                addToCache(key: cacheKey, card: firstCard)
                return firstCard
            }
        } catch {
            print("Scryfall decode error: \(error)")
        }
        
        return nil
    }
    
    private func addToCache(key: String, card: ScryfallCard) {
        // Implement LRU cache with size limit
        if cardCache.count >= maxCacheSize {
            // Evict oldest entry
            if let oldestKey = cacheKeys.first {
                cardCache.removeValue(forKey: oldestKey)
                cacheKeys.removeFirst()
            }
        }
        
        cardCache[key] = card
        cacheKeys.append(key)
    }
    
    func clearCache() {
        cardCache.removeAll()
        cacheKeys.removeAll()
    }
}