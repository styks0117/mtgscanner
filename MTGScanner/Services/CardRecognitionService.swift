import Vision
import UIKit
import AVFoundation

class CardRecognitionService: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var isProcessing = false
    
    private var lastScanTime: Date = .distantPast
    private let scanCooldown: TimeInterval = 1.5 // Prevent rapid re-scanning
    
    func recognizeText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard !isProcessing else { return }
        
        // Cooldown check to prevent multiple scans
        let now = Date()
        guard now.timeIntervalSince(lastScanTime) > scanCooldown else {
            return
        }
        
        isProcessing = true
        lastScanTime = now
        
        guard let cgImage = image.cgImage else {
            isProcessing = false
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            
            defer { self.isProcessing = false }
            
            if let error = error {
                print("Text recognition error: \(error)")
                completion(nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // Extract card name (usually the largest/most prominent text)
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            // Filter out common non-card text
            let filteredStrings = recognizedStrings.filter { text in
                !text.isEmpty &&
                text.count > 2 &&
                !text.contains(where: { $0.isNumber }) // Basic filter for set numbers/etc
            }
            
            if let cardName = filteredStrings.first {
                DispatchQueue.main.async {
                    self.recognizedText = cardName
                    completion(cardName)
                }
            } else {
                completion(nil)
            }
        }
        
        request.recognitionLevel = .fast // Speed over accuracy for real-time
        request.usesLanguageCorrection = false // Faster without language correction
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error)")
            isProcessing = false
            completion(nil)
        }
    }
}