#!/bin/bash

# Delete All Packages Script
# Quickly removes all Docker packages from registry

echo "🗑️ Delete All Packages Script"
echo "============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Read token from .secrets
if [ -f ".secrets" ]; then
    TOKEN=$(grep "GITHUB_TOKEN=" .secrets | cut -d'=' -f2 | tr -d ' ')
    if [ -n "$TOKEN" ]; then
        echo -e "${GREEN}✅ Token found in .secrets${NC}"
    else
        echo -e "${RED}❌ No GITHUB_TOKEN found in .secrets${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ .secrets file not found${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}⚠️  WARNING: This will delete ALL Docker packages from your registry!${NC}"
echo -e "${YELLOW}⚠️  This action cannot be undone!${NC}"
echo ""
read -p "Type 'DELETE ALL' to confirm: " confirm

if [ "$confirm" != "DELETE ALL" ]; then
    echo -e "${RED}❌ Cancelled by user${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🔍 Listing current packages...${NC}"

# List all packages
packages_response=$(curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/user/packages?package_type=container")

if [ $? -eq 0 ] && [ -n "$packages_response" ]; then
    echo "$packages_response" | jq -r '.[] | "  📦 \(.name) - \(.visibility) - \(.created_at)"'
    
    total_packages=$(echo "$packages_response" | jq length)
    echo ""
    echo -e "${BLUE}📊 Total packages found: $total_packages${NC}"
else
    echo -e "${RED}❌ Failed to list packages${NC}"
    exit 1
fi

echo ""
echo -e "${RED}🗑️  Starting deletion...${NC}"

deleted_count=0
failed_count=0

# Delete each package
echo "$packages_response" | jq -r '.[].name' | while read package; do
    if [ -n "$package" ]; then
        echo -e "${BLUE}🗑️  Deleting package: $package${NC}"
        
        response=$(curl -X DELETE \
          -H "Authorization: token $TOKEN" \
          -H "Accept: application/vnd.github.v3+json" \
          "https://api.github.com/user/packages/container/$package")
        
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✅ Successfully deleted $package${NC}"
            deleted_count=$((deleted_count + 1))
        else
            echo -e "  ${RED}❌ Failed to delete $package: $response${NC}"
            failed_count=$((failed_count + 1))
        fi
        
        # Wait between deletions
        sleep 3
    fi
done

echo ""
echo -e "${BLUE}⏳ Waiting for deletions to complete...${NC}"
sleep 30

echo ""
echo -e "${BLUE}🔍 Verifying registry is empty...${NC}"

# Check if registry is empty
final_check=$(curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/user/packages?package_type=container")

remaining_packages=$(echo "$final_check" | jq length)

if [ "$remaining_packages" -eq 0 ]; then
    echo -e "${GREEN}✅ Registry is now empty!${NC}"
else
    echo -e "${YELLOW}⚠️  Registry still has $remaining_packages packages:${NC}"
    echo "$final_check" | jq -r '.[] | "  📦 \(.name)"'
fi

echo ""
echo -e "${GREEN}🎉 Cleanup completed!${NC}"
echo -e "${BLUE}📝 Next steps:${NC}"
echo "  1. Run 'Recreate Packages with Repository Link' workflow"
echo "  2. Create new packages with proper namespace"
echo "  3. Ensure all packages are public by default"
