//
//  HydraTrackApp.swift
//  HydraTrack
//
//  Created by GH on 21/9/2025.
//

import SwiftUI
import UserNotifications
import CoreData

@main
struct HydraTrackApp: App {
    let persistenceController = StorageService.shared.persistentContainer
    
    init() {
        ReminderService.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
