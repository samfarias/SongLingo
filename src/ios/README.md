# SongLingo iOS Client

This is the native iOS application for SongLingo, developed using Swift and SwiftUI. It provides a rich, interactive interface for users to browse songs, learn vocabulary, and practice pronunciation.

## Tech Stack
- **Language**: Swift 5+
- **UI Framework**: SwiftUI
- **Networking**: URLSession / Custom API Layer
- **Integration**: Spotify SDK integration for playback assistance.

## Setup & Installation

### Prerequisites
- [Xcode](https://developer.apple.com/xcode/) 15+ (installed on macOS).

### Running the App
1. **Open the project**:
   Navigate to the `ios/SongLingo` directory and open `SongLingo.xcodeproj` in Xcode.
   ```bash
   cd ios/SongLingo
   open SongLingo.xcodeproj
   ```

2. **Select a Target**:
   Choose an iOS Simulator (e.g., iPhone 15) or a physical device from the scheme selector at the top of Xcode.

3. **Build and Run**:
   Press `Cmd + R` or click the **Run** button to build and launch the application.

### Configuration
Ensure the backend is running (locally or via Docker) as the app will need to communicate with the API. You may need to update the base URL in the app's configuration files (`API/NetworkManager.swift`) to point to your backend's IP address.

## Project Structure
- `SongLingo/`: Main source directory.
  - `API/`: Networking and data fetching logic.
  - `CreateAccView.swift`: Create account view.
  - `Dashboard.swift`: Main dashboard view.
  - `SpotifyAuthManager.swift`: Handles Spotify authentication flow.
  - `Assets.xcassets`: Image and color assets.

## Code Style
The iOS codebase follows the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
