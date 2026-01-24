# Firestore Database Structure

This document outlines the Firestore database structure for the Wastec Bank app.

## Collections

### 1. **users**
Stores user profile information and wallet data.

```
users/{userId}
├── name: string
├── email: string
├── phone: string
├── profileImage: string (URL)
├── walletBalance: number
├── ecoPoints: number
├── createdAt: timestamp
└── updatedAt: timestamp

Subcollections:
└── addresses/{addressId}
    ├── type: string (home, work, other)
    ├── address: map
    │   ├── street: string
    │   ├── city: string
    │   ├── state: string
    │   ├── pincode: string
    │   └── landmark: string
    └── createdAt: timestamp
```

**Indexes Required:**
- None (simple queries only)

---

### 2. **products**
Stores all eco-friendly products available in the store.

```
products/{productId}
├── name: string
├── description: string
├── price: number
├── imageURL: string
├── category: string (Organic, Compost, Recyclable, etc.)
├── stock: number
└── created-at: timestamp
```

**Indexes Required:**
- Single field: `category` (Ascending)
- Composite: `category` (Ascending) + `price` (Ascending)

---

### 3. **orders**
Stores customer orders with cart items.

```
orders/{orderId}
├── userId: string
├── userName: string
├── phoneNumber: string
├── deliveryAddress: string
├── items: array of maps
│   └── [
│       ├── productId: string
│       ├── productName: string
│       ├── productPrice: number
│       ├── productImageUrl: string
│       ├── productDescription: string
│       ├── productCategory: string
│       ├── productStock: number
│       └── quantity: number
│      ]
├── totalAmount: number
├── status: string (pending, confirmed, processing, delivered, cancelled)
├── createdAt: timestamp
└── updatedAt: timestamp
```

**Indexes Required:**
- Composite: `userId` (Ascending) + `createdAt` (Descending)
- Composite: `userId` (Ascending) + `status` (Ascending) + `createdAt` (Descending)

---

### 4. **carts**
Stores user cart data (synced from local storage).

```
carts/{userId}
├── items: array of maps
│   └── [
│       ├── productId: string
│       ├── productName: string
│       ├── productPrice: number
│       ├── productImageUrl: string
│       ├── productDescription: string
│       ├── productCategory: string
│       ├── productStock: number
│       └── quantity: number
│      ]
└── updatedAt: timestamp
```

**Indexes Required:**
- None (document-level queries only)

---

## Security Rules

Add these security rules to your Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User addresses
      match /addresses/{addressId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Products collection (read-only for all authenticated users)
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null && 
                      (resource.data.userId == request.auth.uid || 
                       request.auth.token.admin == true);
    }
    
    // Carts collection
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## API Usage Examples

### Create a User
```dart
await UserService.createUser(
  userId: 'user123',
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+919876543210',
);
```

### Fetch Products
```dart
final products = await ProductService.fetchProducts();
```

### Create an Order
```dart
final order = Order(
  id: '',
  userId: 'user123',
  items: cartItems,
  totalAmount: 500.0,
  status: 'pending',
  createdAt: DateTime.now(),
  userName: 'John Doe',
  phoneNumber: '+919876543210',
  deliveryAddress: '123 Main St, City',
);

final orderId = await OrderService.createOrder(order);
```

### Get User Orders
```dart
final orders = await OrderService.getUserOrders('user123');
```

### Update Order Status
```dart
await OrderService.updateOrderStatus('orderId123', 'delivered');
```

### Stream User Data (Real-time)
```dart
UserService.getUserStream('user123').listen((snapshot) {
  final userData = snapshot.data();
  print('Wallet Balance: ${userData?['walletBalance']}');
});
```

---

## Initial Setup

1. **Initialize Firebase** in your project (already done)

2. **Add sample products** to Firestore:
```dart
await ProductService.initializeProducts();
```

3. **Create Firestore indexes** in Firebase Console:
   - Go to Firestore → Indexes
   - Add the composite indexes mentioned above

4. **Set up Security Rules**:
   - Copy the rules from above
   - Go to Firestore → Rules
   - Paste and publish

---

## Features Implemented

✅ User profile management with Firestore
✅ Product catalog stored in Firestore
✅ Cart syncing with Firestore (for logged-in users)
✅ Order creation and tracking
✅ Real-time updates for user data
✅ Order history and statistics
✅ Wallet and eco-points management

---

## Next Steps

1. Implement Firebase Authentication for user login
2. Add image upload to Firebase Storage
3. Implement push notifications for order updates
4. Add admin panel for product management
5. Implement payment gateway integration
