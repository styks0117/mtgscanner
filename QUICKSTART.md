# Quick Start Guide - MTG Scanner

## TL;DR - Getting the App on Your iPhone

### What You Need
- Mac with Xcode (free from App Store)
- iPhone with iOS 17+
- USB cable
- Your Apple ID

### 5-Minute Setup

1. **Open in Xcode**
   ```bash
   open MTGScanner.xcodeproj
   ```

2. **Add Your Apple ID**
   - Xcode → Settings → Accounts → Click "+" → Sign in

3. **Configure Signing**
   - Select "MTGScanner" project in left panel
   - Select "MTGScanner" target
   - Go to "Signing & Capabilities" tab
   - Choose your Apple ID under "Team"
   - If bundle ID error: change to `com.yourname.mtgscanner`

4. **Connect iPhone & Build**
   - Plug in iPhone with USB cable
   - Unlock iPhone → tap "Trust This Computer"
   - Select your iPhone from device dropdown in Xcode
   - Click Play button (▶️) or press Cmd+R

5. **Trust Certificate (First Time Only)**
   - On iPhone: Settings → General → VPN & Device Management
   - Tap your Apple ID → Tap "Trust"
   - Launch MTG Scanner!

## Is This Safe?

**YES - 100% SAFE. This CANNOT brick your phone.**

- iOS apps are sandboxed - no system access
- Uses only standard Apple APIs
- You can delete it anytime
- No personal data accessed
- Open source code you can review

## How It Works

1. Point camera at a Magic card
2. App scans card name every 2 seconds
3. Looks up card on Scryfall
4. Adds to your collection
5. Tap card to edit condition/foil/quantity
6. Export to CSV when done

## Tips

- Use good lighting
- Hold camera steady
- Start with common English cards
- Check "Detected:" text to see what OCR found
- Swipe to delete cards
- Use ⋯ menu to export or clear all

## Troubleshooting

**Camera shows nothing?**
→ Grant permission in Settings → Privacy → Camera

**Card not found?**
→ Check the "Detected:" text - if OCR misread, the name won't match

**Can't install?**
→ Trust the certificate in Settings → General → VPN & Device Management

**Still stuck?**
→ Check the main README.md for detailed troubleshooting

## No Xcode? Alternative Options

### Option 1: Get Someone to Build It
Ask a friend with a Mac to build it for you using these instructions

### Option 2: Wait for TestFlight
If there's enough interest, the app could be published to TestFlight for easier installation

### Option 3: Buy a Mac
Xcode only runs on macOS - you need a Mac to build iOS apps

## Need Help?

Open an issue on GitHub with:
- What step you're on
- What error you see
- Screenshots if relevant
