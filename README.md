# RTK Client for iOS

A professional-grade iOS application for connecting to SparkFun RTK receivers and NTRIP correction services, delivering centimeter-level positioning accuracy for surveying and precision applications.

## Features

### Core Functionality
- **Dual Connectivity**: Bluetooth Low Energy and TCP/WiFi connections to SparkFun RTK devices
- **NTRIP Client**: Full NTRIP v1.0 protocol implementation with automatic reconnection
- **NMEA Parsing**: High-performance parser supporting GGA, GSA, GSV, RMC, VTG sentences
- **Real-time Processing**: 4-10Hz update rates with sub-second latency
- **RTK Integration**: RTCM 3.x correction data processing for centimeter accuracy

### User Interface
- **SwiftUI Dashboard**: Real-time position display with fix quality indicators
- **Connection Manager**: Device discovery and connection status monitoring
- **Settings Screen**: Secure credential storage and configuration management
- **Minimalist Design**: Clean, professional interface optimized for field use

### Advanced Features
- **Background Operation**: Persistent connections using iOS background modes
- **State Restoration**: Automatic reconnection after app restart or device reboot
- **Data Persistence**: Core Data storage for position history
- **Battery Optimization**: Adaptive power management based on device state

## Architecture

### MVVM + Clean Architecture
```
RTKClient/
├── Domain/              # Business logic and models
│   ├── Models/          # GNSSPosition, NMEASentence
│   └── Protocols/       # Service interfaces
├── Infrastructure/     # Hardware and network interfaces
│   ├── Bluetooth/      # CoreBluetooth RTK manager
│   ├── Network/        # TCP client implementation
│   ├── NTRIP/          # NTRIP protocol client
│   ├── Parsing/        # NMEA sentence parser
│   └── Repository/     # Core Data persistence
└── Presentation/       # UI and ViewModels
    ├── Views/          # SwiftUI interface
    └── ViewModels/     # Reactive state management
```

### Key Components

#### RTKBluetoothManager
- Nordic UART Service (6E400001-B5A3-F393-E0A9-E50E24DCCA9E) integration
- Automatic state restoration with unique identifier
- Exponential backoff reconnection strategy
- Background mode compatibility

#### RTKNTRIPClient
- HTTP Basic authentication with secure credential storage
- Background URLSession for persistent streaming
- GGA sentence transmission every 10 seconds
- SOURCETABLE parsing and mountpoint validation

#### RTKNMEAParser
- Stream-based parsing with 8KB circular buffer
- CRC-24Q checksum validation
- Coordinate conversion (DDMM.mmm to decimal degrees)
- Thread-safe operation on background queues

## Setup and Installation

### Requirements
- iOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- SparkFun RTK device (Surveyor, Express, Facet)

### Dependencies
- **mgrs-ios**: MGRS/UTM coordinate system support
- **CoreBluetooth**: BLE device communication
- **Network.framework**: TCP connectivity
- **Combine**: Reactive programming framework

### Configuration

1. **Info.plist Setup**
```xml
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>location</string>
    <string>fetch</string>
</array>
```

2. **SparkFun Device Configuration**
   - Enable BLE mode via SparkFun web interface
   - Configure NMEA output: GGA, GSA, RMC, VTG at 4Hz
   - Set RTK mode: Rover with RTCM input

3. **NTRIP Service Setup**
   - Obtain credentials from NTRIP provider
   - Configure host, port, mountpoint in Settings
   - Test connection before field deployment

## Usage

### Bluetooth Connection
1. Navigate to **Connect** tab
2. Select **Bluetooth** connection type
3. Tap **Scan for Devices**
4. Select your SparkFun RTK device from the list
5. Monitor connection status on Dashboard

### NTRIP Configuration
1. Open **Settings** tab
2. Enter NTRIP server details:
   - Host: ntrip.provider.com
   - Port: 2101
   - Mountpoint: RTCM3_1
   - Username/Password: Your credentials
3. Tap **Test Connection** to verify
4. Enable **Auto-connect NTRIP** for automatic startup

### Network (TCP) Connection
1. Configure SparkFun device as WiFi hotspot or connect to local network
2. Select **Network** connection type
3. Enter device IP address and port (typically 2948)
4. Tap **Connect**

## Performance Specifications

### Accuracy Targets
- **RTK Fixed**: ±2cm horizontal, ±3cm vertical
- **RTK Float**: ±1m horizontal, ±2m vertical
- **DGPS**: ±3m horizontal, ±5m vertical

### System Performance
- **Update Rate**: 2-10Hz (configurable)
- **Latency**: <500ms end-to-end
- **CPU Usage**: <10% during normal operation
- **Memory**: <50MB active footprint
- **Battery Life**: 8+ hours continuous operation

### Connectivity Range
- **Bluetooth LE**: 10-30m line of sight
- **WiFi/TCP**: 50-100m with infrastructure
- **NTRIP**: Internet connectivity required

## Testing

### Unit Tests
```bash
# Run unit tests
xcodebuild test -scheme RTKClient -destination 'platform=iOS Simulator,name=iPhone 15'

# Generate code coverage
xcodebuild test -scheme RTKClient -enableCodeCoverage YES
```

### Integration Testing
- Real hardware testing with SparkFun RTK Surveyor
- NTRIP service validation with known base stations
- Background mode testing with device sleep/wake cycles
- Battery life measurement under various usage patterns

## Deployment

### App Store Configuration
- **Bundle Identifier**: com.yourcompany.rtkclient
- **Version**: 1.0.0
- **Minimum iOS**: 14.0
- **Device Compatibility**: iPhone, iPad

### Required Permissions
- **Bluetooth**: "RTK Client needs Bluetooth to connect to RTK receivers"
- **Location**: "RTK Client requires location access for positioning display"
- **Background App Refresh**: Enabled for continuous operation

## License and Attribution

### RTKLIB License (BSD 2-Clause)
This application incorporates RTKLIB for RTCM processing:
```
Copyright (c) 2007-2013, T. Takasu
All rights reserved.
```

### Third-Party Libraries
- **mgrs-ios**: MIT License - MGRS coordinate system support

## Troubleshooting

### Common Issues

**Bluetooth Connection Fails**
- Verify device is in BLE mode (not Bluetooth Classic)
- Check device is within 10-30m range
- Restart Bluetooth on iOS device
- Ensure device is not connected to other applications

**NTRIP Authentication Errors**
- Verify credentials with NTRIP provider
- Check network connectivity
- Confirm mountpoint availability
- Test with different NTRIP client (e.g., SW Maps)

**Poor RTK Performance**
- Check correction age (<3 seconds for optimal performance)
- Verify clear sky view (>8 satellites)
- Ensure proper antenna placement
- Monitor HDOP values (<2.0 recommended)

**Background Operation Issues**
- Enable Background App Refresh in iOS Settings
- Verify Location Services permissions
- Check battery optimization settings
- Monitor for iOS 13+ BGTaskScheduler limitations

## Support and Documentation

### Resources
- [SparkFun RTK Product Documentation](https://learn.sparkfun.com/tutorials/what-is-gps-rtk)
- [NTRIP Protocol Specification](http://software.rtcm-navi.org/export/HEAD/ntrip/trunk/BNC/src/bnchelp.html)
- [u-blox F9P Integration Manual](https://www.u-blox.com/en/docs/UBX-18010802)

### Development Team
- Architecture: MVVM + Clean Architecture
- UI Framework: SwiftUI + UIKit hybrid
- Networking: Network.framework + URLSession
- Persistence: Core Data + Keychain Services

For technical support and feature requests, please refer to the project repository or contact the development team.

---

**RTK Client v1.0.0** - Professional RTK positioning for iOS