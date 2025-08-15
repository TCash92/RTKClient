import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var viewModel: GNSSViewModel
    @State private var selectedConnectionType: ConnectionType = .bluetooth
    @State private var showingBluetoothDevices = false
    @State private var networkHost = ""
    @State private var networkPort = "2948"
    
    enum ConnectionType: String, CaseIterable {
        case bluetooth = "Bluetooth"
        case network = "Network"
        
        var icon: String {
            switch self {
            case .bluetooth: return "antenna.radiowaves.left.and.right"
            case .network: return "wifi"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                ConnectionTypePicker()
                
                switch selectedConnectionType {
                case .bluetooth:
                    BluetoothConnectionSection()
                case .network:
                    NetworkConnectionSection()
                }
                
                Spacer()
                
                DisconnectButton()
            }
            .padding()
            .navigationTitle("Connect Device")
        }
        .sheet(isPresented: $showingBluetoothDevices) {
            BluetoothDeviceListView()
                .environmentObject(viewModel)
        }
    }
    
    @ViewBuilder
    private func ConnectionTypePicker() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connection Type")
                .font(.headline)
            
            Picker("Connection Type", selection: $selectedConnectionType) {
                ForEach(ConnectionType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.icon)
                        Text(type.rawValue)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    @ViewBuilder
    private func BluetoothConnectionSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Bluetooth Connection")
                    .font(.headline)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ConnectionStatusRow(
                    title: "Bluetooth Status",
                    status: viewModel.bluetoothState.description,
                    color: bluetoothStatusColor
                )
                
                if let deviceName = viewModel.bluetoothManager.connectedDeviceName {
                    ConnectionStatusRow(
                        title: "Connected Device",
                        status: deviceName,
                        color: .green
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Button(action: {
                if viewModel.bluetoothManager.isConnected {
                    viewModel.bluetoothManager.disconnect()
                } else {
                    showingBluetoothDevices = true
                }
            }) {
                HStack {
                    Image(systemName: viewModel.bluetoothManager.isConnected ? "minus.circle" : "plus.circle")
                    Text(viewModel.bluetoothManager.isConnected ? "Disconnect" : "Scan for Devices")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.bluetoothManager.isConnected ? Color.red : Color.blue)
                .cornerRadius(12)
            }
        }
    }
    
    @ViewBuilder
    private func NetworkConnectionSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Network Connection")
                    .font(.headline)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ConnectionStatusRow(
                    title: "Network Status",
                    status: viewModel.networkState.description,
                    color: networkStatusColor
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Host Address")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("192.168.1.100", text: $networkHost)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Port")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("2948", text: $networkPort)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
            }
            
            Button(action: {
                if viewModel.networkManager.isConnected {
                    viewModel.networkManager.disconnect()
                } else {
                    connectNetwork()
                }
            }) {
                HStack {
                    Image(systemName: viewModel.networkManager.isConnected ? "minus.circle" : "plus.circle")
                    Text(viewModel.networkManager.isConnected ? "Disconnect" : "Connect")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.networkManager.isConnected ? Color.red : (canConnectNetwork ? Color.green : Color.gray))
                .cornerRadius(12)
            }
            .disabled(!canConnectNetwork && !viewModel.networkManager.isConnected)
        }
    }
    
    @ViewBuilder
    private func DisconnectButton() -> some View {
        if viewModel.connectionStatus != .disconnected {
            Button(action: {
                viewModel.disconnectAll()
            }) {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("Disconnect All")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }
        }
    }
    
    private func connectNetwork() {
        guard let port = UInt16(networkPort) else { return }
        viewModel.connectNetwork(host: networkHost, port: port)
    }
    
    private var canConnectNetwork: Bool {
        !networkHost.isEmpty && !networkPort.isEmpty && UInt16(networkPort) != nil
    }
    
    private var bluetoothStatusColor: Color {
        switch viewModel.bluetoothState {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .gray
        case .disconnecting: return .orange
        case .failed: return .red
        }
    }
    
    private var networkStatusColor: Color {
        switch viewModel.networkState {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .gray
        case .failed: return .red
        }
    }
}

struct ConnectionStatusRow: View {
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(status)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct BluetoothDeviceListView: View {
    @EnvironmentObject var viewModel: GNSSViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.bluetoothManager.discoveredDevices.isEmpty {
                    VStack(spacing: 16) {
                        if viewModel.bluetoothManager.isScanning {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Scanning for RTK devices...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        } else {
                            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No devices found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Make sure your RTK device is powered on and in pairing mode")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.bluetoothManager.discoveredDevices) { device in
                        DeviceRow(device: device) {
                            viewModel.connectBluetooth(to: device)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("RTK Devices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.bluetoothManager.isScanning ? "Stop" : "Scan") {
                        if viewModel.bluetoothManager.isScanning {
                            viewModel.bluetoothManager.stopScanning()
                        } else {
                            viewModel.bluetoothManager.startScanning()
                        }
                    }
                }
            }
        }
        .onAppear {
            if !viewModel.bluetoothManager.isScanning {
                viewModel.bluetoothManager.startScanning()
            }
        }
        .onDisappear {
            viewModel.bluetoothManager.stopScanning()
        }
    }
}

struct DeviceRow: View {
    let device: DiscoveredDevice
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(device.peripheral.identifier.uuidString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(device.rssi) dBm")
                        .font(.caption)
                        .foregroundColor(rssiColor)
                    
                    Image(systemName: signalStrengthIcon)
                        .foregroundColor(rssiColor)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private var rssiColor: Color {
        if device.rssi > -50 {
            return .green
        } else if device.rssi > -70 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var signalStrengthIcon: String {
        if device.rssi > -50 {
            return "wifi"
        } else if device.rssi > -70 {
            return "wifi"
        } else {
            return "wifi.slash"
        }
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        let container = DIContainer()
        let viewModel = container.makeGNSSViewModel()
        
        ConnectionView()
            .environmentObject(viewModel)
    }
}