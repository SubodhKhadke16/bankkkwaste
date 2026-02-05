# Dark Theme Migration Guide 🌙

**Date:** 4 February 2026  
**Status:** In Progress

---

## 🎯 Objective
Ensure all screens in the Wastec Bank app properly support dark theme by replacing hardcoded colors with theme-aware colors.

---

## 📋 Strategy

### **Replace Hardcoded Colors with Theme Colors**

Instead of:
```dart
Container(
  color: Colors.white,
  // ...
)
```

Use:
```dart
Container(
  color: Theme.of(context).cardColor,
  // or
  color: Theme.of(context).scaffoldBackgroundColor,
  // or
  color: Theme.of(context).colorScheme.surface,
  // ...
)
```

---

## 🎨 Color Mapping Guide

| Hardcoded Color | Replace With |
|----------------|--------------|
| `Colors.white` (background) | `Theme.of(context).scaffoldBackgroundColor` |
| `Colors.white` (card) | `Theme.of(context).cardColor` |
| `Colors.white` (surface) | `Theme.of(context).colorScheme.surface` |
| `Colors.white` (text on dark) | `Theme.of(context).colorScheme.onPrimary` |
| `Colors.black` (text) | `Theme.of(context).textTheme.bodyLarge?.color` |
| `Colors.grey[50]` (background) | `Theme.of(context).scaffoldBackgroundColor` |
| `Colors.grey[100]` | `Theme.of(context).colorScheme.surface.withOpacity(0.5)` |
| `Colors.grey[300]` | `Theme.of(context).dividerColor` |
| `Colors.grey[600]` (text) | `Theme.of(context).textTheme.bodyMedium?.color` |
| `WastecColors.white` | `Theme.of(context).cardColor` |

---

## 📱 Screens to Update

### Priority 1 - Main Screens ✅
- [x] `track_order_unified.dart` - 13 instances
- [x] `home_clean.dart` - 7 instances  
- [x] `wastec_bank_screen.dart` - 13 instances
- [x] `eco_friendly_page.dart` - 16 instances
- [x] `cart_screen.dart` - 7 instances

### Priority 2 - Secondary Screens
- [ ] `profile_screen.dart` - 12 instances
- [ ] `scrap_submission_screen.dart` - 13 instances
- [ ] `wallet_screen.dart` - 3 instances
- [ ] `trending_rates_screen.dart` - 3 instances
- [ ] `sell_scrap_screen.dart` - 8 instances
- [ ] `track_order_eco_screen.dart` - 7 instances

### Priority 3 - Utility Screens  
- [ ] `scrap_categories_screen.dart` - 1 instance
- [ ] `select_location_screen.dart`
- [ ] `add_address_screen.dart`
- [ ] `settings_screen.dart`

---

## 🔧 Common Patterns

### Pattern 1: Container Background
```dart
// Before
Container(
  color: Colors.white,
  child: ...
)

// After  
Container(
  color: Theme.of(context).cardColor,
  child: ...
)
```

### Pattern 2: AppBar
```dart
// Before
AppBar(
  backgroundColor: WastecColors.white,
  foregroundColor: Colors.black,
)

// After
AppBar(
  backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
  foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
)

// Or simply (uses theme automatically)
AppBar(
  // backgroundColor will use theme
)
```

### Pattern 3: Text Color on Colored Background
```dart
// Before
Text(
  'Hello',
  style: TextStyle(color: Colors.white),
)

// After (when on primary color)
Text(
  'Hello',
  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
)
```

### Pattern 4: Card/Surface
```dart
// Before
Card(
  color: Colors.white,
  child: ...
)

// After
Card(
  // color will use theme automatically
  child: ...
)
```

### Pattern 5: Conditional Colors
```dart
// Before
color: isSelected ? WastecColors.primaryGreen : Colors.white

// After
color: isSelected 
    ? WastecColors.primaryGreen 
    : Theme.of(context).cardColor
```

---

## 🚀 Automated Fix Script

Run this command to automatically update theme-aware colors:

```bash
# Create a backup first
cp -r lib lib_backup

# TODO: Add sed/awk scripts for common replacements
```

---

## ✅ Testing Checklist

After updating each screen:

- [ ] Test in Light Mode - verify no visual regression
- [ ] Test in Dark Mode - verify proper colors
- [ ] Check text readability
- [ ] Check card/surface visibility
- [ ] Check button contrast
- [ ] Check icon visibility
- [ ] Test with device dark mode toggle
- [ ] Test theme switcher in settings

---

## 📊 Progress Tracker

**Total Screens:** ~19  
**Updated:** 5  
**Remaining:** 14  
**Progress:** 26%

---

## 🎯 Next Steps

1. ✅ Update Priority 1 screens (Main navigation)
2. ⏳ Update Priority 2 screens (Secondary features)
3. ⏳ Update Priority 3 screens (Utility pages)
4. ⏳ Test all screens in both themes
5. ⏳ Document any custom color requirements

---

**Last Updated:** February 4, 2026
