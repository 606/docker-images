#!/bin/bash

# Direct Package Testing Script
# Tests packages directly without GitHub CLI

echo "🔓 Testing Packages Directly"
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test function for Docker images
test_docker_image() {
    local image=$1
    local tag=$2
    local full_image="ghcr.io/606/$image:$tag"
    
    echo -e "${BLUE}🧪 Testing Docker: $full_image${NC}"
    
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
        return 1
    fi
}

# Test function for GitHub API
test_github_api() {
    local token=$1
    
    echo -e "${BLUE}🔍 Testing GitHub API access...${NC}"
    
    # Test packages endpoint
    response=$(curl -s -H "Authorization: token $token" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/user/packages?package_type=container")
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo -e "  ${GREEN}✅ GitHub API packages endpoint accessible${NC}"
        
        # Parse packages
        package_count=$(echo "$response" | jq length 2>/dev/null || echo "0")
        echo -e "  ${BLUE}  📦 Found $package_count container packages${NC}"
        
        # Show package details
        echo "$response" | jq -r '.[] | "  📦 \(.name) - \(.visibility) - Repo: \(.repository.name // "none")"' 2>/dev/null || echo "  ⚠️ Could not parse package details"
        
    else
        echo -e "  ${RED}❌ GitHub API packages endpoint failed${NC}"
        echo -e "  ${YELLOW}  Response: $response${NC}"
    fi
}

# Main testing
echo ""
echo "📦 Testing Docker Images:"

# Test Ubuntu images
test_docker_image "ubuntu" "lts"
test_docker_image "ubuntu" "stable"
test_docker_image "ubuntu" "preview"

echo ""
echo "📦 Testing .NET SDK Images:"
test_docker_image "dotnet-sdk" "lts"
test_docker_image "dotnet-sdk" "stable"
test_docker_image "dotnet-sdk" "preview"

echo ""
echo "🔍 Testing GitHub API Access:"

# Read token from .secrets
if [ -f ".secrets" ]; then
    token=$(grep "GITHUB_TOKEN=" .secrets | cut -d'=' -f2 | tr -d ' ')
    if [ -n "$token" ]; then
        test_github_api "$token"
    else
        echo -e "  ${RED}❌ No GITHUB_TOKEN found in .secrets${NC}"
    fi
else
    echo -e "  ${RED}❌ .secrets file not found${NC}"
fi

echo ""
echo "🌐 Package URLs to Test:"
echo "  📦 Ubuntu LTS: https://ghcr.io/606/ubuntu:lts"
echo "  📦 Ubuntu Stable: https://ghcr.io/606/ubuntu:stable"
echo "  📦 Ubuntu Preview: https://ghcr.io/606/ubuntu:preview"
echo "  📦 .NET SDK LTS: https://ghcr.io/606/dotnet-sdk:lts"
echo "  📦 .NET SDK Stable: https://ghcr.io/606/dotnet-sdk:stable"
echo "  📦 .NET SDK Preview: https://ghcr.io/606/dotnet-sdk:preview"

echo ""
echo "🔓 Public Access Summary:"
echo "  ✅ Docker images should be pullable without auth"
echo "  ✅ GitHub API should show package details"
echo "  ✅ Repository linking should work properly"

echo ""
echo "📝 Next Steps:"
echo "  1. Run the Create Linked Packages workflow"
echo "  2. Check that packages appear in repository"
echo "  3. Verify repository links are working"
echo "  4. Test pulling from other machines"
