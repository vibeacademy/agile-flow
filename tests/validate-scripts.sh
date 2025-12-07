#!/bin/bash

# Validate shell scripts
# Runs shellcheck and syntax validation

set -e

ERRORS=0

echo "Validating shell scripts..."
echo ""

# Find all .sh files
for file in $(find . -name "*.sh" -type f ! -path "./.git/*" ! -path "./node_modules/*"); do
    filename=$(basename "$file")
    file_errors=0

    # Check bash syntax
    if ! bash -n "$file" 2>/dev/null; then
        echo "FAIL: $filename - Bash syntax error"
        file_errors=$((file_errors + 1))
    fi

    # Run shellcheck if available
    if command -v shellcheck &> /dev/null; then
        # SC1091: Don't follow sourced files (they may not exist in CI)
        # SC2034: Allow unused variables (may be used by sourcing scripts)
        if ! shellcheck -e SC1091 -e SC2034 "$file" 2>/dev/null; then
            echo "FAIL: $filename - Shellcheck issues found"
            shellcheck -e SC1091 -e SC2034 "$file" 2>&1 | head -20
            file_errors=$((file_errors + 1))
        fi
    fi

    # Check for executable permission (warn only)
    if [ ! -x "$file" ]; then
        echo "WARN: $filename - Not executable (consider chmod +x)"
    fi

    if [ $file_errors -eq 0 ]; then
        echo "PASS: $filename"
    else
        ERRORS=$((ERRORS + file_errors))
    fi
done

echo ""
if [ $ERRORS -gt 0 ]; then
    echo "FAILED: $ERRORS script(s) have issues"
    exit 1
else
    echo "SUCCESS: All shell scripts valid"
    exit 0
fi
