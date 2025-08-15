import XCTest
import Combine
@testable import RTKClient

final class GNSSViewModelTests: XCTestCase {
    
    private var viewModel: GNSSViewModel!
    private var mockBluetoothManager: MockBluetoothManager!
    private var mockNetworkManager: MockNetworkManager!
    private var mockNMEAParser: MockNMEAParser!
    private var mockNTRIPClient: MockNTRIPClient!
    private var mockRepository: MockGNSSRepository!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        mockBluetoothManager = MockBluetoothManager()
        mockNetworkManager = MockNetworkManager()
        mockNMEAParser = MockNMEAParser()
        mockNTRIPClient = MockNTRIPClient()
        mockRepository = MockGNSSRepository()
        cancellables = Set<AnyCancellable>()
        
        viewModel = GNSSViewModel(
            bluetoothManager: mockBluetoothManager,
            networkManager: mockNetworkManager,
            nmeaParser: mockNMEAParser,
            ntripClient: mockNTRIPClient,
            gnssRepository: mockRepository
        )
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockRepository = nil
        mockNTRIPClient = nil
        mockNMEAParser = nil
        mockNetworkManager = nil
        mockBluetoothManager = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.currentPosition)
        XCTAssertFalse(viewModel.isReceivingData)
        XCTAssertEqual(viewModel.dataRate, 0.0)
        XCTAssertEqual(viewModel.connectionStatus, .disconnected)
    }
    
    func testBluetoothConnectionStatusUpdate() {
        let expectation = self.expectation(description: "Connection status updated")
        
        viewModel.$connectionStatus
            .dropFirst()
            .sink { status in
                XCTAssertEqual(status, .bluetooth)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockBluetoothManager.simulateConnection()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPositionDataProcessing() {
        let expectation = self.expectation(description: "Position data processed")
        
        let mockGGASentence = MockGGASentence()
        mockNMEAParser.mockSentences = [mockGGASentence]
        
        viewModel.$currentPosition
            .compactMap { $0 }
            .sink { position in
                XCTAssertNotNil(position)
                XCTAssertEqual(position.fixQuality, .rtk)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let testData = "test data".data(using: .utf8)!
        mockBluetoothManager.simulateDataReceived(testData)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDataRateCalculation() {
        let expectation = self.expectation(description: "Data rate calculated")
        
        mockBluetoothManager.simulateConnection()
        
        viewModel.$dataRate
            .dropFirst(2) // Skip initial values
            .sink { dataRate in
                XCTAssertGreaterThan(dataRate, 0)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate multiple data packets
        for _ in 0..<5 {
            let testData = "test data".data(using: .utf8)!
            mockBluetoothManager.simulateDataReceived(testData)
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRTCMDataForwarding() {
        mockBluetoothManager.simulateConnection()
        
        let rtcmData = Data([0xD3, 0x00, 0x10]) // Mock RTCM frame
        mockNTRIPClient.simulateRTCMData(rtcmData)
        
        XCTAssertTrue(mockBluetoothManager.lastSentData?.starts(with: [0xD3, 0x00, 0x10]) ?? false)
    }
}

// MARK: - Mock Objects

class MockBluetoothManager: BluetoothManagerProtocol, ObservableObject {
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var connectedDeviceName: String?
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var connectionState: ConnectionState = .disconnected
    
    private let dataSubject = PassthroughSubject<Data, Never>()
    var dataStream: AnyPublisher<Data, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    var lastSentData: Data?
    
    func startScanning() {
        isScanning = true
    }
    
    func stopScanning() {
        isScanning = false
    }
    
    func connect(to device: DiscoveredDevice) {
        // Mock implementation
    }
    
    func disconnect() {
        isConnected = false
        connectionState = .disconnected
    }
    
    func send(data: Data) {
        lastSentData = data
    }
    
    func simulateConnection() {
        isConnected = true
        connectionState = .connected
    }
    
    func simulateDataReceived(_ data: Data) {
        dataSubject.send(data)
    }
}

class MockNetworkManager: NetworkManagerProtocol, ObservableObject {
    @Published var isConnected = false
    @Published var connectionState: NetworkConnectionState = .disconnected
    
    private let dataSubject = PassthroughSubject<Data, Never>()
    var dataStream: AnyPublisher<Data, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    func connect(to host: String, port: UInt16) {
        isConnected = true
        connectionState = .connected
    }
    
    func disconnect() {
        isConnected = false
        connectionState = .disconnected
    }
    
    func send(data: Data) {
        // Mock implementation
    }
}

class MockNMEAParser: NMEAParserProtocol {
    var mockSentences: [NMEASentence] = []
    
    func parse(_ data: Data) -> [NMEASentence] {
        return mockSentences
    }
    
    func parseGGA(_ sentence: String) -> GGASentence? {
        return nil
    }
    
    func parseRMC(_ sentence: String) -> RMCSentence? {
        return nil
    }
    
    func parseGSA(_ sentence: String) -> GSASentence? {
        return nil
    }
    
    func validateChecksum(_ sentence: String) -> Bool {
        return true
    }
}

class MockNTRIPClient: NTRIPClientProtocol, ObservableObject {
    @Published var isConnected = false
    @Published var connectionState: NTRIPConnectionState = .disconnected
    
    private let rtcmSubject = PassthroughSubject<Data, Never>()
    var rtcmDataStream: AnyPublisher<Data, Never> {
        rtcmSubject.eraseToAnyPublisher()
    }
    
    func connect(host: String, port: Int, mountpoint: String, username: String, password: String) {
        isConnected = true
        connectionState = .connected
    }
    
    func disconnect() {
        isConnected = false
        connectionState = .disconnected
    }
    
    func sendGGA(_ sentence: String) {
        // Mock implementation
    }
    
    func simulateRTCMData(_ data: Data) {
        rtcmSubject.send(data)
    }
}

class MockGNSSRepository: GNSSRepositoryProtocol {
    private var positions: [GNSSPosition] = []
    
    func savePosition(_ position: GNSSPosition) {
        positions.append(position)
    }
    
    func getRecentPositions(limit: Int) -> [GNSSPosition] {
        return Array(positions.suffix(limit))
    }
    
    func clearHistory() {
        positions.removeAll()
    }
}

struct MockGGASentence: NMEASentence {
    let talkerID = "GP"
    let sentenceID = "GGA"
    let checksum = "47"
    let isValid = true
    
    var gnssPosition: GNSSPosition? {
        return GNSSPosition(
            latitude: 48.1173,
            longitude: 11.5167,
            altitude: 545.4,
            horizontalAccuracy: 0.02,
            verticalAccuracy: 0.03,
            timestamp: Date(),
            fixQuality: .rtk,
            satelliteCount: 12,
            hdop: 0.5,
            vdop: nil,
            pdop: nil
        )
    }
}