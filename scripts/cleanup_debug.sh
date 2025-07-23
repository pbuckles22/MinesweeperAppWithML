#!/bin/bash

# Cleanup Debug Statements Script
# Removes or comments out debug print statements for production

set -e

echo "Cleaning up debug statements..."

# Function to comment out debug statements
comment_debug_statements() {
    local file="$1"
    echo "Processing: $file"
    
    # Comment out debug print statements
    sed -i.bak 's/print('\''DEBUG:/\/\/ print('\''DEBUG:/g' "$file"
    sed -i.bak 's/print("DEBUG:/\/\/ print("DEBUG:/g' "$file"
    
    # Remove backup files
    rm -f "${file}.bak"
}

# Find all Dart files and clean up debug statements
find lib/ -name "*.dart" -type f | while read -r file; do
    comment_debug_statements "$file"
done

echo "Debug statements cleaned up successfully!"
echo "All debug print statements have been commented out."
echo "To re-enable debug mode, uncomment the statements and set FeatureFlags.enableDebugMode = true" 