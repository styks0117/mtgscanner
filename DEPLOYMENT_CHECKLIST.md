# Deployment Checklist

Use this checklist when deploying MTG Scanner to your iPhone for the first time.

## Pre-Deployment ✓

- [ ] Mac with macOS 13.0+ installed
- [ ] Xcode 15.0+ installed (from Mac App Store)
- [ ] iPhone running iOS 17.0+ 
- [ ] USB cable (Lightning or USB-C depending on iPhone model)
- [ ] Apple ID credentials ready

## Xcode Setup ✓

- [ ] Open `MTGScanner.xcodeproj` in Xcode
- [ ] Add Apple ID to Xcode:
  - Xcode → Settings (or Preferences) → Accounts
  - Click "+" button → Select Apple ID → Sign in
  - Verify your account appears in the list
- [ ] Project is loaded without errors

## Code Signing Configuration ✓

- [ ] Select "MTGScanner" project in navigator (left panel)
- [ ] Select "MTGScanner" target (under TARGETS)
- [ ] Go to "Signing & Capabilities" tab
- [ ] Check "Automatically manage signing"
- [ ] Select your Apple ID under "Team" dropdown
- [ ] Verify "Signing Certificate" shows your name
- [ ] If bundle ID conflict:
  - Change "Bundle Identifier" to unique value
  - Example: `com.yourname.mtgscanner`
  - Or: `com.github.yourusername.mtgscanner`

## Device Connection ✓

- [ ] Connect iPhone to Mac with USB cable
- [ ] Unlock iPhone
- [ ] On iPhone, tap "Trust This Computer" when prompted
- [ ] Enter iPhone passcode if requested
- [ ] In Xcode toolbar, click device dropdown (next to Play button)
- [ ] Verify your iPhone appears in the list
- [ ] Select your iPhone

## Build & Install ✓

- [ ] In Xcode, click Play button (▶️) or press Cmd+R
- [ ] Wait for "Build Succeeded" message
- [ ] Wait for "Running MTGScanner on [Your iPhone]" message
- [ ] Check iPhone - app icon should appear

## First Launch Setup ✓

- [ ] On iPhone: Settings → General → VPN & Device Management
- [ ] Under "Developer App", tap your Apple ID
- [ ] Tap "Trust [Your Apple ID]"
- [ ] Tap "Trust" in confirmation dialog
- [ ] Return to Home Screen
- [ ] Tap MTG Scanner app icon
- [ ] App should launch successfully

## App Permissions ✓

- [ ] Grant camera permission when prompted
- [ ] Camera preview should appear in app
- [ ] If camera is black:
  - Settings → Privacy & Security → Camera
  - Enable for "MTG Scanner"
  - Restart app

## Functionality Testing ✓

- [ ] Camera preview is visible
- [ ] Point camera at a Magic card
- [ ] Wait 2-3 seconds for scan
- [ ] Check "Detected:" text appears
- [ ] Verify card appears in list below
- [ ] Tap a card - detail sheet should open
- [ ] Change condition/foil/quantity - tap Save
- [ ] Verify changes reflected in list
- [ ] Swipe left on a card → Delete
- [ ] Tap ⋯ menu → Export CSV
- [ ] Share sheet should appear
- [ ] Select a sharing method (Files, Mail, etc.)
- [ ] Verify CSV file is created
- [ ] Tap ⋯ menu → Clear All
- [ ] Verify all cards are removed

## Post-Testing ✓

- [ ] Close app normally (swipe up from bottom)
- [ ] Reopen app
- [ ] Verify scanned cards persisted (if any left)
- [ ] Try scanning different cards
- [ ] Monitor for crashes or errors

## Common Issues

### Build Fails
- Clean build folder: Xcode → Product → Clean Build Folder (Cmd+Shift+K)
- Restart Xcode
- Check Signing & Capabilities configuration

### Can't Install on iPhone
- Ensure iPhone is unlocked and trusted
- Check iPhone has enough storage space
- Try different USB cable/port
- Restart both Mac and iPhone

### App Crashes on Launch
- Check you're running iOS 17.0+
- Trust the developer certificate (see First Launch Setup)
- Check Xcode console for error messages

### Camera Doesn't Work
- Grant camera permission in Settings
- Ensure no other app is using camera
- Try closing other camera apps
- Restart MTG Scanner

### Cards Not Being Detected
- Ensure good lighting
- Hold card steady
- Position card name in center of camera view
- Try a common card like "Lightning Bolt"
- Check "Detected:" text to see what OCR recognized

## Success Indicators

✅ App installs without errors
✅ App launches without crashing  
✅ Camera preview is visible
✅ Cards can be scanned and added
✅ Cards persist after closing app
✅ CSV export works
✅ No crashes during normal use

## Congratulations!

If all checks pass, your MTG Scanner is working correctly! You can now:
- Scan your Magic card collection
- Track condition and foil status
- Export to CSV for inventory management
- Edit card details as needed

Enjoy scanning! 🎴✨
