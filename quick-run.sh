#!/bin/bash

# Quick Run Script for GitHub Actions Workflows
# Runs specific workflows locally using act

echo "🚀 Quick Run Script for GitHub Actions"
echo "======================================"

# Check prerequisites
if ! command -v act &> /dev/null; then
    echo "❌ act not installed. Run: brew install act"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker not running"
    exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Menu for workflow selection
echo "📋 Available Workflows:"
echo "1) 🧪 Test Packages (test-packages.yml)"
echo "2) 🔄 Recreate Packages with Repository Link (recreate-packages.yml)"
echo "3) 📦 Create Linked Packages (create-linked-packages.yml)"
echo "4) 🔍 Image Update Checker (image-update-checker.yml)"
echo "5) 🏗️ Build Images (build-images.yml)"
echo "6) 🔧 .NET SDK Update (dotnet-sdk-update.yml)"
echo "7) 📅 Scheduled Update (scheduled-update.yml)"
echo "8) 🔗 Webhook Update (webhook-update.yml)"
echo "9) 🔓 Package Visibility Management (package-visibility.yml)"
echo "10) 🗑️ Clean Registry - Delete ALL Docker Images (clean-registry.yml)"
echo "11) 🔧 Fix Package Visibility (fix-visibility.yml)"
echo "0) 🚪 Exit"

echo ""
read -p "Select workflow (0-11): " choice

case $choice in
    1)
        echo "🧪 Running Test Packages workflow..."
        act workflow_dispatch -W .github/workflows/test-packages.yml --container-architecture linux/amd64 --reuse
        ;;
    2)
        echo "🔄 Running Recreate Packages workflow..."
        act workflow_dispatch -W .github/workflows/recreate-packages.yml --container-architecture linux/amd64 --reuse
        ;;
    3)
        echo "📦 Running Create Linked Packages workflow..."
        act workflow_dispatch -W .github/workflows/create-linked-packages.yml --container-architecture linux/amd64 --reuse
        ;;
    4)
        echo "🔍 Running Image Update Checker workflow..."
        act workflow_dispatch -W .github/workflows/image-update-checker.yml --container-architecture linux/amd64 --reuse
        ;;
    5)
        echo "🏗️ Running Build Images workflow..."
        act workflow_dispatch -W .github/workflows/build-images.yml --container-architecture linux/amd64 --reuse
        ;;
    6)
        echo "🔧 Running .NET SDK Update workflow..."
        act workflow_dispatch -W .github/workflows/dotnet-sdk-update.yml --container-architecture linux/amd64 --reuse
        ;;
    7)
        echo "📅 Running Scheduled Update workflow..."
        act workflow_dispatch -W .github/workflows/scheduled-update.yml --container-architecture linux/amd64 --reuse
        ;;
    8)
        echo "🔗 Running Webhook Update workflow..."
        act workflow_dispatch -W .github/workflows/webhook-update.yml --container-architecture linux/amd64 --reuse
        ;;
    9)
        echo "🔓 Running Package Visibility Management workflow..."
        act workflow_dispatch -W .github/workflows/package-visibility.yml --container-architecture linux/amd64 --reuse
        ;;
    10)
        echo "🗑️ Running Clean Registry workflow..."
        echo "⚠️ WARNING: This will delete ALL Docker images from registry!"
        read -p "Are you sure? Type 'YES' to confirm: " confirm
        if [ "$confirm" = "YES" ]; then
            act workflow_dispatch -W .github/workflows/clean-registry.yml --container-architecture linux/amd64 --reuse
        else
            echo "❌ Cancelled by user"
        fi
        ;;
    11)
        echo "🔧 Running Fix Package Visibility workflow..."
        act workflow_dispatch -W .github/workflows/fix-visibility.yml --container-architecture linux/amd64 --reuse
        ;;
    0)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice. Please select 0-11."
        exit 1
        ;;
esac

echo ""
echo "✅ Workflow completed!"
echo ""
echo "📝 Next steps:"
echo "  - Check GitHub Actions tab for results"
echo "  - Verify packages in https://github.com/606?tab=packages"
echo "  - Test pulling images: docker pull ghcr.io/606/docker-images/ubuntu:lts"
