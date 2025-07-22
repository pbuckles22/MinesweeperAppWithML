#!/bin/bash

# This script removes all individually added Python stdlib files from Copy Bundle Resources in the Xcode project.
# It leaves only the blue folder reference for python-stdlib.
# Usage: ./remove_python_bundle_duplicates.sh

PBXPROJ="Runner.xcodeproj/project.pbxproj"
BACKUP="$PBXPROJ.bak.$(date +%s)"

# Backup the project file
cp "$PBXPROJ" "$BACKUP"
echo "Backup of project.pbxproj saved as $BACKUP"

echo "Scanning for Python stdlib file references in Copy Bundle Resources..."

# Find all lines referencing .py files in Copy Bundle Resources
PY_LINES=$(grep -n -E '\.py[",]' "$PBXPROJ" | cut -d: -f1)

if [ -z "$PY_LINES" ]; then
  echo "No individual Python .py files found in Copy Bundle Resources."
else
  echo "Removing the following lines (Python .py files):"
  for line in $PY_LINES; do
    sed -i '' "${line}d" "$PBXPROJ"
    echo "  Removed line $line"
  done
fi

echo "\nDone!"
echo "You should now have only the blue python-stdlib folder reference in Copy Bundle Resources."
echo "If you need to re-add it:"
echo "  - In Xcode, right-click your project > Add Files to 'Runner' > select the python-stdlib folder as a blue folder reference."
echo "  - Clean and rebuild the project." 