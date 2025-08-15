import Foundation

protocol NMEASentence {
    var talkerID: String { get }
    var sentenceID: String { get }
    var checksum: String { get }
    var isValid: Bool { get }
}

struct GGASentence: NMEASentence {
    let talkerID: String
    let sentenceID: String = "GGA"
    let checksum: String
    let timestamp: String
    let latitude: Double?
    let latitudeDirection: String
    let longitude: Double?
    let longitudeDirection: String
    let fixQuality: Int
    let satelliteCount: Int
    let hdop: Double?
    let altitude: Double?
    let altitudeUnit: String
    let geoidHeight: Double?
    let geoidUnit: String
    let dgpsAge: Double?
    let dgpsStation: String?
    
    var isValid: Bool {
        return fixQuality > 0 && latitude != nil && longitude != nil
    }
    
    var gnssPosition: GNSSPosition? {
        guard let lat = latitude,
              let lon = longitude,
              let alt = altitude,
              let hdopValue = hdop else { return nil }
        
        let adjustedLat = latitudeDirection == "S" ? -lat : lat
        let adjustedLon = longitudeDirection == "W" ? -lon : lon
        
        return GNSSPosition(
            latitude: adjustedLat,
            longitude: adjustedLon,
            altitude: alt,
            horizontalAccuracy: hdopValue * 3.0,
            verticalAccuracy: hdopValue * 5.0,
            timestamp: Date(),
            fixQuality: GNSSPosition.FixQuality(rawValue: fixQuality) ?? .invalid,
            satelliteCount: satelliteCount,
            hdop: hdopValue,
            vdop: nil,
            pdop: nil
        )
    }
}

struct RMCSentence: NMEASentence {
    let talkerID: String
    let sentenceID: String = "RMC"
    let checksum: String
    let timestamp: String
    let status: String
    let latitude: Double?
    let latitudeDirection: String
    let longitude: Double?
    let longitudeDirection: String
    let speedOverGround: Double?
    let courseOverGround: Double?
    let date: String
    let magneticVariation: Double?
    let magneticVariationDirection: String
    let mode: String?
    
    var isValid: Bool {
        return status == "A" && latitude != nil && longitude != nil
    }
}

struct GSASentence: NMEASentence {
    let talkerID: String
    let sentenceID: String = "GSA"
    let checksum: String
    let mode: String
    let fixType: Int
    let satelliteIDs: [Int]
    let pdop: Double?
    let hdop: Double?
    let vdop: Double?
    
    var isValid: Bool {
        return fixType > 1
    }
}