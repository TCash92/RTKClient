import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var showingNTRIPTest = false
    @State private var ntripTestResult: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                NTRIPSection()
                NetworkSection()
                BehaviorSection()
                AboutSection()
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveSettings()
                    }
                }
            }
        }
        .alert("NTRIP Test Result", isPresented: $showingNTRIPTest) {
            Button("OK") { }
        } message: {
            Text(ntripTestResult)
        }
    }
    
    @ViewBuilder
    private func NTRIPSection() -> some View {
        Section(header: Text("NTRIP Configuration")) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Host")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("ntrip.example.com", text: $viewModel.ntripHost)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Port")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("2101", text: $viewModel.ntripPort)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Mountpoint")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("RTCM3_1", text: $viewModel.ntripMountpoint)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("username", text: $viewModel.ntripUsername)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                SecureField("password", text: $viewModel.ntripPassword)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(action: testNTRIPConnection) {
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Test Connection")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isNTRIPConfigurationValid ? Color.blue : Color.gray)
                .cornerRadius(8)
            }
            .disabled(!viewModel.isNTRIPConfigurationValid)
            .listRowBackground(Color.clear)
        }
    }
    
    @ViewBuilder
    private func NetworkSection() -> some View {
        Section(header: Text("Network Configuration")) {
            VStack(alignment: .leading, spacing: 8) {
                Text("TCP Host")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("192.168.1.100", text: $viewModel.networkHost)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numbersAndPunctuation)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("TCP Port")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("2948", text: $viewModel.networkPort)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }
        }
    }
    
    @ViewBuilder
    private func BehaviorSection() -> some View {
        Section(header: Text("Behavior")) {
            Toggle("Auto-connect Bluetooth", isOn: $viewModel.autoConnectBluetooth)
            Toggle("Auto-connect NTRIP", isOn: $viewModel.autoConnectNTRIP)
            Toggle("Background Updates", isOn: $viewModel.backgroundUpdates)
            
            Picker("Connection Type", selection: $viewModel.selectedConnectionType) {
                ForEach(SettingsViewModel.ConnectionType.allCases, id: \.self) { type in
                    Text(type.description).tag(type)
                }
            }
        }
    }
    
    @ViewBuilder
    private func AboutSection() -> some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("RTKLIB License")
                Spacer()
                Text("BSD 2-Clause")
                    .foregroundColor(.secondary)
            }
            
            Button("Reset to Defaults") {
                viewModel.resetToDefaults()
            }
            .foregroundColor(.red)
            
            Link("Support & Documentation", destination: URL(string: "https://github.com/example/rtkclient")!)
        }
    }
    
    private func testNTRIPConnection() {
        viewModel.testNTRIPConnection()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Simulate test result - in real implementation, observe the NTRIP client state
            if viewModel.isNTRIPConfigurationValid {
                ntripTestResult = "NTRIP connection test successful!"
            } else {
                ntripTestResult = "NTRIP connection test failed. Please check your settings."
            }
            showingNTRIPTest = true
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let container = DIContainer()
        let viewModel = container.makeSettingsViewModel()
        
        SettingsView()
            .environmentObject(viewModel)
    }
}