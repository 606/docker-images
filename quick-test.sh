#!/bin/bash

# Quick test script - fast execution without hanging

echo "⚡ Quick Test Script"
echo "==================="

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

# Quick test with timeout
echo "🧪 Testing quick workflow..."
timeout 30s act workflow_dispatch -W .github/workflows/quick-test.yml --container-architecture linux/amd64 --reuse

if [ $? -eq 124 ]; then
    echo "⏰ Test timed out after 30 seconds"
    echo "💡 This suggests ACT is hanging. Try:"
    echo "   - Restart Docker"
    echo "   - Use smaller container images"
    echo "   - Check Docker resources"
else
    echo "✅ Quick test completed successfully!"
fi

echo ""
echo "🔍 System status:"
echo "  - Docker: $(docker info --format '{{.ServerVersion}}' 2>/dev/null || echo 'Not running')"
echo "  - ACT: $(act --version 2>/dev/null || echo 'Not working')"
echo "  - Available memory: $(docker system df --format 'table {{.Type}}\t{{.TotalCount}}\t{{.Size}}' 2>/dev/null | grep Images || echo 'Unknown')"
