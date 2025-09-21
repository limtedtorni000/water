import Foundation
import CoreData
import SwiftUI

class StorageService {
    static let shared = StorageService()
    private init() {}
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "HydraTrack")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save Core Data: \(error)")
        }
    }
    
    func addIntake(type: IntakeType, amount: Double, date: Date = Date()) {
        let entry = IntakeEntry(context: context)
        entry.type = type.rawValue
        entry.amount = amount
        entry.date = date
        
        save()
    }
    
    func getIntakeType(for entry: IntakeEntry) -> IntakeType {
        return IntakeType(rawValue: entry.type ?? "water") ?? .water
    }
    
    func fetchEntries(for date: Date) -> [IntakeEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }
    
    func fetchEntries(forDateRange start: Date, end: Date) -> [IntakeEntry] {
        let request: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", start as NSDate, end as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }
    
    func getIntakeEntries(for lastDays: Int) -> [IntakeEntry] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -lastDays, to: endDate)!
        
        let request: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }
    
    func deleteEntry(_ entry: IntakeEntry) {
        context.delete(entry)
        save()
    }
    
    func exportToCSV() -> String {
        let request: NSFetchRequest<IntakeEntry> = IntakeEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        var csv = "Date,Type,Amount\n"
        
        do {
            let entries = try context.fetch(request)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            
            for entry in entries {
                csv += "\(formatter.string(from: entry.date ?? Date())),\(entry.type ?? "unknown"),\(entry.amount)\n"
            }
        } catch {
            print("Failed to export entries: \(error)")
        }
        
        return csv
    }
}