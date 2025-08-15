import Foundation
import Combine

class DIContainer: ObservableObject {
    
    private let bluetoothManager: BluetoothManagerProtocol
    private let networkManager: NetworkManagerProtocol
    private let nmeaParser: NMEAParserProtocol
    private let ntripClient: NTRIPClientProtocol
    private let gnssRepository: GNSSRepositoryProtocol
    
    init(
        bluetoothManager: BluetoothManagerProtocol? = nil,
        networkManager: NetworkManagerProtocol? = nil,
        nmeaParser: NMEAParserProtocol? = nil,
        ntripClient: NTRIPClientProtocol? = nil,
        gnssRepository: GNSSRepositoryProtocol? = nil
    ) {
        self.bluetoothManager = bluetoothManager ?? RTKBluetoothManager()
        self.networkManager = networkManager ?? RTKNetworkManager()
        self.nmeaParser = nmeaParser ?? RTKNMEAParser()
        self.ntripClient = ntripClient ?? RTKNTRIPClient()
        self.gnssRepository = gnssRepository ?? GNSSRepository()
    }
    
    func makeGNSSViewModel() -> GNSSViewModel {
        return GNSSViewModel(
            bluetoothManager: bluetoothManager,
            networkManager: networkManager,
            nmeaParser: nmeaParser,
            ntripClient: ntripClient,
            gnssRepository: gnssRepository
        )
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(
            bluetoothManager: bluetoothManager,
            ntripClient: ntripClient
        )
    }
}