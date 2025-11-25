# Wastec Bank - Waste Management & Scrap Recycling App

A modern Flutter application inspired by Swiggy's UI design, tailored for the waste management and scrap recycling industry. Wastec Bank empowers users to sell scrap, estimate prices, connect with nearby dealers, and earn eco-friendly rewards.

## Features

✅ **Swiggy-inspired UI Design**
- Clean, modern interface with rounded cards and soft shadows
- Eco-friendly green color palette (#00A86B)
- Smooth animations and intuitive navigation

✅ **Core Screens**
- **Home Screen**: Location selector, search bar, hero banner, 2x2 feature grid, bottom navigation
- **Scrap Pickup**: Book doorstep pickup service
- **Price Estimator**: Check today's scrap rates
- **Nearby Dealers**: Locate scrap collectors in your area
- **Rewards**: Earn and track eco points

✅ **Modern Architecture**
- Material 3 design system
- Reusable widget components (FeatureCard, etc.)
- Centralized theme configuration
- Clean code structure

## Project Structure

```
wastec_bank_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   └── theme.dart              # Color scheme & theme configuration
│   ├── screens/
│   │   └── home.dart               # Main home screen (Swiggy-style)
│   ├── widgets/
│   │   └── feature_card.dart       # Reusable feature card component
│   └── utils/                       # Utility functions (add as needed)
├── test/                            # Unit tests
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or later)
- Dart SDK
- Git

### Installation

1. Clone the repository or navigate to the project:
   ```bash
   cd "C:\Wastec Bank\wastec_bank_app"
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Color Palette

| Color | Hex Code | Usage |
|-------|----------|-------|
| Primary Green | `#00A86B` | Buttons, icons, accents |
| Light Green | `#E8F5E9` | Card backgrounds, gradients |
| Dark Green | `#00663D` | Text, dark elements |
| White | `#FFFFFF` | Backgrounds |
| Light Gray | `#F5F5F5` | Input fields, borders |
| Medium Gray | `#BDBDBD` | Secondary text |

## UI Components

### FeatureCard Widget
A reusable card component used in the 2x2 grid with:
- Icon display in white circle
- Title and subtitle
- "Book Now" CTA button
- Gradient background
- Soft shadow effect

### HomeScreen
The main landing screen featuring:
- AppBar with logo and profile icon
- Location selector dropdown
- Search bar with microphone icon
- Hero banner ("Be Eco Friendly with Wastec Bank")
- 2x2 feature grid (Scrap Pickup, Price Estimator, Dealers, Rewards)
- Bottom navigation with 4 tabs

## Customization

### Changing Colors
Edit `lib/config/theme.dart`:
```dart
static const Color primaryGreen = Color(0xFF00A86B); // Change hex code
```

### Adding New Screens
1. Create a new file in `lib/screens/`
2. Import it in `main.dart`
3. Update navigation in `HomeScreen._buildBottomNavBar()`

### Adding Assets
1. Create `assets/` folder at project root
2. Add images/icons
3. Uncomment `assets:` section in `pubspec.yaml`

## Dependencies

- `flutter`: Core Flutter framework
- `cupertino_icons`: iOS-style icons
- `provider`: State management
- `http`: API requests
- `google_maps_flutter`: Map integration
- `firebase_core`, `firebase_auth`, `firebase_messaging`: Firebase services
- `razorpay_flutter`: Payment integration
- `google_fonts`: Custom fonts
- `cached_network_image`: Image caching

## Roadmap

- [ ] Implement backend API integration
- [ ] Add Firebase authentication
- [ ] Integrate Razorpay payments
- [ ] Add Google Maps for dealer location
- [ ] Implement real-time chat
- [ ] Add push notifications (FCM)
- [ ] Build seller/dealer dashboards
- [ ] Create admin panel

## Code Style

This project follows Flutter best practices:
- Use `const` for constructors
- Prefer named parameters
- Document public methods
- Use meaningful variable names
- Keep widgets focused on single responsibility

## Testing

Run unit tests:
```bash
flutter test
```

## Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## License

This project is proprietary. All rights reserved.

## Contact

For inquiries or support, contact the Wastec Bank development team.

---

**Built with ❤️ and Flutter** 🚀
