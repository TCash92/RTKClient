import Foundation

class RTKNMEAParser: NMEAParserProtocol {
    
    private var buffer = Data()
    private let maxBufferSize = 8192
    
    func parse(_ data: Data) -> [NMEASentence] {
        buffer.append(data)
        
        if buffer.count > maxBufferSize {
            let startIndex = buffer.count - maxBufferSize
            buffer = buffer.subdata(in: startIndex..<buffer.count)
        }
        
        var sentences: [NMEASentence] = []
        
        guard let dataString = String(data: buffer, encoding: .ascii) else {
            return sentences
        }
        
        let lines = dataString.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty { continue }
            
            if index == lines.count - 1 && !trimmedLine.hasSuffix("\r") && !trimmedLine.hasSuffix("\n") {
                if let remainingData = trimmedLine.data(using: .ascii) {
                    buffer = remainingData
                }
                break
            }
            
            if let sentence = parseSentence(trimmedLine) {
                sentences.append(sentence)
            }
        }
        
        if sentences.count > 0 {
            buffer = Data()
        }
        
        return sentences
    }
    
    private func parseSentence(_ sentence: String) -> NMEASentence? {
        guard sentence.hasPrefix("$") && sentence.contains("*") else {
            return nil
        }
        
        guard validateChecksum(sentence) else {
            return nil
        }
        
        let components = sentence.dropFirst().components(separatedBy: "*")
        guard components.count >= 2 else { return nil }
        
        let sentenceBody = components[0]
        let checksum = components[1]
        let fields = sentenceBody.components(separatedBy: ",")
        
        guard let talkerAndSentence = fields.first else { return nil }
        
        let talkerID = String(talkerAndSentence.prefix(2))
        let sentenceID = String(talkerAndSentence.suffix(3))
        
        switch sentenceID {
        case "GGA":
            return parseGGA(sentence)
        case "RMC":
            return parseRMC(sentence)
        case "GSA":
            return parseGSA(sentence)
        default:
            return nil
        }
    }
    
    func parseGGA(_ sentence: String) -> GGASentence? {
        let components = sentence.dropFirst().components(separatedBy: "*")
        guard components.count >= 2 else { return nil }
        
        let sentenceBody = components[0]
        let checksum = components[1]
        let fields = sentenceBody.components(separatedBy: ",")
        
        guard fields.count >= 15 else { return nil }
        
        let talkerID = String(fields[0].prefix(2))
        let timestamp = fields[1]
        let latitudeString = fields[2]
        let latitudeDirection = fields[3]
        let longitudeString = fields[4]
        let longitudeDirection = fields[5]
        let fixQualityString = fields[6]
        let satelliteCountString = fields[7]
        let hdopString = fields[8]
        let altitudeString = fields[9]
        let altitudeUnit = fields[10]
        let geoidHeightString = fields[11]
        let geoidUnit = fields[12]
        let dgpsAgeString = fields[13]
        let dgpsStation = fields[14]
        
        let latitude = parseCoordinate(latitudeString)
        let longitude = parseCoordinate(longitudeString)
        let fixQuality = Int(fixQualityString) ?? 0
        let satelliteCount = Int(satelliteCountString) ?? 0
        let hdop = Double(hdopString)
        let altitude = Double(altitudeString)
        let geoidHeight = Double(geoidHeightString)
        let dgpsAge = Double(dgpsAgeString)
        
        return GGASentence(
            talkerID: talkerID,
            checksum: checksum,
            timestamp: timestamp,
            latitude: latitude,
            latitudeDirection: latitudeDirection,
            longitude: longitude,
            longitudeDirection: longitudeDirection,
            fixQuality: fixQuality,
            satelliteCount: satelliteCount,
            hdop: hdop,
            altitude: altitude,
            altitudeUnit: altitudeUnit,
            geoidHeight: geoidHeight,
            geoidUnit: geoidUnit,
            dgpsAge: dgpsAge,
            dgpsStation: dgpsStation.isEmpty ? nil : dgpsStation
        )
    }
    
    func parseRMC(_ sentence: String) -> RMCSentence? {
        let components = sentence.dropFirst().components(separatedBy: "*")
        guard components.count >= 2 else { return nil }
        
        let sentenceBody = components[0]
        let checksum = components[1]
        let fields = sentenceBody.components(separatedBy: ",")
        
        guard fields.count >= 12 else { return nil }
        
        let talkerID = String(fields[0].prefix(2))
        let timestamp = fields[1]
        let status = fields[2]
        let latitudeString = fields[3]
        let latitudeDirection = fields[4]
        let longitudeString = fields[5]
        let longitudeDirection = fields[6]
        let speedString = fields[7]
        let courseString = fields[8]
        let date = fields[9]
        let magneticVariationString = fields[10]
        let magneticVariationDirection = fields[11]
        let mode = fields.count > 12 ? fields[12] : nil
        
        let latitude = parseCoordinate(latitudeString)
        let longitude = parseCoordinate(longitudeString)
        let speed = Double(speedString)
        let course = Double(courseString)
        let magneticVariation = Double(magneticVariationString)
        
        return RMCSentence(
            talkerID: talkerID,
            checksum: checksum,
            timestamp: timestamp,
            status: status,
            latitude: latitude,
            latitudeDirection: latitudeDirection,
            longitude: longitude,
            longitudeDirection: longitudeDirection,
            speedOverGround: speed,
            courseOverGround: course,
            date: date,
            magneticVariation: magneticVariation,
            magneticVariationDirection: magneticVariationDirection,
            mode: mode
        )
    }
    
    func parseGSA(_ sentence: String) -> GSASentence? {
        let components = sentence.dropFirst().components(separatedBy: "*")
        guard components.count >= 2 else { return nil }
        
        let sentenceBody = components[0]
        let checksum = components[1]
        let fields = sentenceBody.components(separatedBy: ",")
        
        guard fields.count >= 18 else { return nil }
        
        let talkerID = String(fields[0].prefix(2))
        let mode = fields[1]
        let fixTypeString = fields[2]
        
        var satelliteIDs: [Int] = []
        for i in 3...14 {
            if let satID = Int(fields[i]), satID > 0 {
                satelliteIDs.append(satID)
            }
        }
        
        let pdopString = fields[15]
        let hdopString = fields[16]
        let vdopString = fields[17]
        
        let fixType = Int(fixTypeString) ?? 0
        let pdop = Double(pdopString)
        let hdop = Double(hdopString)
        let vdop = Double(vdopString)
        
        return GSASentence(
            talkerID: talkerID,
            checksum: checksum,
            mode: mode,
            fixType: fixType,
            satelliteIDs: satelliteIDs,
            pdop: pdop,
            hdop: hdop,
            vdop: vdop
        )
    }
    
    private func parseCoordinate(_ coordinateString: String) -> Double? {
        guard !coordinateString.isEmpty else { return nil }
        
        if coordinateString.contains(".") {
            let parts = coordinateString.components(separatedBy: ".")
            guard parts.count == 2,
                  let wholePart = Double(parts[0]),
                  let fractionalPart = Double("0." + parts[1]) else {
                return nil
            }
            
            let degrees = floor(wholePart / 100)
            let minutes = wholePart.truncatingRemainder(dividingBy: 100) + fractionalPart
            
            return degrees + minutes / 60.0
        } else {
            guard let coordinate = Double(coordinateString) else { return nil }
            let degrees = floor(coordinate / 100)
            let minutes = coordinate.truncatingRemainder(dividingBy: 100)
            return degrees + minutes / 60.0
        }
    }
    
    func validateChecksum(_ sentence: String) -> Bool {
        guard sentence.hasPrefix("$") && sentence.contains("*") else {
            return false
        }
        
        let components = sentence.dropFirst().components(separatedBy: "*")
        guard components.count >= 2 else { return false }
        
        let sentenceBody = components[0]
        let providedChecksum = components[1].uppercased()
        
        var calculatedChecksum: UInt8 = 0
        for character in sentenceBody {
            calculatedChecksum ^= UInt8(character.asciiValue ?? 0)
        }
        
        let calculatedChecksumString = String(format: "%02X", calculatedChecksum)
        
        return calculatedChecksumString == providedChecksum
    }
}