# StoreKit Configuration

## App Store Connect Setup Required

Before testing subscriptions, you need to configure products in App Store Connect:

### 1. Create In-App Purchase Products
- Go to App Store Connect → Your App → In-App Purchases
- Create two products:
  - **Subscription**: 
    - Product ID: `com.HydraTrack.premium.monthly`
    - Subscription Group: Create a new group
    - Price: $0.99/month
    - Free Trial: 7 days
    - Localization: English (and other languages as needed)
  
  - **Non-Consumable**:
    - Product ID: `com.HydraTrack.premium.lifetime`
    - Price: $29.99 one-time

### 2. Configure Subscription Group
- Create a subscription group with display name "Premium"
- Set up localizations for all supported languages
- Review status: Must be "Ready for Sale" or "Waiting for Review"

### 3. Enable StoreKit in Xcode
1. Go to Project Settings → Signing & Capabilities
2. Click "+ Capability"
3. Add "In-App Purchase"

### 4. Testing with Sandbox
- Create sandbox tester accounts in App Store Connect
- Use these accounts to test purchases without real charges
- Test on real devices (StoreKit testing has limitations on simulator)

### 5. App Review Guidelines Compliance
- ✅ Free app with subscription features
- ✅ Clear value proposition for premium features
- ✅ 7-day free trial prominently displayed
- ✅ Restore purchases functionality
- ✅ No blocking core functionality
- ✅ Privacy policy and terms of service links

### 6. Features Behind Subscription
- Advanced analytics and charts
- AI insights and recommendations
- Achievement system
- Data export functionality
- Unlimited history storage
- Advanced reminder settings

### 7. Implementation Notes
- Uses StoreKit 2 for modern, Swift-friendly API
- Supports Family Sharing
- Handles subscription status changes gracefully
- Tracks revenue analytics
- Complies with Apple's subscription guidelines