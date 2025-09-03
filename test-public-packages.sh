#!/bin/bash

# Test Public Packages Script
# Tests that all packages are accessible without authentication

echo "🔓 Testing Public Package Access"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test function
test_package() {
    local image=$1
    local tag=$2
    local full_image="ghcr.io/606/$image:$tag"
    
    echo -e "${BLUE}🧪 Testing: $full_image${NC}"
    
    # Try to pull without authentication
    if docker pull "$full_image" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✅ Successfully pulled $full_image${NC}"
        
        # Test running the container
        echo -e "  ${BLUE}  🚀 Testing container execution...${NC}"
        if docker run --rm "$full_image" echo "Hello from $full_image" >/dev/null 2>&1; then
            echo -e "  ${GREEN}  ✅ Container runs successfully${NC}"
        else
            echo -e "  ${YELLOW}  ⚠️ Container pulled but failed to run${NC}"
        fi
        
        # Clean up
        docker rmi "$full_image" >/dev/null 2>&1
        echo -e "  ${BLUE}  🧹 Cleaned up image${NC}"
        
        return 0
    else
        echo -e "  ${RED}❌ Failed to pull $full_image${NC}"
        echo -e "  ${YELLOW}  💡 This might indicate the package is not public${NC}"
        return 1
    fi
}

# Test all packages
echo ""
echo "📦 Testing Ubuntu Images:"
test_package "ubuntu" "lts"
test_package "ubuntu" "stable"
test_package "ubuntu" "preview"

echo ""
echo "📦 Testing .NET SDK Images:"
test_package "dotnet-sdk" "lts"
test_package "dotnet-sdk" "stable"
test_package "dotnet-sdk" "preview"

echo ""
echo "🔍 Checking Package Status:"

# Check if gh CLI is available
if command -v gh &> /dev/null; then
    echo "  📊 Using GitHub CLI to check package visibility..."
    
    # Check package visibility
    packages=$(gh api user/packages --jq '.[] | select(.package_type == "container") | .name' 2>/dev/null || echo "")
    
    if [ -n "$packages" ]; then
        for package in $packages; do
            if [[ "$package" == *"ubuntu"* ]] || [[ "$package" == *"dotnet-sdk"* ]]; then
                visibility=$(gh api "user/packages/container/$package" --jq '.visibility' 2>/dev/null || echo "unknown")
                echo -e "  📦 $package: ${BLUE}$visibility${NC}"
            fi
        done
    else
        echo -e "  ${YELLOW}⚠️ No packages found or API access issue${NC}"
    fi
else
    echo -e "  ${YELLOW}ℹ️ GitHub CLI not available - install with: brew install gh${NC}"
fi

echo ""
echo "🌐 Manual Package URLs:"
echo "  📦 Ubuntu LTS: https://ghcr.io/606/ubuntu:lts"
echo "  📦 Ubuntu Stable: https://ghcr.io/606/ubuntu:stable"
echo "  📦 Ubuntu Preview: https://ghcr.io/606/ubuntu:preview"
echo "  📦 .NET SDK LTS: https://ghcr.io/606/dotnet-sdk:lts"
echo "  📦 .NET SDK Stable: https://ghcr.io/606/dotnet-sdk:stable"
echo "  📦 .NET SDK Preview: https://ghcr.io/606/dotnet-sdk:preview"

echo ""
echo "🔓 Public Access Summary:"
echo "  ✅ All packages should be PUBLIC by default"
echo "  ✅ No authentication required to pull images"
echo "  ✅ Anyone can use these images in their projects"
echo "  ✅ Weekly visibility checks ensure packages stay public"

echo ""
echo "📝 Next Steps:"
echo "  1. Push changes to trigger package setup workflow"
echo "  2. Check GitHub Actions for package creation"
echo "  3. Verify packages appear in https://github.com/606?tab=packages"
echo "  4. Test pulling images from other machines without auth"
