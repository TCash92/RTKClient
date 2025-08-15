To test and view the iOS RTK Client app, you'll need to follow these steps:

  1. Prerequisites

  Required Software

  - macOS (Monterey 12.0 or later recommended)
  - Xcode 15.0+ (free from Mac App Store)
  - Apple Developer Account (free for testing on your own devices)

  Hardware Options

  - iOS Simulator (included with Xcode) - for UI testing only
  - Physical iPhone/iPad (iOS 14.0+) - required for Bluetooth testing
  - SparkFun RTK Device - for real RTK testing

  2. Opening the Project in Xcode

  # Navigate to the project directory
  cd "/mnt/c/Users/tyson/Documents/New folder (41)/RTKClient"

  # Open in Xcode (on macOS)
  open RTKClient.xcodeproj

  # Or use Xcode's File > Open menu

  3. Building and Running

  For iOS Simulator (UI Testing Only)

  1. In Xcode, select a simulator from the device dropdown (e.g., "iPhone 15 Pro")
  2. Press Cmd+R or click the Play button
  3. The app will build and launch in the simulator

  Note: Bluetooth and real GPS features won't work in simulator

  For Physical Device (Full Testing)

  1. Connect your iPhone/iPad via USB
  2. Select your device from the Xcode device dropdown
  3. First time setup:
    - Go to Settings > Privacy & Security > Developer Mode on your iPhone
    - Enable Developer Mode
    - Trust your Mac when prompted
  4. In Xcode: Signing & Capabilities tab
    - Add your Apple ID as a development team
    - Let Xcode create a provisioning profile
  5. Press Cmd+R to build and run

  4. Testing Different Features

  Simulator Testing (Limited)

  // You can test:
  - UI navigation between tabs
  - Settings screen input validation
  - Dashboard layout and design
  - Connection view interface
  - Mock data display

  Physical Device Testing

  // Full capabilities:
  - Bluetooth scanning for SparkFun devices
  - Real NMEA data parsing
  - NTRIP connection to servers
  - Background operation
  - Location services

  5. Using SwiftUI Previews (Quick UI Testing)

  In Xcode, you can preview individual views without running the full app:

  1. Open any SwiftUI view file (e.g., DashboardView.swift)
  2. Click the Canvas button in the editor
  3. Click Resume to see live preview
  4. Interact with the preview directly

  6. Testing with Mock Data

  To test without hardware, you can modify the app to use mock data:

  // In GNSSViewModel.swift, add a debug mode:
  #if DEBUG
  func injectMockData() {
      // Simulate RTK position data
      currentPosition = GNSSPosition.mock
      isReceivingData = true
      dataRate = 4.0
      connectionStatus = .bluetooth
  }
  #endif

  7. Command Line Testing (Without Xcode GUI)

  # Build the project
  xcodebuild -project RTKClient.xcodeproj -scheme RTKClient -configuration Debug

  # Run tests
  xcodebuild test -project RTKClient.xcodeproj -scheme RTKClient \
      -destination 'platform=iOS Simulator,name=iPhone 15'

  # Build for device (requires provisioning)
  xcodebuild -project RTKClient.xcodeproj -scheme RTKClient \
      -configuration Debug -destination 'generic/platform=iOS'

  8. Testing Checklist

  Basic Functionality

  - App launches without crashing
  - All three tabs are accessible
  - Settings can be saved and loaded
  - Connection view shows proper options

  Bluetooth Testing (Physical Device)

  - Enable Bluetooth on device
  - Put SparkFun RTK in pairing mode
  - Scan finds the device
  - Connection establishes successfully
  - NMEA data streams to dashboard

  NTRIP Testing

  - Enter valid NTRIP credentials
  - Test connection button works
  - RTCM corrections flow to device
  - Correction age displays properly

  Background Testing

  - Lock the device screen
  - Verify connection persists
  - Check data continues streaming
  - Monitor battery usage

  9. Troubleshooting

  Common Issues and Solutions

  "Unable to launch app" on device
  # Trust the developer certificate on your iPhone:
  Settings > General > VPN & Device Management > Developer App > Trust

  "No provisioning profile" error
  # In Xcode:
  1. Select your project
  2. Go to Signing & Capabilities
  3. Check "Automatically manage signing"
  4. Select your Apple ID as Team

  Bluetooth not working
  # Ensure permissions are granted:
  Settings > RTKClient > Bluetooth > Allow

  10. Alternative: TestFlight Beta Testing

  For more extensive testing without Xcode:

  1. Archive the app in Xcode (Product > Archive)
  2. Upload to App Store Connect
  3. Create a TestFlight beta test
  4. Invite testers via email
  5. Testers install via TestFlight app

  Quick Start Commands

  # If you're on macOS with Xcode installed:

  # 1. Open the project
  cd "/path/to/RTKClient"
  open RTKClient.xcodeproj

  # 2. Build and run on simulator
  xcodebuild -project RTKClient.xcodeproj -scheme RTKClient \
      -destination 'platform=iOS Simulator,name=iPhone 15' \
      build

  # 3. Run the app
  xcrun simctl boot "iPhone 15"
  xcrun simctl install "iPhone 15" \
      ~/Library/Developer/Xcode/DerivedData/RTKClient-*/Build/Products/Debug-iphonesimulator/RTKClient.app
  xcrun simctl launch "iPhone 15" com.example.RTKClient

  The easiest way is to open the project in Xcode and press the Run button - it handles all the complexity for you!