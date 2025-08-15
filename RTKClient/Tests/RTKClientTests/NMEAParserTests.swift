import XCTest
@testable import RTKClient

final class NMEAParserTests: XCTestCase {
    
    private var parser: RTKNMEAParser!
    
    override func setUp() {
        super.setUp()
        parser = RTKNMEAParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    func testValidGGASentenceParsing() {
        let ggaSentence = "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47"
        
        let result = parser.parseGGA(ggaSentence)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.talkerID, "GP")
        XCTAssertEqual(result?.fixQuality, 1)
        XCTAssertEqual(result?.satelliteCount, 8)
        XCTAssertEqual(result?.hdop, 0.9)
        XCTAssertEqual(result?.altitude, 545.4)
        XCTAssertTrue(result?.isValid ?? false)
    }
    
    func testValidRTKGGASentenceParsing() {
        let rtkGGASentence = "$GPGGA,123519,4807.038,N,01131.000,E,4,12,0.5,545.4,M,46.9,M,1.2,0001*6E"
        
        let result = parser.parseGGA(rtkGGASentence)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.fixQuality, 4) // RTK fix
        XCTAssertEqual(result?.satelliteCount, 12)
        XCTAssertEqual(result?.hdop, 0.5)
        XCTAssertEqual(result?.dgpsAge, 1.2)
    }
    
    func testChecksumValidation() {
        let validSentence = "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47"
        let invalidSentence = "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*48"
        
        XCTAssertTrue(parser.validateChecksum(validSentence))
        XCTAssertFalse(parser.validateChecksum(invalidSentence))
    }
    
    func testMultipleSentenceParsing() {
        let nmeaData = """
        $GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47\r\n
        $GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A\r\n
        $GPGSA,A,3,01,02,03,04,05,06,07,08,09,10,11,12,1.0,0.9,0.5*3E\r\n
        """.data(using: .ascii)!
        
        let sentences = parser.parse(nmeaData)
        
        XCTAssertEqual(sentences.count, 3)
        XCTAssertTrue(sentences[0] is GGASentence)
        XCTAssertTrue(sentences[1] is RMCSentence)
        XCTAssertTrue(sentences[2] is GSASentence)
    }
    
    func testCoordinateConversion() {
        let ggaSentence = "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47"
        
        guard let result = parser.parseGGA(ggaSentence),
              let position = result.gnssPosition else {
            XCTFail("Failed to parse GGA sentence")
            return
        }
        
        XCTAssertEqual(position.latitude, 48.1173, accuracy: 0.0001)
        XCTAssertEqual(position.longitude, 11.5167, accuracy: 0.0001)
    }
    
    func testInvalidSentenceHandling() {
        let invalidSentence = "INVALID_SENTENCE"
        
        let result = parser.parseGGA(invalidSentence)
        
        XCTAssertNil(result)
    }
    
    func testEmptyDataHandling() {
        let emptyData = Data()
        
        let sentences = parser.parse(emptyData)
        
        XCTAssertTrue(sentences.isEmpty)
    }
    
    func testPartialDataHandling() {
        let partialData = "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47\r\n$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W".data(using: .ascii)!
        
        let sentences = parser.parse(partialData)
        
        XCTAssertEqual(sentences.count, 1) // Only complete sentence should be parsed
        XCTAssertTrue(sentences[0] is GGASentence)
    }
}