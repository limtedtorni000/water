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
        AnalyticsService.shared.startSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    AnalyticsService.shared.endSession()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    AnalyticsService.shared.startSession()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    AnalyticsService.shared.endSession()
                }
        }
    }
}
