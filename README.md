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

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Setup

1. Clone the repository
2. Open the project in Xcode
3. Build and run on a physical device (camera access required)

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

1. Launch the app and grant camera permission
2. Point your camera at a Magic: The Gathering card
3. The app will automatically detect and scan the card name
4. Card details are fetched from Scryfall and added to your collection
5. Tap any card to edit its condition, foil status, or quantity
6. Use the menu (⋯) to export your collection to CSV or clear all cards
