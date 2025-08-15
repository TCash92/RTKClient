import Foundation
import CoreLocation

struct GNSSPosition {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let horizontalAccuracy: Double
    let verticalAccuracy: Double
    let timestamp: Date
    let fixQuality: FixQuality
    let satelliteCount: Int
    let hdop: Double?
    let vdop: Double?
    let pdop: Double?
    
    enum FixQuality: Int, CaseIterable {
        case invalid = 0
        case gps = 1
        case dgps = 2
        case pps = 3
        case rtk = 4
        case rtkFloat = 5
        case estimated = 6
        case manual = 7
        case simulation = 8
        
        var description: String {
            switch self {
            case .invalid: return "Invalid"
            case .gps: return "GPS"
            case .dgps: return "DGPS"
            case .pps: return "PPS"
            case .rtk: return "RTK"
            case .rtkFloat: return "RTK Float"
            case .estimated: return "Estimated"
            case .manual: return "Manual"
            case .simulation: return "Simulation"
            }
        }
        
        var accuracy: String {
            switch self {
            case .rtk: return "±2cm"
            case .rtkFloat: return "±1m"
            case .dgps: return "±3m"
            case .gps: return "±5m"
            default: return "Unknown"
            }
        }
    }
    
    var location: CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: altitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy,
            timestamp: timestamp
        )
    }
}

extension GNSSPosition {
    static let mock = GNSSPosition(
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 10.0,
        horizontalAccuracy: 0.02,
        verticalAccuracy: 0.03,
        timestamp: Date(),
        fixQuality: .rtk,
        satelliteCount: 12,
        hdop: 0.8,
        vdop: 1.2,
        pdop: 1.5
    )
}