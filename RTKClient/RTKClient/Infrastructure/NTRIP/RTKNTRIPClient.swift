import Foundation
import Combine

class RTKNTRIPClient: NSObject, NTRIPClientProtocol, ObservableObject {
    
    @Published var isConnected = false
    @Published var connectionState: NTRIPConnectionState = .disconnected
    
    private var urlSession: URLSession?
    private var dataTask: URLSessionDataTask?
    private var backgroundSession: URLSession?
    
    private let rtcmDataSubject = PassthroughSubject<Data, Never>()
    var rtcmDataStream: AnyPublisher<Data, Never> {
        rtcmDataSubject.eraseToAnyPublisher()
    }
    
    private var currentHost: String?
    private var currentPort: Int?
    private var currentMountpoint: String?
    private var currentUsername: String?
    private var currentPassword: String?
    
    private var ggaTimer: Timer?
    private var lastGGASentence: String?
    
    private var reconnectionTimer: Timer?
    private var reconnectionAttempts = 0
    private let maxReconnectionAttempts = 5
    
    override init() {
        super.init()
        setupURLSessions()
    }
    
    private func setupURLSessions() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 0
        config.networkServiceType = .responsiveData
        
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "com.rtkClient.ntrip.background")
        backgroundConfig.sessionSendsLaunchEvents = true
        backgroundConfig.isDiscretionary = false
        backgroundConfig.networkServiceType = .responsiveData
        backgroundConfig.timeoutIntervalForResource = 300
        
        backgroundSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: nil)
    }
    
    func connect(host: String, port: Int, mountpoint: String, username: String, password: String) {
        disconnect()
        
        currentHost = host
        currentPort = port
        currentMountpoint = mountpoint
        currentUsername = username
        currentPassword = password
        
        DispatchQueue.main.async {
            self.connectionState = .connecting
        }
        
        performNTRIPConnection()
    }
    
    private func performNTRIPConnection() {
        guard let host = currentHost,
              let port = currentPort,
              let mountpoint = currentMountpoint,
              let username = currentUsername,
              let password = currentPassword else {
            DispatchQueue.main.async {
                self.connectionState = .failed(NTRIPError.invalidConfiguration)
            }
            return
        }
        
        let urlString = "http://\(host):\(port)/\(mountpoint)"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.connectionState = .failed(NTRIPError.invalidURL)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("NTRIP/1.0", forHTTPHeaderField: "Ntrip-Version")
        request.setValue("RTKClient/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("close", forHTTPHeaderField: "Connection")
        
        let credentials = "\(username):\(password)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            DispatchQueue.main.async {
                self.connectionState = .failed(NTRIPError.authenticationFailed)
            }
            return
        }
        
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        DispatchQueue.main.async {
            self.connectionState = .authenticating
        }
        
        dataTask = urlSession?.dataTask(with: request)
        dataTask?.resume()
    }
    
    func disconnect() {
        stopGGATimer()
        stopReconnectionTimer()
        
        dataTask?.cancel()
        dataTask = nil
        
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionState = .disconnected
        }
        
        resetConnectionParameters()
    }
    
    func sendGGA(_ sentence: String) {
        guard isConnected,
              let dataTask = dataTask,
              dataTask.state == .running else { return }
        
        lastGGASentence = sentence
        
        let ggaData = (sentence + "\r\n").data(using: .ascii) ?? Data()
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("gga_\(UUID().uuidString).txt")
        
        do {
            try ggaData.write(to: tempURL)
            
            var request = URLRequest(url: dataTask.currentRequest?.url ?? URL(string: "about:blank")!)
            request.httpMethod = "POST"
            request.httpBody = ggaData
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            
            let uploadTask = urlSession?.uploadTask(with: request, fromFile: tempURL)
            uploadTask?.resume()
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                try? FileManager.default.removeItem(at: tempURL)
            }
            
        } catch {
            print("Failed to send GGA sentence: \(error)")
        }
    }
    
    private func startGGATimer() {
        stopGGATimer()
        
        ggaTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            if let lastGGA = self?.lastGGASentence {
                self?.sendGGA(lastGGA)
            }
        }
    }
    
    private func stopGGATimer() {
        ggaTimer?.invalidate()
        ggaTimer = nil
    }
    
    private func scheduleReconnection() {
        guard reconnectionAttempts < maxReconnectionAttempts else {
            DispatchQueue.main.async {
                self.connectionState = .failed(NTRIPError.reconnectionFailed)
            }
            return
        }
        
        stopReconnectionTimer()
        
        let delay = min(pow(2.0, Double(reconnectionAttempts)), 30.0)
        reconnectionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.attemptReconnection()
        }
    }
    
    private func attemptReconnection() {
        guard let host = currentHost,
              let port = currentPort,
              let mountpoint = currentMountpoint,
              let username = currentUsername,
              let password = currentPassword else { return }
        
        reconnectionAttempts += 1
        connect(host: host, port: port, mountpoint: mountpoint, username: username, password: password)
    }
    
    private func stopReconnectionTimer() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
    }
    
    private func resetReconnectionState() {
        reconnectionAttempts = 0
        stopReconnectionTimer()
    }
    
    private func resetConnectionParameters() {
        currentHost = nil
        currentPort = nil
        currentMountpoint = nil
        currentUsername = nil
        currentPassword = nil
        lastGGASentence = nil
        resetReconnectionState()
    }
}

extension RTKNTRIPClient: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                self.connectionState = .failed(NTRIPError.invalidResponse)
            }
            completionHandler(.cancel)
            return
        }
        
        switch httpResponse.statusCode {
        case 200:
            DispatchQueue.main.async {
                self.isConnected = true
                self.connectionState = .connected
                self.resetReconnectionState()
            }
            startGGATimer()
            completionHandler(.allow)
            
        case 401:
            DispatchQueue.main.async {
                self.connectionState = .failed(NTRIPError.authenticationFailed)
            }
            completionHandler(.cancel)
            
        case 404:
            DispatchQueue.main.async {
                self.connectionState = .failed(NTRIPError.mountpointNotFound)
            }
            completionHandler(.cancel)
            
        default:
            DispatchQueue.main.async {
                self.connectionState = .failed(NTRIPError.serverError(httpResponse.statusCode))
            }
            completionHandler(.cancel)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        rtcmDataSubject.send(data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            
            if let error = error {
                if (error as NSError).code != NSURLErrorCancelled {
                    self.connectionState = .failed(error)
                    self.scheduleReconnection()
                } else {
                    self.connectionState = .disconnected
                }
            } else {
                self.connectionState = .disconnected
            }
        }
        
        stopGGATimer()
    }
}

enum NTRIPError: LocalizedError {
    case invalidConfiguration
    case invalidURL
    case authenticationFailed
    case mountpointNotFound
    case serverError(Int)
    case invalidResponse
    case reconnectionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid NTRIP configuration"
        case .invalidURL:
            return "Invalid NTRIP URL"
        case .authenticationFailed:
            return "NTRIP authentication failed"
        case .mountpointNotFound:
            return "NTRIP mountpoint not found"
        case .serverError(let code):
            return "NTRIP server error: \(code)"
        case .invalidResponse:
            return "Invalid server response"
        case .reconnectionFailed:
            return "Failed to reconnect after multiple attempts"
        }
    }
}