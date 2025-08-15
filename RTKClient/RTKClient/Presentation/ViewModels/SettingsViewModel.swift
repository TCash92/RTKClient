import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    
    @Published var ntripHost = ""
    @Published var ntripPort = "2101"
    @Published var ntripMountpoint = ""
    @Published var ntripUsername = ""
    @Published var ntripPassword = ""
    
    @Published var networkHost = ""
    @Published var networkPort = "2948"
    
    @Published var autoConnectBluetooth = true
    @Published var autoConnectNTRIP = false
    @Published var backgroundUpdates = true
    
    @Published var selectedConnectionType: ConnectionType = .bluetooth
    
    private let bluetoothManager: BluetoothManagerProtocol
    private let ntripClient: NTRIPClientProtocol
    private let userDefaults = UserDefaults.standard
    
    enum ConnectionType: String, CaseIterable {
        case bluetooth = "Bluetooth"
        case network = "Network"
        case both = "Both"
        
        var description: String {
            return self.rawValue
        }
    }
    
    init(bluetoothManager: BluetoothManagerProtocol, ntripClient: NTRIPClientProtocol) {
        self.bluetoothManager = bluetoothManager
        self.ntripClient = ntripClient
        
        loadSettings()
    }
    
    func saveSettings() {
        userDefaults.set(ntripHost, forKey: "ntripHost")
        userDefaults.set(ntripPort, forKey: "ntripPort")
        userDefaults.set(ntripMountpoint, forKey: "ntripMountpoint")
        userDefaults.set(ntripUsername, forKey: "ntripUsername")
        
        userDefaults.set(networkHost, forKey: "networkHost")
        userDefaults.set(networkPort, forKey: "networkPort")
        
        userDefaults.set(autoConnectBluetooth, forKey: "autoConnectBluetooth")
        userDefaults.set(autoConnectNTRIP, forKey: "autoConnectNTRIP")
        userDefaults.set(backgroundUpdates, forKey: "backgroundUpdates")
        userDefaults.set(selectedConnectionType.rawValue, forKey: "selectedConnectionType")
        
        saveNTRIPPasswordToKeychain()
    }
    
    private func loadSettings() {
        ntripHost = userDefaults.string(forKey: "ntripHost") ?? ""
        ntripPort = userDefaults.string(forKey: "ntripPort") ?? "2101"
        ntripMountpoint = userDefaults.string(forKey: "ntripMountpoint") ?? ""
        ntripUsername = userDefaults.string(forKey: "ntripUsername") ?? ""
        
        networkHost = userDefaults.string(forKey: "networkHost") ?? ""
        networkPort = userDefaults.string(forKey: "networkPort") ?? "2948"
        
        autoConnectBluetooth = userDefaults.bool(forKey: "autoConnectBluetooth")
        autoConnectNTRIP = userDefaults.bool(forKey: "autoConnectNTRIP")
        backgroundUpdates = userDefaults.bool(forKey: "backgroundUpdates")
        
        if let connectionTypeString = userDefaults.string(forKey: "selectedConnectionType"),
           let connectionType = ConnectionType(rawValue: connectionTypeString) {
            selectedConnectionType = connectionType
        }
        
        loadNTRIPPasswordFromKeychain()
    }
    
    private func saveNTRIPPasswordToKeychain() {
        guard !ntripPassword.isEmpty else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "RTKClient",
            kSecAttrAccount as String: "ntripPassword"
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "RTKClient",
            kSecAttrAccount as String: "ntripPassword",
            kSecValueData as String: ntripPassword.data(using: .utf8) ?? Data()
        ]
        
        SecItemAdd(addQuery as CFDictionary, nil)
    }
    
    private func loadNTRIPPasswordFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "RTKClient",
            kSecAttrAccount as String: "ntripPassword",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let password = String(data: data, encoding: .utf8) {
            ntripPassword = password
        }
    }
    
    func testNTRIPConnection() {
        guard !ntripHost.isEmpty,
              let port = Int(ntripPort),
              !ntripMountpoint.isEmpty,
              !ntripUsername.isEmpty,
              !ntripPassword.isEmpty else { return }
        
        ntripClient.connect(
            host: ntripHost,
            port: port,
            mountpoint: ntripMountpoint,
            username: ntripUsername,
            password: ntripPassword
        )
    }
    
    func resetToDefaults() {
        ntripHost = ""
        ntripPort = "2101"
        ntripMountpoint = ""
        ntripUsername = ""
        ntripPassword = ""
        
        networkHost = ""
        networkPort = "2948"
        
        autoConnectBluetooth = true
        autoConnectNTRIP = false
        backgroundUpdates = true
        selectedConnectionType = .bluetooth
        
        saveSettings()
    }
    
    var isNTRIPConfigurationValid: Bool {
        return !ntripHost.isEmpty &&
               !ntripPort.isEmpty &&
               Int(ntripPort) != nil &&
               !ntripMountpoint.isEmpty &&
               !ntripUsername.isEmpty &&
               !ntripPassword.isEmpty
    }
    
    var isNetworkConfigurationValid: Bool {
        return !networkHost.isEmpty &&
               !networkPort.isEmpty &&
               UInt16(networkPort) != nil
    }
}