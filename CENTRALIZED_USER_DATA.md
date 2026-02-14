# Centralized User Data System

## Overview

All user data is **centralized in the `users` collection** in Firestore. Every user has a single document that contains all their information and gets updated automatically when changes occur.

## User Document Structure

```javascript
users/{userId}/
{
  // Profile Information
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "profileImage": "https://...",
  
  // Wallet & Points
  "walletBalance": 420.00,      // Updated automatically on transactions
  "ecoPoints": 150,             // Updated automatically on eco actions
  
  // Metadata
  "createdAt": Timestamp,
  "updatedAt": Timestamp,       // Updated on every change
  
  // Subcollections
  addresses/                     // User's saved addresses
    {addressId}/
      - type: "home" | "work"
      - address: {...}
      - createdAt: Timestamp
}
```

## Automatic Updates

### 1. **Wallet Balance** ✅
**When:** Transaction created (order completed, money added, withdrawal)
**Where:** `TransactionService.createTransaction()`
**Updates:** `users/{userId}/walletBalance` and `updatedAt`

```dart
// Automatically updates wallet
await TransactionService.creditWalletFromOrder(
  userId: userId,
  amount: 60.00,
  orderId: orderId,
);
// ✅ users/{userId}/walletBalance += 60
// ✅ users/{userId}/updatedAt = now
```

### 2. **Eco Points** ✅
**When:** Eco-friendly actions, purchases, recycling
**Where:** `UserService.updateEcoPoints()`
**Updates:** `users/{userId}/ecoPoints` and `updatedAt`

```dart
// Automatically updates eco points
await UserService.updateEcoPoints(userId, 10, isAdd: true);
// ✅ users/{userId}/ecoPoints += 10
// ✅ users/{userId}/updatedAt = now
```

### 3. **Profile Information** ✅
**When:** User edits profile (name, phone, photo)
**Where:** `AuthService.updateUser()`
**Updates:** `users/{userId}/name`, `phone`, `updatedAt`

```dart
// User edits their profile
await authService.updateUser(updatedUser);
// ✅ users/{userId}/name = "New Name"
// ✅ users/{userId}/phone = "New Phone"
// ✅ users/{userId}/updatedAt = now
```

### 4. **Addresses** ✅
**When:** User adds/updates delivery address
**Where:** `UserService.saveAddress()`
**Updates:** `users/{userId}/addresses/{addressId}`

```dart
// User adds new address
await UserService.saveAddress(
  userId: userId,
  addressType: 'home',
  address: {...},
);
// ✅ users/{userId}/addresses/{newId} created
```

## Data Flow Examples

### Example 1: User Completes Waste Bank Order

```
1. Order created → waste_bank_orders/{orderId}
2. Order status changed to "delivered" (backend)
3. WalletSyncService detects completed order
4. Transaction created → transactions/{txnId}
   - userId: linked to user
   - amount: 60
   - orderId: linked to order
5. ✅ users/{userId}/walletBalance += 60
6. ✅ users/{userId}/updatedAt = now
```

### Example 2: User Edits Profile

```
1. User taps Edit Profile
2. Changes name: "John" → "John Doe"
3. Changes phone: "123" → "+1234567890"
4. Taps Save
5. ✅ users/{userId}/name = "John Doe"
6. ✅ users/{userId}/phone = "+1234567890"
7. ✅ users/{userId}/updatedAt = now
8. UI updates automatically (StreamBuilder)
```

### Example 3: User Adds Address

```
1. User taps Add Address
2. Selects location on map
3. Enters address details
4. Taps Save
5. ✅ users/{userId}/addresses/{addressId} created
6. Address list updates automatically
```

## Real-Time Updates

All user data screens use **StreamBuilder** to listen for changes:

```dart
StreamBuilder(
  stream: UserService.getUserStream(userId),
  builder: (context, snapshot) {
    final userData = snapshot.data?.data();
    final walletBalance = userData?['walletBalance'] ?? 0.0;
    final name = userData?['name'] ?? '';
    // ... UI updates automatically when data changes
  },
)
```

## Benefits of Centralized Data

✅ **Single Source of Truth** - All user data in one place
✅ **Automatic Sync** - Changes propagate instantly
✅ **Easy Queries** - Get all user info with one document read
✅ **Better Performance** - Fewer database reads
✅ **Data Consistency** - No data duplication or conflicts
✅ **Easy Debugging** - Check one document for user state

## Multi-User Isolation

Each user's data is **completely isolated**:

```
User A (userId: abc123)
  └─ users/abc123/
      ├─ walletBalance: 420
      ├─ ecoPoints: 150
      └─ addresses/...

User B (userId: xyz789)
  └─ users/xyz789/
      ├─ walletBalance: 680
      ├─ ecoPoints: 200
      └─ addresses/...
```

- User A cannot see User B's wallet balance
- User B cannot modify User A's profile
- Transactions are filtered by userId
- Orders are filtered by userId

## Firestore Security Rules

Ensures data isolation:

```javascript
match /users/{userId} {
  // Users can only read/write their own data
  allow read, write: if request.auth.uid == userId;
  
  match /addresses/{addressId} {
    allow read, write: if request.auth.uid == userId;
  }
}

match /transactions/{txnId} {
  // Users can only see their own transactions
  allow read: if resource.data.userId == request.auth.uid;
  allow create: if request.resource.data.userId == request.auth.uid;
}
```

## Developer Tools

### View User Data
1. Firebase Console → Firestore Database → users/{userId}
2. See all fields in real-time

### Debug Wallet Issues
1. App → Wallet Tab → Debug Transactions
2. See all transactions with Firebase IDs
3. Reset wallet balance if needed

### Monitor Updates
Check console logs:
```
📝 Updating user profile for: abc123
✅ User profile updated successfully in Firestore
💰 Updating wallet for user: abc123
✅ Wallet updated successfully. New balance: ₹420
```

## Summary

✅ **All user data centralized** in `users/{userId}`
✅ **Automatic updates** for wallet, eco points, profile
✅ **Real-time sync** across all screens
✅ **Multi-user isolation** with security rules
✅ **Easy debugging** with comprehensive logging
✅ **Scalable architecture** for future features
