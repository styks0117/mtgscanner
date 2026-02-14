import SwiftUI
import AVFoundation

struct ScannerView: View {
    @StateObject private var recognitionService = CardRecognitionService()
    @StateObject private var viewModel = ScannerViewModel()
    @State private var showingSheet = false
    @State private var selectedCard: ScannedCard?
    @State private var showCamera = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Camera View
                if showCamera {
                    CameraView(recognitionService: recognitionService, viewModel: viewModel)
                        .frame(height: 300)
                }
                
                // Status/Recognition Display
                VStack(spacing: 8) {
                    if recognitionService.isProcessing {
                        ProgressView("Scanning...")
                            .padding()
                    } else if !recognitionService.recognizedText.isEmpty {
                        HStack {
                            Text("Detected: \(recognitionService.recognizedText)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView("Looking up card...")
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                
                Divider()
                
                // Scanned Cards List
                if viewModel.scannedCards.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Point camera at a Magic card to scan")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Detected cards will appear here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.scannedCards) { card in
                            CardRowView(card: card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCard = card
                                    showingSheet = true
                                }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteCards(at: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("MTG Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showCamera.toggle()
                    } label: {
                        Image(systemName: showCamera ? "camera.fill" : "camera")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.exportToCSV()
                        } label: {
                            Label("Export CSV", systemImage: "square.and.arrow.up")
                        }
                        .disabled(viewModel.scannedCards.isEmpty)
                        
                        Button(role: .destructive) {
                            viewModel.clearAll()
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                        .disabled(viewModel.scannedCards.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingSheet) {
                if let card = selectedCard {
                    CardDetailSheet(card: card, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let url = viewModel.exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    let recognitionService: CardRecognitionService
    let viewModel: ScannerViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.recognitionService = recognitionService
        controller.viewModel = viewModel
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var recognitionService: CardRecognitionService?
    var viewModel: ScannerViewModel?
    private var captureTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        startPeriodicCapture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureTimer?.invalidate()
        captureSession?.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
        startPeriodicCapture()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        captureSession.sessionPreset = .photo
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            
            if let previewLayer = previewLayer {
                view.layer.addSublayer(previewLayer)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        } catch {
            print("Camera setup error: \(error)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    private func startPeriodicCapture() {
        // Capture frame every 2 seconds for OCR
        captureTimer?.invalidate()
        captureTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.captureImageForOCR()
        }
    }
    
    private func captureImageForOCR() {
        guard let recognitionService = recognitionService,
              !recognitionService.isProcessing,
              let connection = previewLayer?.connection else { return }
        
        // Get current frame from preview layer
        let image = captureCurrentFrame()
        
        if let image = image {
            recognitionService.recognizeText(from: image) { [weak self] cardName in
                guard let self = self,
                      let cardName = cardName,
                      let viewModel = self.viewModel else { return }
                
                // Look up the card and add to collection
                viewModel.lookupAndAddCard(named: cardName)
            }
        }
    }
    
    private func captureCurrentFrame() -> UIImage? {
        guard let previewLayer = previewLayer else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(previewLayer.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        previewLayer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: - Card Row View
struct CardRowView: View {
    let card: ScannedCard
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.headline)
                HStack(spacing: 8) {
                    Text(card.setCode.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if card.isFoil {
                        Text("FOIL")
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("x\(card.quantity)")
                    .font(.headline)
                Text(card.condition.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Card Detail Sheet
struct CardDetailSheet: View {
    let card: ScannedCard
    let viewModel: ScannerViewModel
    
    @Environment(\.dismiss) var dismiss
    @State private var condition: CardCondition
    @State private var isFoil: Bool
    @State private var quantity: Int
    
    init(card: ScannedCard, viewModel: ScannerViewModel) {
        self.card = card
        self.viewModel = viewModel
        _condition = State(initialValue: card.condition)
        _isFoil = State(initialValue: card.isFoil)
        _quantity = State(initialValue: card.quantity)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Card Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(card.name)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Set")
                        Spacer()
                        Text("\(card.setName) (\(card.setCode.uppercased()))")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Condition") {
                    Picker("Condition", selection: $condition) {
                        ForEach(CardCondition.allCases, id: \.self) { condition in
                            Text(condition.displayName).tag(condition)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Properties") {
                    Toggle("Foil", isOn: $isFoil)
                    
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                }
            }
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateCard(id: card.id, condition: condition, isFoil: isFoil, quantity: quantity)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
