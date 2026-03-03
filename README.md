# MTG Scanner

An iOS app for scanning and cataloging Magic: The Gathering cards using OCR technology.

## Features

- **Camera-based Card Scanning**: Uses the device camera and Vision framework to recognize card names via OCR
- **Automatic Card Lookup**: Fetches card details from the Scryfall API
- **Collection Management**: Track your card collection with customizable properties
  - Card condition (Near Mint, Lightly Played, Moderately Played, Heavily Played, Damaged)
  - Foil/Normal finish
  - Quantity tracking
- **CSV Export**: Export your collection to CSV format for use with other tools or inventory systems
- **Smart Duplicate Detection**: Automatically increments quantity for duplicate cards with same condition and finish

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Physical iOS device (camera required - simulator won't work)

## Setup and Deployment to Your iPhone

### Prerequisites

1. **Mac computer** with macOS 13.0 or later
2. **Xcode 15.0 or later** (free from Mac App Store)
3. **iPhone** running iOS 17.0 or later
4. **Apple ID** (free - no paid Developer Account needed for personal testing)

### Installation Steps

#### 1. Clone the Repository

```bash
git clone https://github.com/styks0117/mtgscanner.git
cd mtgscanner
```

#### 2. Open in Xcode

```bash
open MTGScanner.xcodeproj
```

Or double-click `MTGScanner.xcodeproj` in Finder.

#### 3. Configure Code Signing (REQUIRED)

Before you can install on your iPhone:

1. In Xcode, select the **MTGScanner** project in the left navigator
2. Select the **MTGScanner** target
3. Go to the **Signing & Capabilities** tab
4. Check **"Automatically manage signing"**
5. Under **Team**, select your Apple ID from the dropdown
   - If you don't see your Apple ID: click "Add Account...", sign in with your Apple ID
6. Xcode will automatically create a signing certificate
7. If you get a "Bundle Identifier not available" error:
   - Change the Bundle Identifier to something unique like `com.yourname.mtgscanner`

#### 4. Connect Your iPhone

1. Connect your iPhone to your Mac using a USB cable
2. **On your iPhone**: Unlock it and tap **"Trust This Computer"** when prompted
3. In Xcode's top toolbar, click the device dropdown (next to the Play button)
4. Select your iPhone from the list

#### 5. Build and Install

1. Click the **Play button** (▶️) in Xcode's toolbar, or press `Cmd+R`
2. Xcode will build the app and install it on your iPhone
3. Wait for "Running MTGScanner on \[Your iPhone\]" message

#### 6. Trust the Developer Certificate (First Time Only)

On your iPhone:
1. Go to **Settings** → **General** → **VPN & Device Management**
2. Under "Developer App", tap your Apple ID
3. Tap **"Trust \[Your Apple ID\]"** and confirm
4. Return to home screen and launch **MTG Scanner**

### Alternative: TestFlight (For Easier Distribution)

For easier installation without cables:

1. Upload the app to TestFlight (requires free Apple Developer account)
2. Share the TestFlight link with yourself
3. Install TestFlight from the App Store on your iPhone
4. Click the link to install MTG Scanner

Note: This requires more setup but is easier for testing on multiple devices.

## Permissions

The app requires camera access to scan cards. The permission prompt will appear on first launch.

## Architecture

- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns with ViewModels
- **Services**: 
  - `CardRecognitionService`: OCR text recognition using Vision framework
  - `ScryfallService`: API integration with caching
  - `CSVExportService`: Export functionality
- **Models**: Core data structures for cards and conditions

## Usage

1. Launch the app and grant camera permission when prompted
2. Point your camera at a Magic: The Gathering card
3. The app will automatically detect and scan the card name every 2 seconds
4. Card details are fetched from Scryfall and added to your collection
5. Tap any card in the list to edit its condition, foil status, or quantity
6. Swipe left on a card to delete it
7. Use the menu (⋯) to export your collection to CSV or clear all cards
8. Toggle the camera icon to show/hide the camera preview

## Safety & Privacy

### Will This Brick My Phone?

**ABSOLUTELY NOT - This app is completely safe and CANNOT brick your iPhone.**

#### Why It's Safe:

1. ✅ **Sandboxed Environment**: iOS apps run in a restricted sandbox with no access to system files
2. ✅ **Standard APIs Only**: Uses only official Apple frameworks (SwiftUI, Vision, AVFoundation)
3. ✅ **No System Access**: Cannot modify iOS, change system settings, or access other apps
4. ✅ **Permission-Based**: Only accesses camera with your explicit permission
5. ✅ **No Root Access**: Impossible to gain system-level access on non-jailbroken devices
6. ✅ **Reversible**: Simply delete the app to remove all its data
7. ✅ **Open Source**: All code is reviewable in this repository

#### What the App CAN Do:
- Access camera (only when app is open and you grant permission)
- Store scanned card data locally in its own sandbox
- Access internet to query Scryfall API
- Create CSV files in app documents

#### What the App CANNOT Do:
- ❌ Access system files or other apps
- ❌ Make system changes
- ❌ Brick or damage your phone
- ❌ Access your photos, contacts, or other personal data
- ❌ Run in the background without permission
- ❌ Cost you money

### Privacy

- Camera access is only used for scanning cards while the app is open
- No data is sent to external servers except Scryfall API for card lookups
- Your card collection is stored locally on your device only
- No analytics, tracking, or data collection
- No personal information is accessed or stored
## Troubleshooting

### Build Issues

**"No account for team"**
- Add your Apple ID in Xcode → Preferences → Accounts
- Select your Apple ID as the Team in Signing & Capabilities

**"Failed to register bundle identifier"**
- The Bundle Identifier must be unique
- Change it to `com.yourname.mtgscanner` in Signing & Capabilities
- Or use: `com.github.copilot-swe-agent[bot].mtgscanner`

**"Could not launch MTGScanner"**
- You need to trust the developer certificate (see step 6 in Installation)
- Go to Settings → General → VPN & Device Management on your iPhone

### Runtime Issues

**Camera shows black screen**
- Grant camera permission in Settings → Privacy & Security → Camera → MTG Scanner
- Restart the app after granting permission

**OCR not detecting card names**
- Ensure good lighting on the card
- Hold the card steady and flat
- Position the card name clearly in center view
- The app scans every 2 seconds - wait a moment
- Try common English cards first for testing

**Cards not being found on Scryfall**
- Check your internet connection
- The card name must match Scryfall's database
- Misread names won't match - check the "Detected:" text
- Visit scryfall.com to verify the card exists

**App crashes on launch**
- Ensure you're running iOS 17.0 or later
- Check Xcode console for error messages
- Try Clean Build Folder (Cmd+Shift+K) and rebuild

**Data not persisting**
- Data is automatically saved using UserDefaults
- Close the app normally (don't force-quit immediately after scanning)
- If issues persist, check available storage on your device

### Testing Tips

1. **Start with common cards**: Test with well-known cards like "Lightning Bolt" or "Black Lotus"
2. **Good lighting**: Scan in bright, even lighting - avoid shadows
3. **Steady hands**: Hold the camera still for 2-3 seconds
4. **Check detected text**: Look at the "Detected:" label to see what OCR recognized
5. **Edit if needed**: Tap a card to manually correct details if OCR misread
6. **Test export**: Add a few cards and test CSV export to ensure it works

## API Usage

This app uses the [Scryfall API](https://scryfall.com/docs/api) to look up card information:
- Free to use, no authentication required
- Includes caching to reduce API calls
- Rate limits: Be respectful of Scryfall's servers
- Exact name matching for best results

## Known Limitations

- Requires iOS 17.0+ (uses latest SwiftUI features)
- Camera required (won't work in Simulator)
- OCR works best with:
  - English language cards
  - Modern card frames
  - Good lighting conditions
  - Clear, unobstructed card names
- May struggle with:
  - Foreign language cards
  - Heavily played/damaged cards with obscured text
  - Glossy/foil cards with glare
  - Old card frames with unusual fonts

## Future Enhancements

Potential improvements for future versions:
- Support for multiple card recognition in a single image
- Barcode scanning for sealed products
- Price tracking from TCGPlayer
- Collection statistics and insights
- iCloud sync between devices
- Dark mode support
- iPad optimization with split view

## License

Open source - feel free to use and modify.

## Contributing

Issues and pull requests are welcome!

## Support

For questions or issues, please open an issue on GitHub.
