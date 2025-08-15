Excellent! With your SparkFun RTK device ready and preference for incremental learning, let's create a powerful Claude Code CLI workflow that builds your iOS NTRIP app step-by-step.

## 🚀 Initial Setup Strategy

### Step 1: Prime Claude Code with Your Project Context

Create a `CLAUDE.md` file in your project root with these essential rules:

```bash
# In your terminal, create the project directory first
mkdir RTKNTRIPClient && cd RTKNTRIPClient
claude -p . "Create a CLAUDE.md file with our iOS RTK NTRIP app architecture rules"
```

Then paste this focused context into `CLAUDE.md`:

```markdown
# iOS RTK NTRIP Client - Project Context

## Architecture Rules
- MVVM + Coordinators pattern
- SwiftUI for main UI, UIKit for performance-critical views (Grade Control, Grid Navigation)
- CoreBluetooth for SparkFun RTK (BLE only, no SPP on iOS)
- Incremental patches preferred - small, testable changes

## Hardware
- SparkFun RTK Surveyor (u-blox F9P)
- Nordic UART Service UUIDs:
  - Service: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
  - TX (write RTCM): 6E400002-B5A3-F393-E0A9-E50E24DCCA9E
  - RX (read NMEA): 6E400003-B5A3-F393-E0A9-E50E24DCCA9E

## Features to Stub
1. BLE Connection Manager
2. NTRIP Client (URLSession)
3. NMEA Parser (GGA, GSA, RMC, VTG)
4. Grade Control View
5. Tape Measure View
6. Grid Navigation View
```

### Step 2: Scaffold with Smart Incremental Commands

Here's your optimal command sequence for building the MVVM structure:

```bash
# 1. Create the Xcode project and base structure
claude -p . "Create an iOS app in Xcode called RTKNTRIPClient with MVVM folders: Models, ViewModels, Views, Services, Coordinators. Use SwiftUI app lifecycle, target iOS 15+. Create the .xcodeproj file structure."

# 2. Build the BLE service layer first (most critical)
claude -p . -c CLAUDE.md "/plan: Create BLEConnectionManager in Services/ that scans for SparkFun RTK devices, connects via CoreBluetooth, and publishes NMEA strings via Combine. Include state machine for connection states."

# After reviewing the plan, apply it:
claude -p . "/edit: implement the BLEConnectionManager with basic connection logic and @Published state"

# 3. Stub the NMEA parser
claude -p . "/plan: Add NMEAParser in Services/ that processes GGA sentences, extracts lat/lon/altitude/fix quality, returns typed Swift structs"
```

### Step 3: Leverage Claude's Memory with Focused Context

**Key trick:** Use the `-c` flag to provide only relevant context:

```bash
# When working on Bluetooth, only include relevant files
claude -p . -c Sources/Services/BLEConnectionManager.swift,CLAUDE.md \
  "Add reconnection logic with exponential backoff to BLEConnectionManager"

# When working on UI, include only UI-related context
claude -p . -c Sources/Views,Sources/ViewModels \
  "Create the main dashboard view showing connection status and GPS coordinates"
```

### Step 4: Test-Driven Development Pattern

Since you have the hardware, use this pattern:

```bash
# Generate test data from your actual device first
claude -p . "Create a TestData/ folder with sample NMEA sentences for testing:
- Valid GGA with RTK fix
- GSA with satellite info
- Invalid checksums for error handling"

# Then implement with tests
claude -p . "/plan: Write XCTest unit tests for NMEAParser including edge cases"
claude -p . "/edit: implement the tests"
```

## 🎯 Premium Feature Development Strategy

For each premium feature, use this incremental pattern:

### Grade Control Example:

```bash
# Step 1: Data model
claude -p . "Create GradeControlModel in Models/ with:
- referenceElevation: Double?
- currentElevation: Double
- deviationCentimeters: Double { computed property }
- Add a method to zero the reference"

# Step 2: ViewModel
claude -p . -c Sources/Models/GradeControlModel.swift \
  "Create GradeControlViewModel that subscribes to NMEAParser elevation updates and updates the model"

# Step 3: View (start simple)
claude -p . "Create GradeControlView in SwiftUI showing deviation as text with color coding:
- Green: within ±5cm
- Yellow: ±5-15cm  
- Red: >15cm deviation"

# Step 4: Enhance incrementally
claude -p . -c Sources/Views/GradeControlView.swift \
  "Add a visual gauge using SwiftUI Canvas for the deviation indicator"
```

## 💡 Power Tips for Your Workflow

### 1. Use Slash Commands Effectively

```bash
# Always start with /plan for complex features
claude -p . "/plan: implement NTRIP client with URLSession, Basic auth, and GGA sentence sending"

# Review the plan, then:
claude -p . "/edit: implement step 1 of the plan only"

# Check your changes:
claude -p . "/diff"
```

### 2. Debugging with Real Hardware

```bash
# Create a debug console for your SparkFun
claude -p . "Add a DebugConsoleView that shows:
- Raw NMEA sentences with color coding
- BLE connection RSSI
- Parsed values in real-time
Make it toggleable via shake gesture"
```

### 3. Handle Background Execution Early

```bash
claude -p . "Update Info.plist with required background modes for BLE. Add state restoration to BLEConnectionManager with identifier 'com.rtkntrip.ble.central'"
```

### 4. Incremental UI Building

Start with text, then enhance:

```bash
# Phase 1: Text-only
claude -p . "Show current position as text labels"

# Phase 2: Add graphics
claude -p . "Enhance with SwiftUI shapes and animations"

# Phase 3: Performance optimization
claude -p . "Convert Grid Navigation to UIKit with UIViewRepresentable for 10Hz updates"
```

## 🚫 Common Pitfalls to Avoid

1. **Don't request entire files** - Break into components:

   ```bash
   # Bad:
   claude "Create the complete NTRIP client"
   
   # Good:
   claude "Create NTRIP authentication method"
   claude "Add RTCM data reception handler"
   ```

2. **Don't skip error handling**:

   ```bash
   claude -p . "Add comprehensive error states to BLEConnectionManager:
   - Bluetooth disabled
   - Device not found
   - Connection timeout
   - Unexpected disconnection"
   ```

3. **Test incrementally with your hardware**:

   ```bash
   # After each BLE change:
   claude -p . "Add a temporary print statement to log raw NMEA data for debugging"
   ```

## 📱 Your First Day Game Plan

```bash
# Hour 1: Foundation
claude -p . "Create Xcode project with MVVM structure"
claude -p . "Add CoreBluetooth and Info.plist permissions"

# Hour 2: BLE Connection
claude -p . "Implement BLE scanner for Nordic UART Service"
claude -p . "Add connection and characteristic discovery"

# Hour 3: Data Flow
claude -p . "Create NMEA parser for GGA sentences"
claude -p . "Connect BLE data to parser with Combine"

# Hour 4: Basic UI
claude -p . "Create dashboard showing lat/lon and fix status"
claude -p . "Add connection status indicator"
```

## 🔄 Iteration Pattern for Complex Features

When stuck, use this recovery pattern:

```bash
# Get Claude to review and suggest improvements
claude -p . -c Sources/Services/BLEConnectionManager.swift \
  "Review this code and suggest improvements for:
  - Battery efficiency
  - Reconnection reliability
  - Memory management"

# Then apply one suggestion at a time
claude -p . "/edit: implement just the battery efficiency improvement"
```

Remember: With your SparkFun device ready, you can validate each increment immediately. Keep the Xcode console open to see real data flowing, and don't hesitate to ask Claude to add temporary debug logging that you can remove later.

Start with the BLE connection - once you see NMEA sentences in your console, you'll know the foundation is solid, and adding features becomes much easier!