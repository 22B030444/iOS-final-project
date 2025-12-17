# Hearo - iOS Music Streaming App

A modern music streaming application for iOS built with Swift and UIKit. Hearo allows users to discover, search, and listen to music using the iTunes Search API.

## Features

### Core Features
- **Music Playback**: Stream 30-second previews from iTunes catalog with full playback controls
- **Search**: Search for tracks and albums with real-time results
- **Home Discovery**: Curated sections for Top Hits, Recently Played, and New Albums
- **Mini Player**: Persistent mini player across all tabs for continuous playback control

### Library Management
- **Liked Songs**: Save favorite tracks with search functionality
- **Playlists**: Create, edit, and manage custom playlists
- **Albums**: Browse and save albums to your library
- **Downloads**: Mark tracks for offline access (simulated)
- **Recently Played**: Automatic tracking of listening history

### Additional Features
- **Artist Pages**: View artist information and track listings
- **Shuffle & Repeat**: Multiple playback modes (repeat off/one/all)
- **Profile Screen**: User profile with statistics and settings

## Requirements

- **iOS**: 16.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.0 or later
- **macOS**: Ventura 13.0 or later (for development)

## Dependencies

This project uses **no external dependencies** or package managers. All functionality is implemented using native iOS frameworks:

- **UIKit**: User interface components
- **AVFoundation**: Audio playback
- **Foundation**: Core utilities and networking
- **UserDefaults**: Local data persistence

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/HearoApp.git
cd HearoApp
```

### 2. Open in Xcode

```bash
open HearoApp.xcodeproj
```

Or manually:
1. Launch Xcode
2. Select "Open a project or file"
3. Navigate to the `HearoApp.xcodeproj` file
4. Click "Open"

### 3. Configure Signing

1. Select the project in the Navigator (left sidebar)
2. Select the "HearoApp" target
3. Go to "Signing & Capabilities" tab
4. Select your Team from the dropdown
5. Ensure "Automatically manage signing" is checked

### 4. Build and Run

1. Select a simulator or connected device from the toolbar
2. Press `Cmd + R` or click the Play button
3. Wait for the build to complete

## Project Structure

```
HearoApp/
├── Models/
│   ├── Track.swift              # Track data model
│   ├── Album.swift              # Album data model
│   └── Playlist.swift           # Playlist data model
│
├── Services/
│   ├── NetworkManager.swift     # API calls to iTunes Search API
│   ├── MusicPlayerManager.swift # Global audio playback singleton
│   ├── LikedSongsManager.swift  # Liked songs persistence
│   ├── PlaylistManager.swift    # Playlist CRUD operations
│   ├── SavedAlbumsManager.swift # Album library management
│   ├── PlayHistoryManager.swift # Recently played tracking
│   └── DownloadsManager.swift   # Download state management
│
├── Views/
│   ├── TrackTableViewCell.swift # Table view cell for tracks
│   ├── TrackTableViewCell.xib   # Cell XIB layout
│   ├── TrackCollectionViewCell.swift # Collection view cell
│   └── MiniPlayerView.swift     # Mini player component
│
├── Controllers/
│   ├── MainTabBarController.swift    # Tab bar with mini player
│   ├── HomeViewController.swift      # Home/discovery screen
│   ├── SearchViewController.swift    # Search functionality
│   ├── LibraryViewController.swift   # Library menu
│   ├── PlayerViewController.swift    # Full-screen player
│   ├── LikedSongsViewController.swift
│   ├── PlaylistsViewController.swift
│   ├── PlaylistViewController.swift
│   ├── AlbumsViewController.swift
│   ├── AlbumViewController.swift
│   ├── ArtistViewController.swift
│   ├── ProfileViewController.swift
│   └── LoginViewController.swift
│
├── Resources/
│   ├── Assets.xcassets/         # Images and colors
│   ├── Main.storyboard          # UI layouts
│   └── LaunchScreen.storyboard
│
├── Supporting Files/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
│
└── XIBs/
    ├── TrackTableViewCell.xib
    └── MiniPlayerView.xib
```

## API Reference

This app uses the [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/index.html) which is free and requires no authentication.

### Endpoints Used

| Endpoint | Description |
|----------|-------------|
| `/search?term={query}&entity=song` | Search for tracks |
| `/search?term={query}&entity=album` | Search for albums |
| `/lookup?id={collectionId}&entity=song` | Get album tracks |

### Example Response

```json
{
  "resultCount": 50,
  "results": [
    {
      "trackId": 123456,
      "trackName": "Song Title",
      "artistName": "Artist Name",
      "collectionName": "Album Name",
      "artworkUrl100": "https://...",
      "previewUrl": "https://..."
    }
  ]
}
```

## Color Palette

| Color Name | Hex Code | Usage |
|------------|----------|-------|
| BackgroundDark | `#1A1A2E` | Main background |
| AccentPurple | `#9D4EDD` | Buttons, highlights |
| CardBackground | `#2D2D44` | Cards, cells |
| TextPrimary | `#FFFFFF` | Primary text |
| TextSecondary | `#9D9D9D` | Secondary text |

## Architecture

The app follows the **MVC (Model-View-Controller)** pattern with additional Service layers:

- **Models**: Data structures for Track, Album, Playlist
- **Views**: UIKit views, cells, and XIBs
- **Controllers**: UIViewControllers handling user interaction
- **Services**: Singleton managers for data and business logic

### Key Design Patterns

- **Singleton**: MusicPlayerManager, NetworkManager, all data managers
- **Delegate**: MiniPlayerDelegate, UITableViewDelegate/DataSource
- **Observer**: NotificationCenter for player state changes
- **Target-Action**: Button interactions

## Running on Physical Device

1. Connect your iOS device via USB
2. Trust the computer on your device if prompted
3. Select your device from Xcode's device dropdown
4. Ensure your Apple ID is configured in Xcode preferences
5. Build and run (`Cmd + R`)

Note: Free Apple Developer accounts have limitations on provisioning profiles (7-day expiration).

## Troubleshooting

### Build Errors

**"No such module" error**
- Clean build folder: `Cmd + Shift + K`
- Rebuild: `Cmd + B`

**Signing errors**
- Verify your Team is selected in Signing & Capabilities
- Try changing the Bundle Identifier to something unique

### Runtime Issues

**No audio playback**
- Check device is not in Silent mode
- Verify internet connection (streaming requires network)
- Check console for AVPlayer errors

**Cells not displaying**
- Ensure XIB files are included in target
- Verify cell identifiers match in code and Storyboard

## Known Limitations

- Audio previews are limited to 30 seconds (iTunes API limitation)
- Downloads are simulated (tracks marked but not actually downloaded)
- No user authentication (local storage only)
- Search results limited to iTunes catalog

## Future Enhancements

- [ ] Background audio playback
- [ ] Lock screen controls
- [ ] CarPlay support
- [ ] Actual offline downloads
- [ ] Social sharing features
- [ ] Equalizer settings
- [ ] Lyrics display
- [ ] Queue management

## License

This project is created for educational purposes.

## Acknowledgments

- [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/) - Music data and previews
- [SF Symbols](https://developer.apple.com/sf-symbols/) - iOS system icons

---

**Developed with ❤️ using Swift and UIKit**
