# Fine-Dine App — Setup Guide

## 1. Firebase Setup

### Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com
2. Create project named **restaurant_package_booking**
3. Enable **Authentication** → Email/Password
4. Enable **Cloud Firestore** → Start in test mode
5. Enable **Firebase Storage**

### Step 2: Add Android App
1. Package name: `com.example.fine_dine`
2. Download `google-services.json` → place in `/android/app/`

### Step 3: FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This generates `lib/firebase_options.dart` — update `main.dart`:
```dart
import 'firebase_options.dart';
// In main():
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

---

## 2. Database Design (Firestore Collections)

### Collection: `users`
| Field | Type | Notes |
|-------|------|-------|
| uid (doc ID) | String | PK, from Firebase Auth |
| email | String | Unique |
| name | String | |
| phone | String | |
| role | String | 'user' or 'admin' |
| profileImageUrl | String? | nullable |
| createdAt | Timestamp | |

### Collection: `packages`
| Field | Type | Notes |
|-------|------|-------|
| id (doc ID) | String | PK, auto |
| name | String | |
| description | String | |
| pricePerGuest | Number | RM per pax |
| imageUrls | Array<String> | |
| includes | Array<String> | package contents |
| category | String | Western/Asian/Fusion/Local/All |
| minGuests | Number | |
| maxGuests | Number | |
| isAvailable | Boolean | |
| orderCount | Number | auto-incremented |
| createdAt | Timestamp | |

### Collection: `reservations`
| Field | Type | Notes |
|-------|------|-------|
| id (doc ID) | String | PK, auto |
| userId | String | FK → users.uid |
| userName | String | denormalized |
| userEmail | String | denormalized |
| userPhone | String | denormalized |
| packageId | String | FK → packages.id |
| packageName | String | denormalized |
| packageImageUrl | String | denormalized |
| pricePerGuest | Number | snapshot |
| numGuests | Number | |
| eventDate | Timestamp | |
| eventTime | String | HH:MM format |
| additionalPreferences | String? | |
| customizations | Array<Map> | [{name, price}] |
| totalPrice | Number | computed |
| status | String | upcoming/completed/cancelled |
| rating | Number? | 1–5 |
| createdAt | Timestamp | |
| updatedAt | Timestamp? | |

---

## 3. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data; admins can read all
    match /users/{userId} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId || isAdmin());
      allow write: if request.auth != null && 
        (request.auth.uid == userId || isAdmin());
      allow create: if request.auth != null;
    }
    
    // Packages: anyone can read; only admins can write
    match /packages/{packageId} {
      allow read: if true;
      allow write: if request.auth != null && isAdmin();
    }
    
    // Reservations: users see their own; admins see all
    match /reservations/{resId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.userId == request.auth.uid || isAdmin());
    }
    
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid))
        .data.role == 'admin';
    }
  }
}
```

---

## 4. Create Admin Account
After first user registers, manually update in Firestore Console:
- Go to `users` collection → find your user → set `role: "admin"`

---

## 5. Packages Used (≥ 4 Third-Party)
| Package | Purpose |
|---------|---------|
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `firebase_storage` | Image storage |
| `go_router` | Navigation/Routing |
| `cached_network_image` | Efficient image loading |
| `shared_preferences` | Local caching |
| `flutter_secure_storage` | Secure token storage |
| `shimmer` | Loading skeleton UI |
| `intl` | Date/currency formatting |
| `image_picker` | Pick images for packages |
| `table_calendar` | Date picker |
| `flutter_rating_bar` | Star rating widget |

---

## 6. Key Features
- ✅ Guest browsing (no login required)
- ✅ User registration & login
- ✅ Admin vs User role separation
- ✅ Real-time pricing calculation (base × guests + customizations)
- ✅ Full booking flow: Browse → Form → Confirm → Success
- ✅ Booking management: View, Edit, Cancel
- ✅ Admin CRUD for packages
- ✅ Admin user management
- ✅ Search & filter by category
- ✅ Most Ordered feature
- ✅ Star rating on booking success
- ✅ Shimmer loading UI
- ✅ Status badges (upcoming/completed/cancelled)
