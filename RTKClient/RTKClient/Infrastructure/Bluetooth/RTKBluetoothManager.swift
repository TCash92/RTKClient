import Foundation
import Combine
import CoreBluetooth

class RTKBluetoothManager: NSObject, BluetoothManagerProtocol, ObservableObject {
    
    static let nordicUARTServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let nordicUARTRXCharacteristicUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    static let nordicUARTTXCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    static let restoreIdentifier = "com.rtkClient.bluetooth.central"
    
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var connectedDeviceName: String?
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var connectionState: ConnectionState = .disconnected
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var rxCharacteristic: CBCharacteristic?
    private var txCharacteristic: CBCharacteristic?
    
    private let dataSubject = PassthroughSubject<Data, Never>()
    var dataStream: AnyPublisher<Data, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    private var reconnectionTimer: Timer?
    private var reconnectionAttempts = 0
    private let maxReconnectionAttempts = 5
    
    override init() {
        super.init()
        setupCentralManager()
    }
    
    private func setupCentralManager() {
        let options: [String: Any] = [
            CBCentralManagerOptionRestoreIdentifierKey: Self.restoreIdentifier,
            CBCentralManagerOptionShowPowerAlertKey: true
        ]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        
        discoveredDevices.removeAll()
        isScanning = true
        
        let services = [Self.nordicUARTServiceUUID]
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ]
        
        centralManager.scanForPeripherals(withServices: services, options: options)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        guard isScanning else { return }
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect(to device: DiscoveredDevice) {
        stopScanning()
        connectionState = .connecting
        connectedPeripheral = device.peripheral
        
        let options: [String: Any] = [
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
            CBConnectPeripheralOptionNotifyOnNotificationKey: true
        ]
        
        centralManager.connect(device.peripheral, options: options)
    }
    
    func disconnect() {
        guard let peripheral = connectedPeripheral else { return }
        connectionState = .disconnecting
        centralManager.cancelPeripheralConnection(peripheral)
        stopReconnectionTimer()
    }
    
    func send(data: Data) {
        guard let peripheral = connectedPeripheral,
              let characteristic = rxCharacteristic,
              peripheral.state == .connected else { return }
        
        let maxChunkSize = peripheral.maximumWriteValueLength(for: .withoutResponse)
        let chunkSize = min(maxChunkSize, 20)
        
        for i in stride(from: 0, to: data.count, by: chunkSize) {
            let endIndex = min(i + chunkSize, data.count)
            let chunk = data.subdata(in: i..<endIndex)
            peripheral.writeValue(chunk, for: characteristic, type: .withoutResponse)
        }
    }
    
    private func startReconnectionTimer() {
        stopReconnectionTimer()
        
        guard reconnectionAttempts < maxReconnectionAttempts else {
            connectionState = .failed(BluetoothError.reconnectionFailed)
            return
        }
        
        let delay = min(pow(2.0, Double(reconnectionAttempts)), 30.0)
        reconnectionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.attemptReconnection()
        }
    }
    
    private func stopReconnectionTimer() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
    }
    
    private func attemptReconnection() {
        guard let peripheral = connectedPeripheral else { return }
        
        reconnectionAttempts += 1
        connectionState = .connecting
        centralManager.connect(peripheral, options: nil)
    }
    
    private func resetReconnectionState() {
        reconnectionAttempts = 0
        stopReconnectionTimer()
    }
}

extension RTKBluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            break
        case .poweredOff:
            connectionState = .disconnected
            isConnected = false
        case .resetting:
            connectionState = .disconnected
            isConnected = false
        case .unauthorized:
            connectionState = .failed(BluetoothError.unauthorized)
        case .unsupported:
            connectionState = .failed(BluetoothError.unsupported)
        case .unknown:
            connectionState = .failed(BluetoothError.unknown)
        @unknown default:
            connectionState = .failed(BluetoothError.unknown)
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                peripheral.delegate = self
                if peripheral.state == .connected {
                    connectedPeripheral = peripheral
                    peripheral.discoverServices([Self.nordicUARTServiceUUID])
                } else {
                    centralManager.connect(peripheral, options: nil)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown Device"
        
        let device = DiscoveredDevice(
            peripheral: peripheral,
            name: deviceName,
            rssi: RSSI.intValue,
            advertisementData: advertisementData
        )
        
        if !discoveredDevices.contains(device) {
            discoveredDevices.append(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        connectionState = .connected
        isConnected = true
        connectedDeviceName = peripheral.name
        resetReconnectionState()
        
        peripheral.discoverServices([Self.nordicUARTServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionState = .failed(error ?? BluetoothError.connectionFailed)
        isConnected = false
        startReconnectionTimer()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionState = .disconnected
        isConnected = false
        connectedDeviceName = nil
        rxCharacteristic = nil
        txCharacteristic = nil
        
        if error != nil {
            startReconnectionTimer()
        } else {
            resetReconnectionState()
        }
    }
}

extension RTKBluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil,
              let services = peripheral.services else {
            connectionState = .failed(error ?? BluetoothError.serviceDiscoveryFailed)
            return
        }
        
        for service in services {
            if service.uuid == Self.nordicUARTServiceUUID {
                peripheral.discoverCharacteristics([
                    Self.nordicUARTRXCharacteristicUUID,
                    Self.nordicUARTTXCharacteristicUUID
                ], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil,
              let characteristics = service.characteristics else {
            connectionState = .failed(error ?? BluetoothError.characteristicDiscoveryFailed)
            return
        }
        
        for characteristic in characteristics {
            switch characteristic.uuid {
            case Self.nordicUARTRXCharacteristicUUID:
                rxCharacteristic = characteristic
            case Self.nordicUARTTXCharacteristicUUID:
                txCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil,
              let data = characteristic.value,
              !data.isEmpty else { return }
        
        dataSubject.send(data)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            connectionState = .failed(error!)
            return
        }
    }
}

enum BluetoothError: LocalizedError {
    case unauthorized
    case unsupported
    case unknown
    case connectionFailed
    case reconnectionFailed
    case serviceDiscoveryFailed
    case characteristicDiscoveryFailed
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Bluetooth access not authorized"
        case .unsupported:
            return "Bluetooth not supported on this device"
        case .unknown:
            return "Unknown Bluetooth error"
        case .connectionFailed:
            return "Failed to connect to device"
        case .reconnectionFailed:
            return "Failed to reconnect after multiple attempts"
        case .serviceDiscoveryFailed:
            return "Failed to discover required services"
        case .characteristicDiscoveryFailed:
            return "Failed to discover required characteristics"
        }
    }
}