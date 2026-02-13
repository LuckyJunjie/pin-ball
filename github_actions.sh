#!/bin/bash
# GitHub Actions Trigger & Monitor
# Simple wrapper for the Python script

set -e

cd "$(dirname "$0")"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found!"
    echo "💡 Install: https://cli.github.com/"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "💡 Run: gh auth login"
    exit 1
fi

echo "🎮 Pinball GitHub Actions Manager"
echo "=================================="
echo ""
echo "Repository: LuckyJunjie/pin-ball"
echo "Workflow: ci.yml"
echo ""
echo "Options:"
echo "  1) Trigger workflow"
echo "  2) View recent runs"
echo "  3) View latest run status"
echo "  4) Wait for completion"
echo "  5) Open in browser"
echo ""
read -p "Select option (1-5): " option

case $option in
    1)
        echo ""
        echo "🚀 Triggering workflow..."
        gh workflow run ci.yml --repo LuckyJunjie/pin-ball
        echo ""
        echo "✅ Workflow triggered!"
        echo "🔗 View: https://github.com/LuckyJunjie/pin-ball/actions/workflows/ci.yml"
        ;;
    2)
        echo ""
        echo "📊 Recent workflow runs:"
        gh run list --workflow ci.yml --repo LuckyJunjie/pin-ball --limit 10
        ;;
    3)
        echo ""
        echo "📋 Latest run status:"
        gh run view --repo LuckyJunjie/pin-ball $(gh run list --workflow ci.yml --repo LuckyJunjie/pin-ball --limit 1 -json id --jq '.[0].id')
        ;;
    4)
        echo ""
        RUN_ID=$(gh run list --workflow ci.yml --repo LuckyJunjie/pin-ball --limit 1 -json id --jq '.[0].id')
        echo "⏳ Waiting for run $RUN_ID..."
        gh run watch --repo LuckyJunjie/pin-ball $RUN_ID --exit-status
        echo ""
        echo "✅ Run completed!"
        gh run view --repo LuckyJunjie/pin-ball $RUN_ID
        ;;
    5)
        echo ""
        echo "🌐 Opening GitHub Actions..."
        xdg-open "https://github.com/LuckyJunjie/pin-ball/actions/workflows/ci.yml" 2>/dev/null || \
        open "https://github.com/LuckyJunjie/pin-ball/actions/workflows/ci.yml" 2>/dev/null || \
        echo "🔗 URL: https://github.com/LuckyJunjie/pin-ball/actions/workflows/ci.yml"
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac
