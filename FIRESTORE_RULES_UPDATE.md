# Firestore Security Rules Update Required

## Issue
The app is getting "Permission Denied" errors when trying to create transactions and update wallet balance because the `transactions` collection rule is missing.

```
W/Firestore: Write failed at transactions/xxx: Status{code=PERMISSION_DENIED, 
description=Missing or insufficient permissions., cause=null}
```

## Solution
Add the `transactions` collection rule to your Firestore security rules in the Firebase Console.

## Steps to Update Firestore Rules

1. **Go to Firebase Console**
   - Open https://console.firebase.google.com/
   - Select your project

2. **Navigate to Firestore Database**
   - Click on "Firestore Database" in the left sidebar
   - Click on the "Rules" tab

3. **Add the transactions rule**
   - Find the closing brace `}` just before the last `}`
   - Add this rule before the closing braces:

```javascript
// ADDED: Transactions collection for wallet functionality
match /transactions/{transactionId} {
  allow read: if request.auth != null && resource.data.userId == request.auth.uid;
  allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
  allow update: if false; // Transactions are immutable
  allow delete: if false; // Transactions cannot be deleted
}
```

4. **Or copy the entire updated rules from `firestore.rules` file in this project**

5. **Publish the Rules**
   - Click the "Publish" button
   - Wait for confirmation that rules are updated

## What This Rule Allows

✅ **Users can:**
- Read their own transactions
- Create new transactions for themselves (wallet credits/debits)

❌ **Users cannot:**
- See other users' transactions
- Update transactions (they're immutable once created)
- Delete transactions

## Verify Rules Work

After updating rules, restart your app and check:

1. Wallet balance updates when orders are delivered ✅
2. Transaction history shows new transactions ✅
3. No more permission denied errors in logs ✅
4. Console shows: `✅ Successfully credited wallet: ₹X for order ...`

