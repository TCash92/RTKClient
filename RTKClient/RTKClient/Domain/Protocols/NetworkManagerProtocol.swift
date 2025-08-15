import Foundation
import Combine
import Network

protocol NetworkManagerProtocol: ObservableObject {
    var isConnected: Bool { get }
    var connectionState: NetworkConnectionState { get }
    var dataStream: AnyPublisher<Data, Never> { get }
    
    func connect(to host: String, port: UInt16)
    func disconnect()
    func send(data: Data)
}

enum NetworkConnectionState {
    case disconnected
    case connecting
    case connected
    case failed(Error)
    
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .failed(let error): return "Failed: \(error.localizedDescription)"
        }
    }
}