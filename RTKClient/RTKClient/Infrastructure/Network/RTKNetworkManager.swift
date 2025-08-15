import Foundation
import Combine
import Network

class RTKNetworkManager: NetworkManagerProtocol, ObservableObject {
    
    @Published var isConnected = false
    @Published var connectionState: NetworkConnectionState = .disconnected
    
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "RTKNetworkQueue", qos: .userInitiated)
    
    private let dataSubject = PassthroughSubject<Data, Never>()
    var dataStream: AnyPublisher<Data, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    private var reconnectionTimer: Timer?
    private var reconnectionAttempts = 0
    private let maxReconnectionAttempts = 5
    private var currentHost: String?
    private var currentPort: UInt16?
    
    func connect(to host: String, port: UInt16) {
        disconnect()
        
        currentHost = host
        currentPort = port
        reconnectionAttempts = 0
        
        let endpoint = NWEndpoint.Host(host)
        let portEndpoint = NWEndpoint.Port(integerLiteral: port)
        
        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.enableKeepalive = true
        tcpOptions.keepaliveIdle = 30
        tcpOptions.noDelay = true
        
        let parameters = NWParameters(tls: nil, tcp: tcpOptions)
        parameters.serviceName = "RTK Data Stream"
        parameters.requiredInterfaceType = .wifi
        
        connection = NWConnection(host: endpoint, port: portEndpoint, using: parameters)
        
        setupConnection()
        
        DispatchQueue.main.async {
            self.connectionState = .connecting
        }
        
        connection?.start(queue: queue)
    }
    
    func disconnect() {
        stopReconnectionTimer()
        
        connection?.forceCancel()
        connection = nil
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionState = .disconnected
        }
        
        currentHost = nil
        currentPort = nil
        reconnectionAttempts = 0
    }
    
    func send(data: Data) {
        guard let connection = connection,
              connection.state == .ready else { return }
        
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("Failed to send data: \(error)")
            }
        })
    }
    
    private func setupConnection() {
        guard let connection = connection else { return }
        
        connection.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateUpdate(state)
            }
        }
        
        startReceiving()
    }
    
    private func handleStateUpdate(_ state: NWConnection.State) {
        switch state {
        case .setup:
            connectionState = .connecting
            
        case .preparing:
            connectionState = .connecting
            
        case .ready:
            connectionState = .connected
            isConnected = true
            resetReconnectionState()
            
        case .waiting(let error):
            connectionState = .failed(error)
            isConnected = false
            scheduleReconnection()
            
        case .failed(let error):
            connectionState = .failed(error)
            isConnected = false
            scheduleReconnection()
            
        case .cancelled:
            connectionState = .disconnected
            isConnected = false
            
        @unknown default:
            connectionState = .failed(NetworkError.unknownState)
            isConnected = false
        }
    }
    
    private func startReceiving() {
        guard let connection = connection else { return }
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            
            if let data = data, !data.isEmpty {
                self?.dataSubject.send(data)
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.connectionState = .failed(error)
                    self?.isConnected = false
                }
                return
            }
            
            if isComplete {
                DispatchQueue.main.async {
                    self?.connectionState = .disconnected
                    self?.isConnected = false
                }
                return
            }
            
            self?.startReceiving()
        }
    }
    
    private func scheduleReconnection() {
        guard reconnectionAttempts < maxReconnectionAttempts,
              let host = currentHost,
              let port = currentPort else {
            connectionState = .failed(NetworkError.reconnectionFailed)
            return
        }
        
        stopReconnectionTimer()
        
        let delay = min(pow(2.0, Double(reconnectionAttempts)), 30.0)
        reconnectionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.attemptReconnection(host: host, port: port)
        }
    }
    
    private func attemptReconnection(host: String, port: UInt16) {
        guard reconnectionAttempts < maxReconnectionAttempts else {
            connectionState = .failed(NetworkError.reconnectionFailed)
            return
        }
        
        reconnectionAttempts += 1
        connect(to: host, port: port)
    }
    
    private func stopReconnectionTimer() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
    }
    
    private func resetReconnectionState() {
        reconnectionAttempts = 0
        stopReconnectionTimer()
    }
}

enum NetworkError: LocalizedError {
    case unknownState
    case reconnectionFailed
    case connectionTimeout
    case invalidEndpoint
    
    var errorDescription: String? {
        switch self {
        case .unknownState:
            return "Unknown network connection state"
        case .reconnectionFailed:
            return "Failed to reconnect after multiple attempts"
        case .connectionTimeout:
            return "Connection timed out"
        case .invalidEndpoint:
            return "Invalid network endpoint"
        }
    }
}