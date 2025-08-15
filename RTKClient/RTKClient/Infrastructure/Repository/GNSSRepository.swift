import Foundation
import CoreData

class GNSSRepository: GNSSRepositoryProtocol {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RTKDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func savePosition(_ position: GNSSPosition) {
        let positionEntity = NSEntityDescription.entity(forEntityName: "PositionEntity", in: context)!
        let managedPosition = NSManagedObject(entity: positionEntity, insertInto: context)
        
        managedPosition.setValue(position.latitude, forKey: "latitude")
        managedPosition.setValue(position.longitude, forKey: "longitude")
        managedPosition.setValue(position.altitude, forKey: "altitude")
        managedPosition.setValue(position.horizontalAccuracy, forKey: "horizontalAccuracy")
        managedPosition.setValue(position.verticalAccuracy, forKey: "verticalAccuracy")
        managedPosition.setValue(position.timestamp, forKey: "timestamp")
        managedPosition.setValue(position.fixQuality.rawValue, forKey: "fixQuality")
        managedPosition.setValue(position.satelliteCount, forKey: "satelliteCount")
        managedPosition.setValue(position.hdop, forKey: "hdop")
        managedPosition.setValue(position.vdop, forKey: "vdop")
        managedPosition.setValue(position.pdop, forKey: "pdop")
        
        do {
            try context.save()
        } catch {
            print("Failed to save position: \(error)")
        }
    }
    
    func getRecentPositions(limit: Int) -> [GNSSPosition] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PositionEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = limit
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { managedObject in
                guard let latitude = managedObject.value(forKey: "latitude") as? Double,
                      let longitude = managedObject.value(forKey: "longitude") as? Double,
                      let altitude = managedObject.value(forKey: "altitude") as? Double,
                      let horizontalAccuracy = managedObject.value(forKey: "horizontalAccuracy") as? Double,
                      let verticalAccuracy = managedObject.value(forKey: "verticalAccuracy") as? Double,
                      let timestamp = managedObject.value(forKey: "timestamp") as? Date,
                      let fixQualityRaw = managedObject.value(forKey: "fixQuality") as? Int,
                      let satelliteCount = managedObject.value(forKey: "satelliteCount") as? Int else {
                    return nil
                }
                
                let hdop = managedObject.value(forKey: "hdop") as? Double
                let vdop = managedObject.value(forKey: "vdop") as? Double
                let pdop = managedObject.value(forKey: "pdop") as? Double
                
                return GNSSPosition(
                    latitude: latitude,
                    longitude: longitude,
                    altitude: altitude,
                    horizontalAccuracy: horizontalAccuracy,
                    verticalAccuracy: verticalAccuracy,
                    timestamp: timestamp,
                    fixQuality: GNSSPosition.FixQuality(rawValue: fixQualityRaw) ?? .invalid,
                    satelliteCount: satelliteCount,
                    hdop: hdop,
                    vdop: vdop,
                    pdop: pdop
                )
            }
        } catch {
            print("Failed to fetch positions: \(error)")
            return []
        }
    }
    
    func clearHistory() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PositionEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
}