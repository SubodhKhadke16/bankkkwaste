# Firestore Indexes Setup

## What are Firestore Indexes?

Firestore requires composite indexes when you query with:
- Multiple `where` clauses on different fields
- A `where` clause + `orderBy` on a different field

Your app uses these queries, so you'll need to create indexes.

## Two Ways to Create Indexes

### Option 1: Let Firebase Auto-Create (EASIEST) ✅

**Just run your app normally** - When Firestore encounters a query that needs an index, it will:

1. Show an error in the console with a clickable link
2. Click the link to auto-create the index
3. Wait 1-2 minutes for the index to build
4. Restart your app

**Example error you might see:**
```
The query requires an index. You can create it here: https://console.firebase.google.com/...
```

**This is the recommended approach** - just use the app and create indexes as needed.

---

### Option 2: Deploy All Indexes at Once (ADVANCED)

If you want to set up all indexes beforehand:

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firestore** (from your project root):
   ```bash
   firebase init firestore
   ```
   - Select your Firebase project
   - Keep default file names (firestore.rules and firestore.indexes.json)

4. **Deploy the indexes**:
   ```bash
   firebase deploy --only firestore:indexes
   ```

5. **Wait for indexes to build** (2-5 minutes)

---

## Required Indexes

The `firestore.indexes.json` file includes indexes for:

### 1. **Transactions** (wallet history)
   - `userId` + `createdAt` (for all transactions list)
   - `userId` + `type` + `createdAt` (for credits/debits filter)
   - `userId` + `category` + `createdAt` (for category filter)

### 2. **Waste Bank Orders**
   - `userId` + `createdAt` (for order history sorted by date)

### 3. **Eco-Friendly Orders**
   - `userId` + `createdAt` (for order history sorted by date)

---

## Checking Index Status

1. Go to Firebase Console
2. Click **Firestore Database** → **Indexes** tab
3. See all indexes and their build status:
   - 🟢 **Building** - Index is being created (wait 1-5 min)
   - ✅ **Enabled** - Index is ready to use
   - 🔴 **Error** - Something went wrong

---

## When You Need to Create More Indexes

If you see this error in your app:
```
The query requires an index
```

**Simply click the link** in the error message - it will take you directly to Firebase Console with the index pre-configured. Just click "Create Index" and wait for it to build.

---

## Summary

✅ **Recommended**: Just run your app and create indexes when Firebase shows the link
❌ **Not Required**: Manual deployment (unless you want all indexes upfront)

The app will work fine once indexes are created!
