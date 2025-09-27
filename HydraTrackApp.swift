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
    @StateObject private var subscriptionService = SubscriptionService.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        ReminderService.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(subscriptionService)
                .preferredColorScheme(.dark)
                .task {
                    await subscriptionService.updateSubscriptionStatus()
                }
                .onOpenURL { url in
                    WidgetSyncManager.shared.handleWidgetAction(url: url, context: persistenceController.viewContext)
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initial sync with widget
        WidgetSyncManager.shared.syncHydrationData(context: StorageService.shared.persistentContainer.viewContext)
        
        // Register for notifications
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Sync data when app enters background
        WidgetSyncManager.shared.syncHydrationData(context: StorageService.shared.persistentContainer.viewContext)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Sync data when app will enter foreground
        WidgetSyncManager.shared.syncHydrationData(context: StorageService.shared.persistentContainer.viewContext)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
