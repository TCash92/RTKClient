import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: GNSSViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ConnectionStatusCard()
                    
                    if let position = viewModel.currentPosition {
                        PositionCard(position: position)
                        AccuracyCard(position: position)
                        SatelliteCard(position: position)
                    } else {
                        NoPositionCard()
                    }
                    
                    DataStreamCard()
                }
                .padding()
            }
            .navigationTitle("RTK Client")
            .refreshable {
                // Pull to refresh functionality
            }
        }
        .environmentObject(viewModel)
    }
}

struct ConnectionStatusCard: View {
    @EnvironmentObject var viewModel: GNSSViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.title2)
                
                Text("Connection Status")
                    .font(.headline)
                
                Spacer()
                
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                    .opacity(viewModel.isReceivingData ? 1.0 : 0.3)
            }
            
            Text(viewModel.connectionStatus.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if viewModel.correctionAge > 0 {
                Text("Correction Age: \(String(format: "%.1f", viewModel.correctionAge))s")
                    .font(.caption)
                    .foregroundColor(correctionAgeColor)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statusIcon: String {
        switch viewModel.connectionStatus {
        case .disconnected:
            return "wifi.slash"
        case .bluetooth:
            return "antenna.radiowaves.left.and.right"
        case .network:
            return "wifi"
        case .ntripOnly:
            return "globe"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.connectionStatus {
        case .disconnected:
            return .red
        case .bluetooth, .network, .ntripOnly:
            return .green
        }
    }
    
    private var correctionAgeColor: Color {
        if viewModel.correctionAge < 3 {
            return .green
        } else if viewModel.correctionAge < 10 {
            return .orange
        } else {
            return .red
        }
    }
}

struct PositionCard: View {
    let position: GNSSPosition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Position")
                    .font(.headline)
                
                Spacer()
                
                FixQualityBadge(fixQuality: position.fixQuality)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Latitude:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.8f°", position.latitude))
                        .font(.subheadline.monospaced())
                }
                
                HStack {
                    Text("Longitude:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.8f°", position.longitude))
                        .font(.subheadline.monospaced())
                }
                
                HStack {
                    Text("Altitude:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.2f m", position.altitude))
                        .font(.subheadline.monospaced())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AccuracyCard: View {
    let position: GNSSPosition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Accuracy")
                    .font(.headline)
                
                Spacer()
                
                Text(position.fixQuality.accuracy)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accuracyColor.opacity(0.2))
                    .foregroundColor(accuracyColor)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Horizontal:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "±%.2f m", position.horizontalAccuracy))
                        .font(.subheadline.monospaced())
                }
                
                HStack {
                    Text("Vertical:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "±%.2f m", position.verticalAccuracy))
                        .font(.subheadline.monospaced())
                }
                
                if let hdop = position.hdop {
                    HStack {
                        Text("HDOP:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f", hdop))
                            .font(.subheadline.monospaced())
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var accuracyColor: Color {
        switch position.fixQuality {
        case .rtk:
            return .green
        case .rtkFloat:
            return .orange
        case .dgps:
            return .yellow
        default:
            return .red
        }
    }
}

struct SatelliteCard: View {
    let position: GNSSPosition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dot.radiowaves.up.forward")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Satellites")
                    .font(.headline)
                
                Spacer()
                
                Text("\(position.satelliteCount)")
                    .font(.title2.bold())
                    .foregroundColor(satelliteCountColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let pdop = position.pdop {
                    HStack {
                        Text("PDOP:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f", pdop))
                            .font(.subheadline.monospaced())
                    }
                }
                
                if let vdop = position.vdop {
                    HStack {
                        Text("VDOP:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f", vdop))
                            .font(.subheadline.monospaced())
                    }
                }
                
                HStack {
                    Text("Last Update:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(position.timestamp, style: .time)
                        .font(.subheadline.monospaced())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var satelliteCountColor: Color {
        if position.satelliteCount >= 8 {
            return .green
        } else if position.satelliteCount >= 5 {
            return .orange
        } else {
            return .red
        }
    }
}

struct DataStreamCard: View {
    @EnvironmentObject var viewModel: GNSSViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Data Stream")
                    .font(.headline)
                
                Spacer()
                
                Circle()
                    .fill(viewModel.isReceivingData ? .green : .red)
                    .frame(width: 12, height: 12)
            }
            
            HStack {
                Text("Data Rate:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f Hz", viewModel.dataRate))
                    .font(.subheadline.monospaced())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct NoPositionCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Position Data")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Connect to an RTK receiver to start receiving position data")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FixQualityBadge: View {
    let fixQuality: GNSSPosition.FixQuality
    
    var body: some View {
        Text(fixQuality.description)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.2))
            .foregroundColor(badgeColor)
            .cornerRadius(8)
    }
    
    private var badgeColor: Color {
        switch fixQuality {
        case .rtk:
            return .green
        case .rtkFloat:
            return .orange
        case .dgps, .gps:
            return .yellow
        default:
            return .red
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let container = DIContainer()
        let viewModel = container.makeGNSSViewModel()
        
        DashboardView()
            .environmentObject(viewModel)
    }
}