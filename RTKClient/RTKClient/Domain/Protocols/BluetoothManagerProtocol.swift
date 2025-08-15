import Foundation
import Combine
import CoreBluetooth

protocol BluetoothManagerProtocol: ObservableObject {
    var isScanning: Bool { get }
    var isConnected: Bool { get }
    var connectedDeviceName: String? { get }
    var discoveredDevices: [DiscoveredDevice] { get }
    var connectionState: ConnectionState { get }
    var dataStream: AnyPublisher<Data, Never> { get }
    
    func startScanning()
    func stopScanning()
    func connect(to device: DiscoveredDevice)
    func disconnect()
    func send(data: Data)
}

struct DiscoveredDevice: Identifiable, Equatable {
    let id = UUID()
    let peripheral: CBPeripheral
    let name: String
    let rssi: Int
    let advertisementData: [String: Any]
    
    static func == (lhs: DiscoveredDevice, rhs: DiscoveredDevice) -> Bool {
        return lhs.peripheral.identifier == rhs.peripheral.identifier
    }
}

enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case failed(Error)
    
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnecting: return "Disconnecting"
        case .failed(let error): return "Failed: \(error.localizedDescription)"
        }
    }
}