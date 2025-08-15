Tips and tricks for claude code cli for the iOS NTRIP app:

Based on the comprehensive research and architectural decisions we've made, here are strategic tips and tricks for using Claude Code CLI to build your iOS NTRIP client efficiently:

## Getting Started with Claude Code CLI for iOS Development

### 1. **Project Setup and Structure**

```bash
# Create a well-organized project structure from the start
claude "Create an iOS app project structure for an RTK NTRIP client with:
- MVVM architecture with Coordinators
- Separate modules for Domain, Infrastructure, and Presentation layers
- Support for both SwiftUI and UIKit hybrid approach
- Folders for Bluetooth, NTRIP, NMEA parsing, and Premium Features
Generate the initial Xcode project file structure and Swift Package manifest"
```

### 2. **Incremental Development Strategy**

Start with the **core connectivity layer** before UI:

```bash
# Build BLE manager first (most critical component)
claude "Implement a CoreBluetooth manager for SparkFun RTK devices with:
- Nordic UART Service UUIDs (6E400001-B5A3-F393-E0A9-E50E24DCCA9E)
- State restoration with identifier 'com.yourapp.rtk.central'
- Automatic reconnection logic with exponential backoff
- Background mode support
Include proper error handling and delegate patterns"
```

### 3. **Leverage Claude's Context Window Effectively**

Break complex features into focused requests:

```bash
# Don't ask for the entire app at once. Instead:
claude "Create just the NMEA GGA sentence parser that:
- Validates checksums
- Extracts lat, lon, altitude, fix quality, satellite count
- Returns a Swift struct with typed properties
- Handles both GPGGA and GNGGA talker IDs"
```

### 4. **Use Claude for Protocol Implementation**

NTRIP protocol is well-documented, perfect for Claude:

```bash
claude "Implement NTRIP client using URLSession that:
- Sends proper HTTP headers with Basic auth
- Handles SOURCETABLE response parsing
- Maintains persistent connection for RTCM streaming
- Sends GGA sentence every 10 seconds
- Supports both HTTP and HTTPS connections
Follow the official NTRIP v1.0 specification"
```

### 5. **Test-Driven Development with Claude**

Ask for tests alongside implementation:

```bash
claude "Write XCTest unit tests for the NMEA parser including:
- Valid GGA sentences with different fix qualities
- Invalid checksums
- Malformed sentences
- Edge cases like empty fields
Also create mock data for testing"
```

### 6. **Hybrid UI Implementation Tips**

For the SwiftUI/UIKit hybrid:

```bash
# Start with SwiftUI wrapper
claude "Create a SwiftUI view that wraps a UIKit MKMapView for Grid Navigation:
- Use UIViewRepresentable
- Add MKTileOverlay for grid lines every 10 meters
- Update user position from @Published GNSS state
- Include coordinator for handling map delegates"
```

### 7. **Performance-Critical Code**

For Grade Control real-time updates:

```bash
claude "Implement a high-performance Grade Control indicator using:
- CAShapeLayer for smooth 60fps animation
- Circular buffer for elevation samples
- Moving average filter for stability
- Color gradients indicating deviation from target
Optimize for minimal CPU usage"
```

### 8. **Background Execution Patterns**

Get the tricky parts right:

```bash
claude "Implement complete background execution for BLE + NTRIP:
- CBCentralManager state restoration in AppDelegate
- Background task assertion for NTRIP connection
- Handle iOS 13+ scene-based lifecycle
- Graceful degradation when background execution fails
Include all Info.plist configurations needed"
```

### 9. **Memory Management for C Integration**

When adding RTKLIB later:

```bash
claude "Create Swift wrapper for RTKLIB's RTCM parser:
- Proper bridging header setup
- Safe memory management with UnsafeMutablePointer
- Swift-friendly API hiding C complexity
- Thread-safe access patterns
Include deallocation in deinit"
```

### 10. **Iterative Refinement Strategy**

Use Claude to refactor and optimize:

```bash
# After initial implementation
claude "Review this BLE manager code and suggest improvements for:
- Battery efficiency
- Connection reliability in poor signal conditions
- Compliance with Apple's best practices
- Potential memory leaks or retain cycles"
```

## Pro Tips for Maximum Efficiency

### 🎯 **Focus on Integration Points First**

Build and test the BLE connection and NTRIP client independently before combining them. This isolates problems and makes debugging easier.

### 📝 **Document as You Go**

```bash
claude "Add comprehensive DocC documentation to this RTKManager class including:
- Public API documentation
- Code examples
- Threading considerations
- Error handling patterns"
```

### 🔧 **Use Claude for Configuration Files**

```bash
claude "Generate all necessary configuration files:
- Info.plist with background modes and usage descriptions
- Package.swift with dependencies
- .swiftlint.yml for code standards
- GitHub Actions workflow for CI/CD"
```

### 🚀 **Rapid Prototyping Pattern**

1. Start with a working prototype using mock data
2. Add real BLE connectivity
3. Integrate NTRIP
4. Polish UI and add premium features
5. Optimize performance

### 🐛 **Debugging Helpers**

```bash
claude "Create a debug console view that displays:
- Raw NMEA sentences with color coding
- RTCM message types and frequency
- BLE connection state and RSSI
- NTRIP connection status and data rate
Make it toggleable via shake gesture"
```

### 📱 **Device-Specific Optimizations**

```bash
claude "Add adaptive behavior based on device capabilities:
- Reduce update frequency on older devices
- Adjust map detail level based on available RAM
- Scale UI for different screen sizes
- Battery saver mode below 20% charge"
```

## Common Pitfalls to Avoid

1. **Don't request entire files** - Break them into logical components
2. **Don't ignore Apple's guidelines** - Always mention App Store compliance requirements
3. **Don't skip error handling** - Ask Claude to include comprehensive error cases
4. **Don't forget about offline mode** - Plan for intermittent connectivity from the start

## Sample Development Sequence

```bash
# Day 1-2: Core Infrastructure
claude "BLE manager with state restoration"
claude "NTRIP client with reconnection logic"
claude "NMEA sentence parser for GGA, GSA, RMC"

# Day 3-4: Data Flow
claude "MVVM view models for GNSS state"
claude "Combine publishers for real-time updates"
claude "Data persistence with Core Data"

# Day 5-6: Basic UI
claude "SwiftUI main dashboard"
claude "Settings screen with secure credential storage"
claude "Connection status indicators"

# Day 7-8: Premium Features
claude "Grade Control UIKit implementation"
claude "MapKit integration for Grid Navigation"
claude "Tape Measure calculations and UI"

# Day 9-10: Polish and Testing
claude "Unit test suite"
claude "UI tests for critical paths"
claude "Performance profiling and optimization"
```

By following these patterns and tips, you'll be able to leverage Claude Code CLI effectively to build a professional-grade iOS NTRIP client that matches or exceeds the Lefebure Android app's functionality while taking full advantage of iOS's native capabilities.

### Getting Started with Claude Code CLI for iOS App Development

Claude Code CLI is Anthropic's agentic coding tool that integrates Claude AI into your terminal workflow. It helps with tasks like code generation, debugging, refactoring, understanding codebases, and automating routines—perfect for building an iOS RTK NTRIP client app in Swift. It's designed to feel like a co-pilot in your CLI, handling everything from reading GitHub issues to running tests. Based on its documentation and user feedback as of 2025, here are practical tips and tricks to get started, tailored to your project.

#### 1. **Installation and Setup**
   - **Install via Homebrew (Recommended for macOS Developers):** Run `brew install anthropic/claude-code/claude-code` in your terminal. This sets up the CLI quickly and handles dependencies. If you're on another OS, download from the official Anthropic site or GitHub repo.
   - **API Key Configuration:** After installation, run `claude-code config` to set up your Anthropic API key (get one from anthropic.com). Enable integrations like GitHub by adding your token—essential for pulling issues or repos related to libraries like RTKLIB.
   - **VS Code Extension for Seamless Integration:** Install the official Claude Code extension from the VS Code Marketplace. It syncs with the CLI, allowing inline code suggestions in your Swift files. Bind it to a shortcut (e.g., Cmd+Shift+C) for quick queries like "Generate Swift code for NTRIP authentication."
   - **Trick:** Test installation with `claude-code --version` and a simple command: `claude-code "Hello, Claude!"`. If it responds, you're good. For iOS dev, ensure Xcode is installed (15+ for Swift 5.9+ features like async/await in networking).

#### 2. **Basic Commands and Workflows**
   - **Core Commands:**
     - `claude-code generate`: Creates code snippets. Example: `claude-code generate "Swift class for NTRIP client using URLSession with background support"`. Pipe output to a file: `claude-code generate ... > NTRIPManager.swift`.
     - `claude-code explain`: Analyzes code. Copy-paste your CoreBluetooth setup and run `claude-code explain` to get breakdowns or improvements.
     - `claude-code debug`: Troubleshoot errors. Example: `claude-code debug "CoreBluetooth connection drops in background on iOS 18" --attach-log your_log.txt`.
     - `claude-code refactor`: Optimizes code. Use for hybrid SwiftUI/UIKit: `claude-code refactor "Convert this UIKit MapKit view to UIViewRepresentable for SwiftUI"`.
     - `claude-code test`: Generates unit tests. Crucial for your app: `claude-code test "Swift XCTest for custom NMEA parser handling GGA sentences"`.
   - **Flags for Efficiency:**
     - `--model claude-3.7-sonnet`: Use the latest model for complex tasks like RTKLIB integration (faster and more accurate than defaults).
     - `--context`: Attach files or dirs: `claude-code generate ... --context Bridging-Header.h rtklib.h` for C-Swift bridging.
     - `--output-format swift`: Ensures generated code is in Swift syntax.
     - `--verbose`: Logs AI reasoning—great for learning why it suggests certain patterns (e.g., exponential backoff in reconnections).
   - **Trick:** Chain commands with pipes: `claude-code explain your_code.swift | claude-code refactor > improved_code.swift`. For your app, start with `claude-code generate "Basic MVVM structure for iOS GNSS app"`.

#### 3. **Tips for iOS/Swift-Specific Development**
   - **Project Bootstrapping:** Run `claude-code init --template ios-swift-hybrid` (if available; otherwise describe your stack). It can scaffold an Xcode project with pods for dependencies like KeychainAccess.
   - **Handling Platform-Specifics:** Query for iOS quirks: `claude-code "Best practices for CoreBluetooth state restoration in Swift" --include-docs`. It pulls from Apple docs and generates code with comments.
   - **Open-Source Integration:** For RTKLIB or NmeaParser: `claude-code "Integrate C library RTKLIB into Swift via bridging header" --step-by-step`. It outputs a guide with code snippets.
   - **UI Hybrid Workflows:** `claude-code generate "SwiftUI view embedding UIKit MapKit for grid navigation"`. Test iterations quickly in Xcode previews.
   - **Background Execution:** `claude-code debug "Implement persistent BLE and URLSession in iOS background" --with-example`. It can even suggest Info.plist updates.
   - **Trick:** Use `--git-integration` to auto-commit generated code: `claude-code generate ... --commit "Add NTRIP manager"`. For your premium features, generate one at a time (e.g., Grade Control first) and refine iteratively.

#### 4. **Best Practices and Tricks for Productivity**
   - **Prompt Engineering:** Be specific—include context like "for iOS 18, using Swift 5.10, hybrid UI". Add constraints: "bare-bones, no third-party deps except essentials". For errors: Attach stack traces or logs.
   - **Agentic Mode:** Enable with `--agentic`: Lets Claude execute multi-step tasks, like "Set up full NTRIP flow: connect, auth, parse GGA, forward RTCM".
   - **Customization:** Edit `~/.claude-code/config.yaml` for defaults (e.g., preferred model, output dir). Set aliases in your shell: `alias ccgen="claude-code generate"`.
   - **Error Handling:** If responses are off, use `--refine` on previous output. For long sessions, `--conversation-id` to maintain context across commands.
   - **Performance Tricks:** Run in a tmux session for background ops. Limit scope: Break app into modules (e.g., connectivity first) to avoid overwhelming prompts.
   - **Learning Resources:** Watch the beginner YouTube tutorial (2025). Read Anthropic's best practices post for advanced workflows like codebase analysis.
   - **Common Pitfalls:** Avoid vague prompts—Claude excels with details. Test generated code in Xcode immediately. For security (e.g., Keychain), verify outputs against Apple docs.
   - **Trick:** Combine with Git: `claude-code analyze --repo .` to understand your codebase, then `claude-code "Add WiFi/TCP fallback to BLE manager"`.

Start small: Install, configure, and generate a simple "Hello, RTK!" Swift file. Build iteratively—focus on connectivity, then parsing, UI last. Claude Code will accelerate your dev cycle, but always review and test code manually for iOS specifics. If stuck, query the CLI itself: `claude-code "Tips for using Claude Code with Xcode for iOS apps"`. Happy coding!

Great choice! Using the **Claude Code CLI** (or any LLM-powered coding assistant) can significantly accelerate the development of your iOS RTK NTRIP client. To get the most out of it, you need to provide clear, structured, and context-rich prompts. Below are essential tips and tricks tailored to your specific project, leveraging the detailed architectural plan we've established.

### 1. Master the Art of the Prompt: Be Specific, Structured, and Iterative

The quality of Claude's output is directly proportional to the quality of your input. Vague prompts yield vague results. Use the following framework for your prompts:

*   **Context:** Remind Claude of the project's scope and your current goal.
*   **Task:** Clearly state what you want it to do.
*   **Constraints:** Specify the language, frameworks, and any architectural rules.
*   **Output Format:** Define exactly how you want the code or answer structured.

**Example Prompt for a CoreBluetooth Manager:**

```prompt
Context: I'm building an iOS RTK NTRIP client in Swift. The app must connect to a u-blox GNSS receiver via Bluetooth LE to send RTCM correction data.
Task: Generate a complete, production-ready Swift class called `BLEConnectionManager` that manages the BLE connection lifecycle.
Constraints:
- Use the CoreBluetooth framework.
- The class should be a singleton.
- It must handle scanning for devices with a specific service UUID (e.g., `FFE0`), connecting, discovering services/characteristics, and writing data to a specific characteristic (e.g., `FFE1`).
- Implement a robust state machine (e.g., an enum with states like `.idle`, `.scanning`, `.connecting`, `.connected`, `.disconnected`).
- Include delegate methods for `CBCentralManagerDelegate` and `CBPeripheralDelegate`.
- Handle common errors (e.g., connection timeout, characteristic not found).
- Use Combine for publishing state changes to the rest of the app.
Output Format: Provide the complete Swift code for the `BLEConnectionManager` class, including all necessary imports, properties, and methods. Add detailed comments explaining the state machine transitions and error handling.
```

### 2. Break Down Complex Features into Atomic Components

Your premium features (Grade Control, Tape Measure, Grid Navigation) are complex. Don't ask Claude to build the entire feature at once. Break them down.

**Example Prompt for a Grade Control Indicator:**

```prompt
Context: In the same iOS RTK NTRIP app, I'm implementing a "Grade Control" feature. I need a custom SwiftUI view that visually shows the user's current elevation deviation from a target grade.
Task: Create a SwiftUI `View` struct called `GradeControlIndicator`.
Constraints:
- The view should display a horizontal baseline (target grade).
- A central vertical line should move up and down to represent the current position.
- The movement should be smooth and animated.
- The view should accept a `@Binding` property for the current deviation in centimeters (e.g., `@Binding var deviationCm: Double`).
- Use a simple color scheme: green for within tolerance (e.g., ±5cm), red for outside.
- The indicator should be compact and suitable for a status bar.
Output Format: Provide the complete SwiftUI code for the `GradeControlIndicator` struct. Include a simple `ZStack` and `GeometryReader` for layout.
```

### 3. Leverage Claude for Debugging and Code Review

Claude is excellent at finding bugs and suggesting improvements. Paste your existing code and ask for help.

**Example Prompt for Debugging:**

```prompt
Context: I have a `NTRIPClient` class in my iOS app that uses `URLSession` to connect to an NTRIP caster. The connection works, but the app crashes when the device goes to sleep.
Task: Review the following Swift code for the `NTRIPClient` class and identify potential issues with background execution on iOS.
Constraints:
- Focus on `URLSession` configuration and delegate methods.
- Check for proper handling of background sessions.
- Suggest fixes to ensure the data stream continues when the app is in the background.
Output Format: Point out the specific lines of code that are problematic. Explain why they are an issue. Provide the corrected code snippet with comments.
```

### 4. Use Claude to Generate Boilerplate and Configuration

Save time on repetitive tasks like setting up `Info.plist` entries or creating data models.

**Example Prompt for Info.plist Configuration:**

```prompt
Context: My iOS app needs to use Bluetooth in the background to maintain a connection to a GNSS receiver.
Task: Provide the exact XML entries that need to be added to the `Info.plist` file to enable Bluetooth background mode.
Constraints:
- The app uses CoreBluetooth in central mode.
- It needs to scan and connect to peripherals while in the background.
Output Format: Provide the XML code block that should be added to `Info.plist`. Include the key `UIBackgroundModes` and the array of required background modes.
```

### 5. Ask for Documentation and Explanations

If you don't understand a piece of code or a concept (like how RTKLIB's `rtcm_decode()` function works), ask Claude to explain it.

**Example Prompt for Explanation:**

```prompt
Context: I'm integrating the C-based RTKLIB library into my Swift iOS app to parse RTCM messages.
Task: Explain how the `rtcm_decode()` function in RTKLIB works. What are its input parameters, return values, and how does it update the internal `rtcm_t` data structure?
Constraints:
- Provide a clear, step-by-step explanation.
- Use simple language suitable for a Swift developer who is unfamiliar with C.
- Mention how this function would be used in the context of an NTRIP client.
Output Format: A concise paragraph explaining the function's purpose and workflow.
```

### 6. Iterate and Refine

Treat your interaction with Claude as a conversation. The first response might be good, but rarely perfect.

*   **Refine:** "That's a good start, but can you make the `GradeControlIndicator` animate the movement of the vertical line using a spring animation?"
*   **Expand:** "Can you now create a parent view that combines the `GradeControlIndicator` with a text display for the numerical deviation?"
*   **Optimize:** "Is there a way to make this `BLEConnectionManager` more memory-efficient to prevent retain cycles?"

By following these tips, you'll transform Claude Code CLI from a simple code generator into a powerful, collaborative development partner, helping you build a robust and professional-grade iOS RTK NTRIP client efficiently.

Awesome — Claude Code CLI is a great fit for this project. Here’s a tight, field-tested playbook to get you productive fast, with examples tailored to your RTK/NTRIP iOS app.

------

## 0) First-time setup (1–2 mins)

- Install & check it works:

  ```bash
  npm i -g @anthropic-ai/claude-code
  claude --help
  ```

  Then run inside your repo: `claude` (it opens an interactive session in your terminal). ([GitHub](https://github.com/anthropics/claude-code))

- Quickstart concepts you’ll use right away:

  - `-p` sets project root
  - `-c` adds specific files/dirs as context
  - `-r` includes recent changes (diff-aware)
  - `--resume` / `--continue` to pick up a past thread
     Examples & flags are in Quickstart and the CLI reference. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))

------

## 1) Prime Claude with your rules (once)

Create a `CLAUDE.md` at the repo root with the “house rules” you gave me (open-source priority, hybrid UI plan, BLE+WiFi, NTRIP behaviors, background modes, iOS targets, coding style, etc.). Claude Code treats this like persistent memory for the repo. Keep it concise and actionable (bullets + short code snippets). ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/memory))

**Seed outline** (paste into `CLAUDE.md`):

- Architecture: MVVM + Coordinators; SwiftUI app shell; UIKit/MapKit for Grid; CoreGraphics for Grade Control.
- Connectivity: CoreBluetooth (NUS) + Network.framework TCP; robust FSM; exponential backoff.
- NTRIP: HTTP/1.1 GET, Basic auth, send GGA at 10s; keep-alive; secure TLS; reconnection rules.
- Data: Minimal Swift NMEA parser (GGA/GSA/GSV/RMC/VTG); RTCM pass-through; optional RTKLIB via Obj-C wrapper later.
- Background: `bluetooth-central`, state restoration, background tasks.
- Security: Keychain for creds. No plaintext.
- OSS bias: no commercial SDKs unless 10× advantage.

This makes all later prompts “snap to” your blueprint. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/memory))

------

## 2) Your bread-and-butter CLI patterns

Use these patterns constantly:

- **Targeted generation with context**

  ```bash
  claude -p . -c Sources/Connectivity,BLE,NTRIP "Create a CBCentral-based BLEServiceHandler for Nordic UART with state restoration and reconnection FSM. Use async/await, dependency-injected logger. Add a unit test skeleton."
  ```

  Pass only relevant folders to keep answers crisp. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))

- **Iterate on a file in-place**

  ```bash
  claude -p . "@file Sources/NTRIP/NtripClient.swift" \
    "/plan: add TLS support, Basic auth, and periodic GGA writer timer; then /edit with a minimal patch; then /diff"
  ```

  `/plan`, `/edit`, `/diff`, `/review`, `/test` are designed for tight code loops.

- **Pick up where you left off**

  ```bash
  claude --resume   # reopens your last repo session
  claude --continue # same, alternate flag
  ```

  ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/cli-reference))

- **Work only on what changed**

  ```bash
  git add -A && git commit -m "wip"
  # make more edits
  claude -p . -r "/review: Review only the recent changes. Point out logic and concurrency issues."
  ```

  ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))

- **Bring real logs/samples**

  ```bash
  claude -p . -c Tests/Fixtures "@file Tests/Fixtures/gga_stream.txt" \
    "Debug: parser misreads multi-GSV. Fix parser and add table-driven tests."
  ```

  File tokens are first-class and ideal for NMEA/RTCM snippets.

------

## 3) High-leverage slash commands (use these a lot)

- `/plan` → agree on a concrete step list, then `/edit` to apply a small patch; finish with `/diff` and `/review`.
- `/refactor` for cleanups without changing behavior (great before writing tests).
- `/test` to define how to run tests (it won’t run them itself; you provide the command and expectations). Pair with Hooks below.
- `/lint`, `/style`, `/todo` to keep the repo pristine.

Tip: keep interactions small (single responsibility patches). Claude Code is optimized around the “plan → small patch → diff” cadence. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))

------

## 4) Hooks: enforce quality automatically

Set **pre**/**post** hooks so every accepted patch builds and tests:

- Create `.claude/hooks.js`:
  - **preApply**: run `swiftformat . && swiftlint`
  - **postApply**: `xcodebuild -scheme App -destination 'platform=iOS Simulator,name=iPhone 15' test`
     If build/tests fail, the patch won’t just “sneak in”. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/hooks))

------

## 5) Subagents for deep-dive tasks

Define expert subagents in `CLAUDE.md` (or summon ad-hoc):

- `@iOS-Engineer`: UIKit/MapKit/CoreBluetooth veteran
- `@Networking-Engineer`: sockets, TLS, HTTP/1.1, NTRIP
- `@GNSS-Engineer`: NMEA/RTCM, GGA cadence, MSM messages

Example:

```text
/plan with @Networking-Engineer: harden NtripClient handshake (HTTP/1.1 GET, Basic auth), header parse, binary stream demarcation, keep-alive, and reconnection with jitter.
```

Subagents let you steer style and depth per topic. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/memory))

------

## 6) Smart context curation (token discipline)

- Prefer `-c` with **specific** folders/files over the whole repo.
- Use `-r` when asking for reviews; it keeps prompts tight by focusing on diffs.
- For heavy assets (e.g., long RTCM logs), clip to representative slices and attach with `@file`.
   These habits keep responses focused and accurate. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))

------

## 7) Safety & secrets

- Never paste real caster creds into prompts. Put placeholders in code; store the real values in Keychain at runtime.
- Add “**Do not suggest commercial SDKs; prefer OSS**” in `CLAUDE.md`. Claude will honor repo memory and your guardrails. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/memory))

------

## 8) Proven prompt templates (copy/paste)

**BLE (Nordic UART) manager skeleton**

```text
/plan: Create a BLEServiceHandler that scans/connects to NUS, subscribes to RX, chunk-assembles NMEA lines, and exposes AsyncStream<String>. Support state restoration and reconnection FSM.
/edit @file Sources/BLE/BLEServiceHandler.swift: Implement with CBCentralManager and CBPeripheral delegates, background-friendly. Include unit-testable parser for fragmented notifications.
```

**NTRIP client (Network.framework)**

```text
/plan: Build NtripClient using NWConnection (TLS optional), HTTP/1.1 GET to mountpoint, Basic auth header, parse 200 OK + blank line, then binary RTCM stream. Add periodic GGA sender (every 10s) sourced from latest position.
/edit @file Sources/NTRIP/NtripClient.swift: Implement connection lifecycle, backoff, and delegate callbacks for data and errors.
```

([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))

**Grid Navigation (UIKit/MapKit island in SwiftUI app)**

```text
/plan: Add MapKit UIViewController + MKOverlayRenderer that draws a meter-spaced grid aligned to a local ENU frame. Expose a SwiftUI wrapper via UIViewControllerRepresentable. Optimize for frequent position updates.
/edit @file Sources/UI/Grid/GridViewController.swift: Implement overlay & renderer with minimal allocations per frame.
```

([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))

**Grade Control gauge (CoreGraphics)**

```text
/plan: Create a CALayer-backed gauge view that shows vertical deviation (cm) with sub-100ms updates and color thresholds. Provide SwiftUI wrapper.
/edit @file Sources/UI/Grade/GradeGaugeView.swift: Implement draw(in:) and value animations on a display link.
```

([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))

**RTKLIB wrapper (Phase 2)**

```text
/plan: Add Obj-C wrapper around RTKLIB’s RTCM decode entry points (init_rtcm, input_rtcm3). Expose Swift-friendly handle type and minimal APIs.
/edit @file Sources/RTKLIB/RTCLibWrapper.h: Define C/ObjC bridge.
/edit @file Sources/RTKLIB/RTCLibWrapper.m: Implement create/free/process byte-chunk.
```

(Use the same plan→edit→diff loop; keep patches small.) ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))

------

## 9) Interactive mode: “live” collaboration

Inside an interactive session (`claude`), you can type prose + slash commands, attach files with `@file`, and apply patches incrementally without re-running the command. It’s great for long refactors and code reviews. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/cli-reference))

------

## 10) CI & PRs

Wire Claude Code into PR workflows to auto-review diffs and propose patches, or run it from CI as a gated assistant (optional, but handy as the team grows). ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/sub-agents))

------

### Handy cheat sheet

- Start a focused task:
   `claude -p . -c Sources/NTRIP "Add TLS & GGA timer to NtripClient; patch only."` ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/common-workflows))
- Resume last thread: `claude --resume` ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/cli-reference))
- Plan → patch → review loop: `/plan` → `/edit` → `/diff` → `/review`
- Keep tests green automatically: use **Hooks** (preApply/postApply). ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/hooks))
- Persist project rules once: `CLAUDE.md`. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/memory))
- Call specialists when needed: `@iOS-Engineer`, `@Networking-Engineer`, `@GNSS-Engineer`. ([Anthropic](https://docs.anthropic.com/en/docs/claude-code/memory))

If you want, I can draft a starter `CLAUDE.md`, a first set of hooks, and a couple of ready-to-run CLI commands tuned to your repo layout.
