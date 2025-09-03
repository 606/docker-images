#!/bin/bash

# Configuration validation script for docker images

echo "🔍 Validating docker images configuration..."
echo "=========================================="

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ jq is not installed. Please install it first:"
    echo "   brew install jq"
    exit 1
fi

# Check if config file exists
if [ ! -f ".github/configs/images.json" ]; then
    echo "❌ Configuration file not found: .github/configs/images.json"
    exit 1
fi

echo "✅ Configuration file found"

# Validate JSON syntax
if ! jq empty .github/configs/images.json 2>/dev/null; then
    echo "❌ Invalid JSON syntax in configuration file"
    exit 1
fi

echo "✅ JSON syntax is valid"

# Check for required fields
echo ""
echo "📋 Checking image configurations..."

errors=0

while IFS= read -r image_data; do
    name=$(echo "$image_data" | jq -r '.name')
    base_image=$(echo "$image_data" | jq -r '.base_image')
    registry=$(echo "$image_data" | jq -r '.registry')
    
    echo "  🔍 Checking image: $name"
    
    # Check name
    if [ "$name" = "null" ] || [ -z "$name" ]; then
        echo "    ❌ Invalid name: $name"
        ((errors++))
    else
        echo "    ✅ Name: $name"
    fi
    
    # Check base_image
    if [ "$base_image" = "null" ] || [ -z "$base_image" ]; then
        echo "    ❌ Invalid base_image: $base_image"
        ((errors++))
    else
        echo "    ✅ Base image: $base_image"
    fi
    
    # Check registry
    if [ "$registry" = "null" ] || [ -z "$registry" ]; then
        echo "    ❌ Invalid registry: $registry"
        ((errors++))
    else
        echo "    ✅ Registry: $registry"
    fi
    
    # Check channels
    channels=$(echo "$image_data" | jq -r '.channels | keys[]')
    if [ -z "$channels" ]; then
        echo "    ❌ No channels defined"
        ((errors++))
    else
        echo "    ✅ Channels: $channels"
        
        # Check each channel
        for channel in $channels; do
            tag=$(echo "$image_data" | jq -r ".channels.$channel.tag")
            dockerfile=$(echo "$image_data" | jq -r ".channels.$channel.dockerfile")
            
            if [ "$tag" = "null" ] || [ -z "$tag" ]; then
                echo "      ❌ Channel $channel: Invalid tag: $tag"
                ((errors++))
            else
                echo "      ✅ Channel $channel: Tag: $tag"
            fi
            
            if [ "$dockerfile" = "null" ] || [ -z "$dockerfile" ]; then
                echo "      ❌ Channel $channel: Invalid dockerfile: $dockerfile"
                ((errors++))
            else
                echo "      ✅ Channel $channel: Dockerfile: $dockerfile"
            fi
            
            # Check if dockerfile exists
            if [ ! -f "$dockerfile" ]; then
                echo "      ❌ Channel $channel: Dockerfile not found: $dockerfile"
                ((errors++))
            else
                echo "      ✅ Channel $channel: Dockerfile exists: $dockerfile"
            fi
        done
    fi
    
    echo ""
    
done < <(jq -c '.images[]' .github/configs/images.json)

# Final validation
echo "🎯 Validation Summary:"
if [ $errors -eq 0 ]; then
    echo "✅ Configuration is valid! No errors found."
    echo ""
    echo "📊 Configuration details:"
    echo "  Total images: $(jq '.images | length' .github/configs/images.json)"
    echo "  Total channels: $(jq '.images[].channels | keys | length' .github/configs/images.json | paste -sd+ | bc)"
    echo ""
    echo "🚀 Ready to run workflows!"
else
    echo "❌ Configuration has $errors error(s). Please fix them before running workflows."
    exit 1
fi
