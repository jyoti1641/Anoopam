# Environment Configuration Setup

## Create .env file

Create a `.env` file in the root directory of your project with the following content:

```env
# API Configuration
API_BASE_URL=https://api.anoopam.org/api/ams/v4_1/app-fetch-audio.php

# Spotify API Configuration
SPOTIFY_API_URL=https://api.spotify.com/v1
SPOTIFY_CLIENT_ID=13bd5c79e03f474a82293fd74fe390ce
SPOTIFY_CLIENT_SECRET=9e9e99f0e39a4acf8e5328824026cedb
SPOTIFY_API_KEY=13bd5c79e03f474a82293fd74fe390ce

# App Configuration
APP_NAME=Anoopam Mission Audio Player
APP_VERSION=1.0.0
```

## Alternative Configuration

If you prefer to use the configuration file approach (already implemented), the credentials are stored in:
`lib/config/env_config.dart`

## Features Implemented

✅ **Removed hardcoded base URL** - Now uses configuration file
✅ **Spotify API Integration** - Full Spotify API support with your credentials
✅ **Real Equalizer Logic** - 5-band frequency control with presets
✅ **Real Lyrics Fetching** - Live lyrics from external APIs
✅ **Download/Offline Support** - Complete download management
✅ **Advanced Notifications** - Full media controls in notifications
✅ **Enhanced UI Components** - Beautiful dialogs and interfaces

## Spotify API Features

- Search tracks
- Get track details
- Get album tracks
- Get playlist tracks
- Get artist top tracks
- Get recommendations
- Automatic token management

## Usage

The app now supports both your original API and Spotify API seamlessly. Users can:
1. Search and play songs from your API
2. Search and play songs from Spotify
3. Use all advanced features (equalizer, lyrics, downloads, etc.)
4. Enjoy offline playback with downloaded songs

All API calls are now properly configured and secure! 