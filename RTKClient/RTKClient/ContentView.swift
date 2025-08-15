import SwiftUI

struct ContentView: View {
    @EnvironmentObject var container: DIContainer
    @StateObject private var gnssViewModel: GNSSViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @State private var selectedTab = 0
    
    init() {
        let tempContainer = DIContainer()
        let gnssVM = tempContainer.makeGNSSViewModel()
        let settingsVM = tempContainer.makeSettingsViewModel()
        
        _gnssViewModel = StateObject(wrappedValue: gnssVM)
        _settingsViewModel = StateObject(wrappedValue: settingsVM)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environmentObject(gnssViewModel)
                .tabItem {
                    Image(systemName: "location")
                    Text("Dashboard")
                }
                .tag(0)
            
            ConnectionView()
                .environmentObject(gnssViewModel)
                .tabItem {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Connect")
                }
                .tag(1)
            
            SettingsView()
                .environmentObject(settingsViewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .onReceive(container.objectWillChange) { _ in
            _gnssViewModel.wrappedValue = container.makeGNSSViewModel()
            _settingsViewModel.wrappedValue = container.makeSettingsViewModel()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DIContainer())
    }
}