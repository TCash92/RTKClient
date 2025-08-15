import Foundation
import Combine

protocol NMEAParserProtocol {
    func parse(_ data: Data) -> [NMEASentence]
    func parseGGA(_ sentence: String) -> GGASentence?
    func parseRMC(_ sentence: String) -> RMCSentence?
    func parseGSA(_ sentence: String) -> GSASentence?
    func validateChecksum(_ sentence: String) -> Bool
}

protocol NTRIPClientProtocol: ObservableObject {
    var isConnected: Bool { get }
    var connectionState: NTRIPConnectionState { get }
    var rtcmDataStream: AnyPublisher<Data, Never> { get }
    
    func connect(host: String, port: Int, mountpoint: String, username: String, password: String)
    func disconnect()
    func sendGGA(_ sentence: String)
}

enum NTRIPConnectionState {
    case disconnected
    case connecting
    case authenticating
    case connected
    case failed(Error)
    
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .authenticating: return "Authenticating"
        case .connected: return "Connected"
        case .failed(let error): return "Failed: \(error.localizedDescription)"
        }
    }
}

protocol GNSSRepositoryProtocol {
    func savePosition(_ position: GNSSPosition)
    func getRecentPositions(limit: Int) -> [GNSSPosition]
    func clearHistory()
}