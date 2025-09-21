import Foundation

class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}
    
    // MARK: - Configuration
    private let userDefaults = UserDefaults.standard
    private let analyticsEnabledKey = "analyticsEnabled"
    private let sessionStartKey = "sessionStartTime"
    private let eventCountKey = "analyticsEventCount"
    private let userIdKey = "analyticsUserId"
    private let installDateKey = "analyticsInstallDate"
    private let lastActiveDateKey = "analyticsLastActiveDate"
    private let sessionCountKey = "analyticsSessionCount"
    private let userPropertiesKey = "analyticsUserProperties"
    
    // MARK: - Analytics Configuration
    var isAnalyticsEnabled: Bool {
        get {
            // Default to true for new users
            if userDefaults.object(forKey: analyticsEnabledKey) == nil {
                userDefaults.set(true, forKey: analyticsEnabledKey)
            }
            return userDefaults.bool(forKey: analyticsEnabledKey)
        }
        set {
            userDefaults.set(newValue, forKey: analyticsEnabledKey)
            if newValue {
                trackEvent(.analytics_enabled)
            } else {
                trackEvent(.analytics_disabled)
            }
        }
    }
    
    var userId: String {
        if let existingId = userDefaults.string(forKey: userIdKey) {
            return existingId
        }
        
        let newId = UUID().uuidString
        userDefaults.set(newId, forKey: userIdKey)
        return newId
    }
    
    var installDate: Date {
        if let date = userDefaults.object(forKey: installDateKey) as? Date {
            return date
        }
        
        let date = Date()
        userDefaults.set(date, forKey: installDateKey)
        return date
    }
    
    var sessionCount: Int {
        get {
            return userDefaults.integer(forKey: sessionCountKey)
        }
        set {
            userDefaults.set(newValue, forKey: sessionCountKey)
        }
    }
    
    // MARK: - Event Tracking
    func trackEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        guard isAnalyticsEnabled else { return }
        
        // Add common parameters
        var allParameters = parameters ?? [:]
        allParameters["user_id"] = userId
        allParameters["session_number"] = sessionCount
        allParameters["days_since_install"] = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        
        // Log to console for debugging
        print("📊 [\(Date().formatted())] Analytics: \(event.name)")
        if !allParameters.isEmpty {
            print("Parameters: \(allParameters)")
        }
        
        // Store event locally
        storeEvent(event, parameters: allParameters)
        
        // Update metrics
        updateMetrics(for: event)
    }
    
    // MARK: - User Properties
    func setUserProperty(_ value: Any, forName name: String) {
        guard isAnalyticsEnabled else { return }
        
        var properties = userProperties
        properties[name] = value
        userDefaults.set(properties, forKey: userPropertiesKey)
        
        trackEvent(.user_property_set, parameters: [
            "property_name": name,
            "property_value": String(describing: value)
        ])
    }
    
    func incrementUserProperty(_ name: String, by amount: Int = 1) {
        guard isAnalyticsEnabled else { return }
        
        var properties = userProperties
        let currentValue = properties[name] as? Int ?? 0
        properties[name] = currentValue + amount
        userDefaults.set(properties, forKey: userPropertiesKey)
        
        trackEvent(.user_property_incremented, parameters: [
            "property_name": name,
            "increment_value": amount
        ])
    }
    
    // MARK: - Session Tracking
    func startSession() {
        guard isAnalyticsEnabled else { return }
        
        // Check if this is a new session (more than 30 minutes since last active)
        let lastActive = userDefaults.object(forKey: lastActiveDateKey) as? Date
        let isNewSession = lastActive == nil || Date().timeIntervalSince(lastActive!) > 30 * 60
        
        if isNewSession {
            sessionCount += 1
            userDefaults.set(Date(), forKey: sessionStartKey)
            trackEvent(.session_started, parameters: [
                "session_number": sessionCount,
                "is_first_session": sessionCount == 1
            ])
        }
        
        userDefaults.set(Date(), forKey: lastActiveDateKey)
    }
    
    func endSession() {
        guard isAnalyticsEnabled else { return }
        
        if let startTime = userDefaults.object(forKey: sessionStartKey) as? Date {
            let sessionDuration = Date().timeIntervalSince(startTime)
            trackEvent(.session_ended, parameters: [
                "session_duration": sessionDuration,
                "session_number": sessionCount
            ])
        }
    }
    
    // MARK: - Funnel Tracking
    func trackFunnelStep(_ funnel: AnalyticsFunnel, step: Int) {
        trackEvent(.funnel_step_completed, parameters: [
            "funnel_name": funnel.rawValue,
            "step_number": step,
            "total_steps": funnel.totalSteps
        ])
    }
    
    // MARK: - Performance Tracking
    func trackTiming(_ eventName: String, duration: TimeInterval, category: String? = nil) {
        trackEvent(.timing_event, parameters: [
            "event_name": eventName,
            "duration_ms": Int(duration * 1000),
            "category": category ?? "general"
        ])
    }
    
    // MARK: - Error Tracking
    func trackError(_ error: Error, context: [String: Any]? = nil) {
        trackEvent(.error_occurred, parameters: [
            "error_message": error.localizedDescription,
            "error_type": String(describing: type(of: error)),
            "context": context ?? [:]
        ])
    }
    
    // MARK: - Screen Tracking
    func trackScreen(_ screenName: String) {
        trackEvent(.screen_viewed, parameters: [
            "screen_name": screenName
        ])
    }
    
    // MARK: - Revenue Tracking (for future monetization)
    func trackRevenue(amount: Double, currency: String = "USD", productId: String? = nil) {
        trackEvent(.purchase, parameters: [
            "revenue_amount": amount,
            "currency": currency,
            "product_id": productId ?? "unknown"
        ])
    }
    
    // MARK: - User Demographics
    func setUserDemographics(ageGroup: String? = nil, gender: String? = nil, country: String? = nil) {
        if let age = ageGroup {
            setUserProperty(age, forName: "age_group")
        }
        if let g = gender {
            setUserProperty(g, forName: "gender")
        }
        if let c = country {
            setUserProperty(c, forName: "country")
        }
    }
    
    // MARK: - App Preferences
    func trackAppPreferences() {
        // Track user preferences
        setUserProperty("water_goal_\(IntakeViewModel().waterGoal)", forName: "preferred_water_goal")
        setUserProperty("caffeine_goal_\(IntakeViewModel().caffeineGoal)", forName: "preferred_caffeine_goal")
        setUserProperty(IntakeViewModel().waterUnit, forName: "preferred_water_unit")
        setUserProperty(IntakeViewModel().caffeineUnit, forName: "preferred_caffeine_unit")
    }
    
    // MARK: - Usage Metrics
    func trackDailyUsage() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayKey = "usage_\(Int(today.timeIntervalSince1970))"
        
        if !userDefaults.bool(forKey: todayKey) {
            userDefaults.set(true, forKey: todayKey)
            incrementUserProperty("days_used")
        }
        
        incrementUserProperty("total_sessions")
    }
    
    // MARK: - Engagement Tracking
    func trackEngagementMetric(_ metric: String, value: Int) {
        incrementUserProperty("\(metric)_count", by: value)
        setUserProperty(value, forName: "last_\(metric)_value")
    }
    
    // MARK: - Private Methods
    private func storeEvent(_ event: AnalyticsEvent, parameters: [String: Any]?) {
        let eventData: [String: Any] = [
            "id": UUID().uuidString,
            "event_name": event.name,
            "timestamp": Date().timeIntervalSince1970,
            "parameters": parameters ?? [:]
        ]
        
        // Store in user defaults for demo (in production, use a proper database)
        if var allEvents = userDefaults.array(forKey: "analyticsEvents") as? [[String: Any]] {
            allEvents.append(eventData)
            // Keep only last 1000 events
            if allEvents.count > 1000 {
                allEvents.removeFirst(allEvents.count - 1000)
            }
            userDefaults.set(allEvents, forKey: "analyticsEvents")
        } else {
            userDefaults.set([eventData], forKey: "analyticsEvents")
        }
    }
    
    private func updateMetrics(for event: AnalyticsEvent) {
        let currentCount = userDefaults.integer(forKey: eventCountKey)
        userDefaults.set(currentCount + 1, forKey: eventCountKey)
        
        // Track specific event counts
        let eventKey = "analytics_event_\(event.name)"
        let eventCount = userDefaults.integer(forKey: eventKey)
        userDefaults.set(eventCount + 1, forKey: eventKey)
    }
    
    private var userProperties: [String: Any] {
        get {
            return userDefaults.dictionary(forKey: userPropertiesKey) ?? [:]
        }
        set {
            userDefaults.set(newValue, forKey: userPropertiesKey)
        }
    }
}

// MARK: - Analytics Events
enum AnalyticsEvent {
    // App Lifecycle
    case app_opened
    case app_closed
    case session_started
    case session_ended
    case analytics_enabled
    case analytics_disabled
    
    // User Actions
    case intake_added(type: String, amount: Double)
    case intake_deleted
    case goal_changed(type: String)
    case unit_changed(type: String)
    case reminder_set(enabled: Bool)
    case history_viewed
    case settings_viewed
    case export_performed
    
    // User Properties
    case user_property_set
    case user_property_incremented
    
    // Funnel & Conversion
    case funnel_step_completed
    case onboarding_completed
    case tutorial_started
    case tutorial_completed
    
    // Performance & Errors
    case timing_event
    case error_occurred
    case crash_reported
    
    // Screen Views
    case screen_viewed
    case analytics_viewed
    case insights_viewed
    
    // Monetization (future)
    case purchase
    case subscription_started
    case subscription_cancelled
    
    var name: String {
        switch self {
        case .app_opened: return "app_opened"
        case .app_closed: return "app_closed"
        case .session_started: return "session_started"
        case .session_ended: return "session_ended"
        case .analytics_enabled: return "analytics_enabled"
        case .analytics_disabled: return "analytics_disabled"
        case .intake_added: return "intake_added"
        case .intake_deleted: return "intake_deleted"
        case .goal_changed: return "goal_changed"
        case .unit_changed: return "unit_changed"
        case .reminder_set: return "reminder_set"
        case .history_viewed: return "history_viewed"
        case .settings_viewed: return "settings_viewed"
        case .export_performed: return "export_performed"
        case .user_property_set: return "user_property_set"
        case .user_property_incremented: return "user_property_incremented"
        case .funnel_step_completed: return "funnel_step_completed"
        case .onboarding_completed: return "onboarding_completed"
        case .tutorial_started: return "tutorial_started"
        case .tutorial_completed: return "tutorial_completed"
        case .timing_event: return "timing_event"
        case .error_occurred: return "error_occurred"
        case .crash_reported: return "crash_reported"
        case .screen_viewed: return "screen_viewed"
        case .analytics_viewed: return "analytics_viewed"
        case .insights_viewed: return "insights_viewed"
        case .purchase: return "purchase"
        case .subscription_started: return "subscription_started"
        case .subscription_cancelled: return "subscription_cancelled"
        }
    }
}

// MARK: - Analytics Funnels
enum AnalyticsFunnel: String {
    case onboarding = "onboarding"
    case firstIntake = "first_intake"
    case goalSetting = "goal_setting"
    case reminderSetup = "reminder_setup"
    case dataExport = "data_export"
    
    var totalSteps: Int {
        switch self {
        case .onboarding: return 3
        case .firstIntake: return 2
        case .goalSetting: return 2
        case .reminderSetup: return 2
        case .dataExport: return 2
        }
    }
}

// MARK: - Analytics Convenience Methods
extension AnalyticsService {
    func trackIntakeAdded(type: IntakeType, amount: Double) {
        trackEvent(.intake_added(type: type.rawValue, amount: amount))
        
        // Track first intake funnel
        let totalIntakes = userProperties["total_intakes"] as? Int ?? 0
        if totalIntakes == 0 {
            trackFunnelStep(.firstIntake, step: 1)
        }
        
        // Update intake count
        setUserProperty(totalIntakes + 1, forName: "total_intakes")
        
        // Track daily usage
        trackDailyUsage()
        
        // Track engagement
        incrementUserProperty("intake_count")
    }
    
    func trackGoalChanged(type: String) {
        trackEvent(.goal_changed(type: type))
    }
    
    func trackUnitChanged(type: String) {
        trackEvent(.unit_changed(type: type))
    }
    
    func trackReminderSet(enabled: Bool) {
        trackEvent(.reminder_set(enabled: enabled))
    }
}