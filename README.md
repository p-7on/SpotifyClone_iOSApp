Spotify Clone App

This is a demo project that implements a simplified Spotify-like music player using the official Spotify API. The app allows users to log in via OAuth, view the currently playing track, and manage their session with secure token handling.

📋 Features

- Spotify login via OAuth 2.0 PKCE Flow
- Secure storage of access tokens in Keychain
- Display of currently playing track (album, song title, artist)
- Auto-login when a valid token is available
- Reactive state management with Combine

🛠️ Tech Stack & Architecture

- SwiftUI – For the user interface
- Combine – For reactive data handling
- AuthenticationServices – For Spotify OAuth integration
- CryptoKit – For generating PKCE code challenge
- Keychain – For secure token storage
- MVVM Architecture – For clean separation of concerns
- SDWebImageSwiftUI – For async image loading

📸📱 Screenshots

<img src="https://github.com/p-7on/SpotifyClone_iOSApp/blob/105f12cbc6dae505f375358570603f78909b4e93/Screenshots/homescreen.png?raw=true" width="250" /> <img src="https://github.com/p-7on/SpotifyClone_iOSApp/blob/105f12cbc6dae505f375358570603f78909b4e93/Screenshots/login_oauth.png?raw=true" width="250" /> <img src="https://github.com/p-7on/SpotifyClone_iOSApp/blob/105f12cbc6dae505f375358570603f78909b4e93/Screenshots/playback.png?raw=true" width="250" /> 

<img src="https://github.com/p-7on/SpotifyClone_iOSApp/blob/105f12cbc6dae505f375358570603f78909b4e93/Screenshots/no_song_playing.png?raw=true" width="250" />


