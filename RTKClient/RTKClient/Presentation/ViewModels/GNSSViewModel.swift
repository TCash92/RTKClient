import Foundation
import Combine
import CoreLocation

class GNSSViewModel: ObservableObject {
    
    @Published var currentPosition: GNSSPosition?
    @Published var isReceivingData = false
    @Published var dataRate: Double = 0.0
    @Published var correctionAge: TimeInterval = 0.0
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    @Published var bluetoothState: ConnectionState = .disconnected
    @Published var networkState: NetworkConnectionState = .disconnected
    @Published var ntripState: NTRIPConnectionState = .disconnected
    
    private let bluetoothManager: BluetoothManagerProtocol
    private let networkManager: NetworkManagerProtocol
    private let nmeaParser: NMEAParserProtocol
    private let ntripClient: NTRIPClientProtocol
    private let gnssRepository: GNSSRepositoryProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var lastDataReceived = Date()
    private var dataRateTimer: Timer?
    private var messageCount = 0
    
    private var currentGGASentence: String?
    
    enum ConnectionStatus {
        case disconnected
        case bluetooth
        case network
        case ntripOnly
        
        var description: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .bluetooth: return "Bluetooth Connected"
            case .network: return "Network Connected"
            case .ntripOnly: return "NTRIP Connected"
            }
        }
    }
    
    init(
        bluetoothManager: BluetoothManagerProtocol,
        networkManager: NetworkManagerProtocol,
        nmeaParser: NMEAParserProtocol,
        ntripClient: NTRIPClientProtocol,
        gnssRepository: GNSSRepositoryProtocol
    ) {
        self.bluetoothManager = bluetoothManager
        self.networkManager = networkManager
        self.nmeaParser = nmeaParser
        self.ntripClient = ntripClient
        self.gnssRepository = gnssRepository
        
        setupBindings()
        startDataRateTimer()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3(
            bluetoothManager.objectWillChange,
            networkManager.objectWillChange,
            ntripClient.objectWillChange
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.updateConnectionStatus()
        }
        .store(in: &cancellables)
        
        bluetoothManager.dataStream
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] data in
                self?.processIncomingData(data)
            }
            .store(in: &cancellables)
        
        networkManager.dataStream
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] data in
                self?.processIncomingData(data)
            }
            .store(in: &cancellables)
        
        ntripClient.rtcmDataStream
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] data in
                self?.processRTCMData(data)
            }
            .store(in: &cancellables)
    }
    
    private func updateConnectionStatus() {
        if bluetoothManager.isConnected {
            connectionStatus = .bluetooth
            bluetoothState = bluetoothManager.connectionState
        } else if networkManager.isConnected {
            connectionStatus = .network
            networkState = networkManager.connectionState
        } else if ntripClient.isConnected {
            connectionStatus = .ntripOnly
            ntripState = ntripClient.connectionState
        } else {
            connectionStatus = .disconnected
        }
    }
    
    private func processIncomingData(_ data: Data) {
        lastDataReceived = Date()
        messageCount += 1
        
        DispatchQueue.main.async {
            self.isReceivingData = true
        }
        
        let sentences = nmeaParser.parse(data)
        
        for sentence in sentences {
            processSentence(sentence)
        }
    }
    
    private func processSentence(_ sentence: NMEASentence) {
        switch sentence {
        case let ggaSentence as GGASentence:
            processGGASentence(ggaSentence)
        case let gsaSentence as GSASentence:
            processGSASentence(gsaSentence)
        default:
            break
        }
    }
    
    private func processGGASentence(_ sentence: GGASentence) {
        guard let position = sentence.gnssPosition else { return }
        
        let ggaString = generateGGAString(from: position)
        currentGGASentence = ggaString
        
        if ntripClient.isConnected {
            ntripClient.sendGGA(ggaString)
        }
        
        DispatchQueue.main.async {
            self.currentPosition = position
        }
        
        gnssRepository.savePosition(position)
    }
    
    private func processGSASentence(_ sentence: GSASentence) {
        guard var position = currentPosition else { return }
        
        position = GNSSPosition(
            latitude: position.latitude,
            longitude: position.longitude,
            altitude: position.altitude,
            horizontalAccuracy: position.horizontalAccuracy,
            verticalAccuracy: position.verticalAccuracy,
            timestamp: position.timestamp,
            fixQuality: position.fixQuality,
            satelliteCount: position.satelliteCount,
            hdop: sentence.hdop ?? position.hdop,
            vdop: sentence.vdop ?? position.vdop,
            pdop: sentence.pdop ?? position.pdop
        )
        
        DispatchQueue.main.async {
            self.currentPosition = position
        }
    }
    
    private func processRTCMData(_ data: Data) {
        if bluetoothManager.isConnected {
            bluetoothManager.send(data: data)
        } else if networkManager.isConnected {
            networkManager.send(data: data)
        }
        
        DispatchQueue.main.async {
            self.correctionAge = 0.0
        }
    }
    
    private func generateGGAString(from position: GNSSPosition) -> String {
        let timestamp = DateFormatter.nmeaTime.string(from: position.timestamp)
        let latitude = formatCoordinate(position.latitude, isLatitude: true)
        let longitude = formatCoordinate(position.longitude, isLatitude: false)
        
        let ggaFields = [
            "GPGGA",
            timestamp,
            latitude.coordinate,
            latitude.direction,
            longitude.coordinate,
            longitude.direction,
            "\(position.fixQuality.rawValue)",
            "\(position.satelliteCount)",
            String(format: "%.1f", position.hdop ?? 1.0),
            String(format: "%.1f", position.altitude),
            "M",
            "0.0",
            "M",
            "",
            ""
        ]
        
        let sentence = "$" + ggaFields.joined(separator: ",")
        let checksum = calculateChecksum(sentence.dropFirst())
        return sentence + "*" + checksum
    }
    
    private func formatCoordinate(_ coordinate: Double, isLatitude: Bool) -> (coordinate: String, direction: String) {
        let absCoordinate = abs(coordinate)
        let degrees = Int(absCoordinate)
        let minutes = (absCoordinate - Double(degrees)) * 60.0
        
        let direction: String
        if isLatitude {
            direction = coordinate >= 0 ? "N" : "S"
        } else {
            direction = coordinate >= 0 ? "E" : "W"
        }
        
        let formattedCoordinate = String(format: "%02d%07.4f", degrees, minutes)
        return (formattedCoordinate, direction)
    }
    
    private func calculateChecksum(_ sentence: String) -> String {
        var checksum: UInt8 = 0
        for character in sentence {
            checksum ^= UInt8(character.asciiValue ?? 0)
        }
        return String(format: "%02X", checksum)
    }
    
    private func startDataRateTimer() {
        dataRateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDataRate()
        }
    }
    
    private func updateDataRate() {
        let timeSinceLastData = Date().timeIntervalSince(lastDataReceived)
        
        DispatchQueue.main.async {
            if timeSinceLastData > 2.0 {
                self.isReceivingData = false
                self.dataRate = 0.0
            } else {
                self.dataRate = Double(self.messageCount)
                self.correctionAge += 1.0
            }
        }
        
        messageCount = 0
    }
    
    func connectBluetooth(to device: DiscoveredDevice) {
        bluetoothManager.connect(to: device)
    }
    
    func connectNetwork(host: String, port: UInt16) {
        networkManager.connect(to: host, port: port)
    }
    
    func connectNTRIP(host: String, port: Int, mountpoint: String, username: String, password: String) {
        ntripClient.connect(host: host, port: port, mountpoint: mountpoint, username: username, password: password)
    }
    
    func disconnectAll() {
        bluetoothManager.disconnect()
        networkManager.disconnect()
        ntripClient.disconnect()
    }
    
    deinit {
        dataRateTimer?.invalidate()
    }
}

extension DateFormatter {
    static let nmeaTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss.SS"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
}