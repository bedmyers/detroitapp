# Off Woodward

**An iOS app for discovering what's happening in Detroit — browse a week of local events by day, neighborhood, and category, or point your camera at a venue to see what's on there.**

Detroit's events are scattered across venue sites, social media, and ticketing platforms. Off Woodward pulls them into one place with a fast, swipe-driven interface built for deciding what to do *tonight*.

## Screenshots

<!-- TODO: add screenshots -->
| Browse | Event Detail | Nearby | Venue Recognition |
|--------|--------------|--------|-------------------|
| _coming soon_ | _coming soon_ | _coming soon_ | _coming soon_ |

## Tech Stack

- **UI:** SwiftUI (iOS 16+, AR features iOS 17+)
- **State & data flow:** MVVM with `ObservableObject` view models, Combine
- **Backend:** Firebase Realtime Database (event data)
- **Location:** CoreLocation
- **AR / ML:** ARKit + Vision + a custom Core ML image classifier trained on Detroit venues
- **System integrations:** EventKit (calendar), UserNotifications (reminders), UIKit share sheet
- **Dependencies:** Swift Package Manager (Firebase iOS SDK)

## Features

- **7-day event browser** — events grouped by day; tap a day chip or swipe horizontally to move between days
- **Filtering & sorting** — filter by category (Music, Shows, Sports, Food, Art, Museum, …) and by neighborhood (Downtown, Midtown, Corktown, Eastern Market, and more); sort by price, start time, or rating
- **Event detail view** — remote image loading, time/location/price/description sections, one-tap Apple Maps directions, swipe left/right to page through events
- **Nearby events** — determines your location, snaps it to the nearest of eight Detroit neighborhoods, and shows what's happening near you today
- **AR venue recognition (iOS 17+)** — live ARKit camera feed run through a custom-trained Core ML classifier; when a Detroit venue is recognized with high confidence, jump straight to that venue's events for the week
- **Calendar & reminders** — add an event to your calendar via EventKit, or schedule a local notification 1 or 24 hours before it starts
- **Sharing & deep links** — share an event with a custom `offwoodward://event/<id>` URL; opening the link deep-links straight to that event in the app

## Architecture

```
DetroitAppApp (entry point, Firebase init, deep link routing)
│
├── Models/
│   ├── Event            — Decodable event model + date/time formatting helpers
│   ├── EventViewModel   — fetches events from Firebase RTDB, decodes and groups
│   │                      them by day, derives the user's neighborhood
│   ├── LocationManager  — CLLocationManager singleton publishing the user's location
│   └── DeepLinkManager  — parses offwoodward:// URLs into an event ID
│
├── Views/
│   ├── ContentView              — main browser: day selector, category chips,
│   │                              neighborhood menu, sorted event list
│   ├── EventView                — pageable detail view (share, calendar, reminders)
│   ├── NearbyEventsView         — today's events in the user's neighborhood
│   ├── BuildingRecognitionView  — ARKit camera + Vision/Core ML venue classifier
│   └── VenueEventsView          — this week's events at a recognized venue
│
└── UI/ — shared colors and category icon mappings
```

**How the pieces fit together:** `EventViewModel` fetches the event set from Firebase Realtime Database, decodes it into `Event` values, and publishes a dictionary keyed by date. Views filter and sort that published data locally (by day, category, neighborhood, price, time, or rating), so switching filters is instant with no network round trips. `LocationManager` publishes the device location via Combine; the view model maps it to the closest known neighborhood center to power the "nearby events" experience. The AR flow runs each camera frame through a Vision request backed by the custom Core ML model and only surfaces a venue once classification confidence exceeds 80%.

## Getting Started

### Prerequisites

- Xcode 15+ / iOS 16+ simulator or device (iOS 17+ device for the AR venue-recognition feature)
- A Firebase project with Realtime Database enabled

### Setup

1. Clone the repo and open `DetroitApp.xcodeproj` in Xcode. Swift Package Manager resolves the Firebase dependencies automatically.
2. Download `GoogleService-Info.plist` from your Firebase console and add it to the `DetroitApp` target. (It is intentionally not committed.)
3. Populate your Realtime Database with event records matching the `Event` model (`name`, `date` in `M/dd/yy` format, `location`, `address`, `neighborhood`, `category`, `rating`, plus optional fields like `timeStart`, `price`, `image`, and `website`).
4. Build and run. Location, notification, calendar, and camera permissions are requested at runtime as the corresponding features are used.

> **Note:** the AR venue-recognition feature uses the bundled `DetroitVens` Core ML model, a custom image classifier trained on photos of Detroit venues.

## Testing the Deep Links

With the app installed, open Safari on the simulator/device and navigate to a URL like:

```
offwoodward://event/<event-id>
```

Event IDs take the form `event-name-date-location`, lowercased and hyphenated.
