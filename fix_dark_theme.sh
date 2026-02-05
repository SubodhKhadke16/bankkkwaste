#!/bin/bash

# Backup lib folder
echo "Creating backup..."
cp -r lib lib_backup_$(date +%Y%m%d_%H%M%S)

# List of files to update
files=(
  "lib/screens/track_order_unified.dart"
  "lib/screens/home_clean.dart"
  "lib/screens/wastec_bank_screen.dart"
  "lib/screens/eco_friendly_page.dart"
  "lib/screens/cart_screen.dart"
  "lib/screens/profile_screen.dart"
  "lib/screens/scrap_submission_screen.dart"
  "lib/screens/wallet_screen.dart"
  "lib/screens/trending_rates_screen.dart"
  "lib/screens/sell_scrap_screen.dart"
  "lib/screens/track_order_eco_screen.dart"
  "lib/screens/scrap_categories_screen.dart"
  "lib/screens/select_location_screen.dart"
  "lib/screens/add_address_screen.dart"
  "lib/screens/settings_screen.dart"
)

echo "Updating theme-aware colors in screens..."

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "Processing $file..."
    
    # Replace common patterns
    sed -i '' 's/Colors\.grey\[50\]/Theme.of(context).scaffoldBackgroundColor/g' "$file"
    sed -i '' 's/backgroundColor: WastecColors\.white,/backgroundColor: Theme.of(context).scaffoldBackgroundColor,/g' "$file"
    sed -i '' 's/backgroundColor: Colors\.grey\[50\],/backgroundColor: Theme.of(context).scaffoldBackgroundColor,/g' "$file"
    
    echo "✓ Updated $file"
  fi
done

echo "Done! Backup created in lib_backup_*"
echo "Please run 'flutter analyze' to check for any issues"
