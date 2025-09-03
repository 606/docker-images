#!/bin/bash

# Local GitHub Actions pipeline runner using act
# This script allows you to run all pipelines locally for testing

echo "🚀 Local GitHub Actions Pipeline Runner"
echo "======================================"

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "❌ act is not installed. Please install it first:"
    echo "   brew install act"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Create .secrets file if it doesn't exist
if [ ! -f ".secrets" ]; then
    echo "📝 Creating .secrets file..."
    cat > .secrets << EOF
GITHUB_TOKEN=your_github_token_here
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password
EOF
    echo "⚠️  Please edit .secrets file with your actual credentials"
    echo "   Then run this script again"
    exit 1
fi

# Function to run a specific workflow
run_workflow() {
    local workflow_name=$1
    local workflow_file=$2
    local event_type=${3:-workflow_dispatch}
    
    echo "🔧 Running workflow: $workflow_name"
    echo "   File: $workflow_file"
    echo "   Event: $event_type"
    echo "---"
    
    if [ "$event_type" = "workflow_dispatch" ]; then
        act workflow_dispatch -W "$workflow_file" --secret-file .secrets
    else
        act -W "$workflow_file" --secret-file .secrets
    fi
    
    echo "---"
    echo "✅ Workflow $workflow_name completed"
    echo ""
}

# Function to run scheduled workflows
run_scheduled_workflows() {
    echo "⏰ Running scheduled workflows..."
    
    # Run image update checker (daily schedule)
    echo "🔄 Running Image Update Checker (daily schedule)..."
    act schedule -W .github/workflows/image-update-checker.yml --secret-file .secrets
    
    # Run .NET SDK update (Tuesday schedule)
    echo "🔄 Running .NET SDK Update (Tuesday schedule)..."
    act schedule -W .github/workflows/dotnet-sdk-update.yml --secret-file .secrets
    
    # Run monthly scheduled update
    echo "🔄 Running Monthly Scheduled Update..."
    act schedule -W .github/workflows/scheduled-update.yml --secret-file .secrets
}

# Main menu
show_menu() {
    echo "📋 Available workflows:"
    echo "  1. Image Update Checker"
    echo "  2. Build and Push Images"
    echo "  3. .NET SDK Update"
    echo "  4. Webhook Update"
    echo "  5. Scheduled Update"
    echo "  6. Run All Workflows"
    echo "  7. Run Scheduled Workflows"
    echo "  8. Test Specific Workflow"
    echo "  0. Exit"
    echo ""
    read -p "Select option (0-8): " choice
}

# Run specific workflow based on choice
run_choice() {
    case $choice in
        1)
            run_workflow "Image Update Checker" ".github/workflows/image-update-checker.yml"
            ;;
        2)
            run_workflow "Build and Push Images" ".github/workflows/build-images.yml"
            ;;
        3)
            run_workflow ".NET SDK Update" ".github/workflows/dotnet-sdk-update.yml"
            ;;
        4)
            run_workflow "Webhook Update" ".github/workflows/webhook-update.yml" "repository_dispatch"
            ;;
        5)
            run_workflow "Scheduled Update" ".github/workflows/scheduled-update.yml"
            ;;
        6)
            echo "🚀 Running all workflows..."
            run_workflow "Image Update Checker" ".github/workflows/image-update-checker.yml"
            run_workflow "Build and Push Images" ".github/workflows/build-images.yml"
            run_workflow ".NET SDK Update" ".github/workflows/dotnet-sdk-update.yml"
            run_workflow "Webhook Update" ".github/workflows/webhook-update.yml" "repository_dispatch"
            run_workflow "Scheduled Update" ".github/workflows/scheduled-update.yml"
            ;;
        7)
            run_scheduled_workflows
            ;;
        8)
            read -p "Enter workflow file path: " workflow_path
            if [ -f "$workflow_path" ]; then
                run_workflow "Custom Workflow" "$workflow_path"
            else
                echo "❌ Workflow file not found: $workflow_path"
            fi
            ;;
        0)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please try again."
            ;;
    esac
}

# Check if secrets file exists and has valid content
check_secrets() {
    if [ -f ".secrets" ]; then
        if grep -q "your_github_token_here" .secrets; then
            echo "⚠️  Please update .secrets file with your actual credentials"
            echo "   Current .secrets file contains placeholder values"
            return 1
        fi
        return 0
    fi
    return 1
}

# Main execution
main() {
    echo "🔍 Checking prerequisites..."
    
    if ! check_secrets; then
        echo "❌ Please configure .secrets file first"
        exit 1
    fi
    
    echo "✅ All prerequisites met"
    echo ""
    
    while true; do
        show_menu
        run_choice
        echo ""
        read -p "Press Enter to continue..."
        echo ""
    done
}

# Run main function
main
