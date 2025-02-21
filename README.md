
# Project Setup Guide

## Prerequisites
- [Android Studio](https://developer.android.com/studio) installed
- Flutter installed and set up
- Java Development Kit (JDK) installed (Can be uninstalled later)
- Git installed

## Installation Steps

### 1. Clone the Repository
```bash
git clone [repository-url]
cd [repository-name]
```


### 2. Generate SHA-1 Debug Key
Google has security measures in place that wont allow an emulator to sign in with google unless their SHA key is registered

#### Windows
Open Command Prompt and run:
```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android
```

#### macOS/Linux
Open Terminal and run:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

#### Common Issues with SHA-1 Generation:
If you encounter the error: `keytool error: java.lang.Exception: Keystore file does not exist`
- Ensure Android Studio has been opened at least once
- Verify that you're using the correct path to your `.android` folder
- Make sure you've created a virtual device or run a flutter app at least once

### 3. Share Your SHA-1 Key
After generating your SHA-1 key, you'll see output similar to this:
```
Certificate fingerprints:
     SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

Copy the SHA1 value and share it with the project administrator(DiscordId : arminarlert9801)
## Troubleshooting
- If you can't find the `.android` folder:
  - Windows: It's typically located at `C:\Users\[YourUsername]\.android\`
  - macOS/Linux: It's typically located at `~/.android/`
- If `keytool` command is not recognized:
  - Ensure Java is properly installed and added to your system's PATH
  - Try using the full path to keytool in your Java installation directory

<br>
<br>
<br>
<br>
<br>

# Project Documentation

## Folder Structure
```
lib/
├── data/               # Static data and mock data for development
├── models/             # Data models and their serialization logic
├── providers/          # Riverpod providers for state management
│   └── stream_providers.dart  # Firebase stream providers
├── screens/           # UI screens and their widgets
│   ├── announcements/  # Announcements Full View that appears on clicking see all announcements
│   ├── dashboard/      # Dashboard screen and its components
│   ├── events/         # Events Screen/Calendar Screen and its components
│   ├── search/         # Search Screen
│   └── screens.dart    # Screen exports
├── services/          # External service integrations
├── utils/             # Utility functions and helpers
│   └── firedata.dart   # Firebase data operations
├── bottom_navbar.dart  # Custom bottom navigation bar
├── event_manager.dart  # Main app widget manager
└── main.dart          # App entry point
```

## State Management
- Using Riverpod for state management
- Stream providers for real-time Firebase data
- State providers for UI state (search, filters)

## Widget Flow
```
App Entry
└── EventManager (Root Widget)
    ├── DashboardScreen
    │   ├── ProfileHeader
    │   ├── AnnouncementsSlider
    │   ├── ClubsContainer
    │   └── EventCard
    ├── EventsScreen
    ├── SearchScreen
    │   ├── SearchBar
    │   ├── FilterChips
    │   └── SearchResults
    ├── ResourcesScreen
    └── ChatScreen
```

## Data Flow
```
Firebase Streams (firedata.dart)
   └── Stream Providers (stream_providers.dart)
       └── Consumer Widgets
```

## Best Practices
1. **State Management**
   - Use Riverpod providers for global state

2. **Code Organization**
   - Firebase operations in lib/utils/firedata.dart
   - Auth Service in lib/utils/services
   - Data fetching done through providers in providers/stream_providers.dart

3. **Firebase Integration**
   - All Firebase operations through firedata.dart
   - Use stream providers for real-time updates
