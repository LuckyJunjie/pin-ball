#!/usr/bin/env python3
"""
GitHub Actions Workflow Manager for Pinball Game
- Trigger Godot CI/CD workflows
- Get workflow run results
- Monitor test status
"""

import os
import json
import subprocess
from datetime import datetime

# Configuration
REPO_OWNER = "LuckyJunjie"
REPO_NAME = "pin-ball"
WORKFLOW_FILE = "ci.yml"
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")

def run_command(cmd, check=True):
    """Run shell command and return output"""
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and result.returncode != 0:
        print(f"❌ Command failed: {cmd}")
        print(f"   Error: {result.stderr}")
        return None
    return result.stdout.strip()

def get_api_url(endpoint):
    """Build GitHub API URL"""
    return f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/{endpoint}"

def trigger_workflow():
    """Trigger GitHub Actions workflow"""
    print("🚀 Triggering GitHub Actions workflow...")
    
    if not GITHUB_TOKEN:
        print("⚠️ GITHUB_TOKEN not set")
        print("💡 Setting token for you...")
        return None
    
    # Use gh CLI if available
    result = run_command(f"gh workflow run {WORKFLOW_FILE} --repo {REPO_OWNER}/{REPO_NAME}")
    
    if result is None:
        print("❌ Failed to trigger workflow")
        return None
    
    print("✅ Workflow triggered!")
    print(f"📋 View: https://github.com/{REPO_OWNER}/{REPO_NAME}/actions/workflows/{WORKFLOW_FILE}")
    return True

def get_workflow_runs(limit=5):
    """Get recent workflow runs"""
    print(f"📊 Getting recent workflow runs...")
    
    result = run_command(f"gh run list --workflow {WORKFLOW_FILE} --limit {limit} --repo {REPO_OWNER}/{REPO_NAME}")
    
    if result is None:
        print("❌ Failed to get workflow runs")
        return []
    
    lines = result.split('\n')
    runs = []
    
    for line in lines:
        if line.strip():
            parts = line.split()
            if len(parts) >= 4:
                run = {
                    'id': parts[0],
                    'status': parts[1],
                    'conclusion': parts[2] if len(parts) > 2 else '',
                    'branch': parts[3] if len(parts) > 3 else '',
                    'message': ' '.join(parts[4:]) if len(parts) > 4 else ''
                }
                runs.append(run)
    
    return runs

def get_workflow_run_status():
    """Get latest workflow run status"""
    runs = get_workflow_runs(1)
    
    if not runs:
        return None
    
    run = runs[0]
    
    print(f"\n📋 Latest Workflow Run:")
    print(f"   ID: {run['id']}")
    print(f"   Status: {run['status']}")
    print(f"   Conclusion: {run['conclusion']}")
    print(f"   Branch: {run['branch']}")
    
    return run

def wait_for_completion(run_id, timeout=300):
    """Wait for workflow run to complete"""
    import time
    
    print(f"⏳ Waiting for workflow {run_id} to complete...")
    start = datetime.now()
    
    while (datetime.now() - start).seconds < timeout:
        result = run_command(f"gh run view {run_id} --repo {REPO_OWNER}/{REPO_NAME} --json status,conclusion")
        
        if result:
            try:
                import json
                data = json.loads(result)
                status = data.get('status', '')
                conclusion = data.get('conclusion', '')
                
                if status == 'completed':
                    print(f"\n✅ Workflow completed!")
                    print(f"   Conclusion: {conclusion}")
                    return conclusion
                elif status == 'in_progress' or status == 'queued':
                    print(f"   Status: {status}...")
                    time.sleep(10)
                else:
                    print(f"   Status: {status}")
                    return None
            except:
                pass
        
        time.sleep(5)
    
    print("⏰ Timeout reached")
    return None

def get_test_results():
    """Get test results from latest run"""
    print("\n📊 Test Results:")
    
    runs = get_workflow_runs(1)
    
    if not runs:
        print("   No workflow runs found")
        return
    
    latest_run = runs[0]
    
    # Check status
    if latest_run['status'] == 'completed':
        if latest_run['conclusion'] == 'success':
            print("   ✅ All tests passed!")
        else:
            print(f"   ❌ Tests failed: {latest_run['conclusion']}")
    elif latest_run['status'] == 'in_progress':
        print("   🔄 Tests in progress...")
    else:
        print(f"   ⚠️ Status: {latest_run['status']}")

def show_workflow_info():
    """Show workflow information"""
    print(f"\n📋 Workflow: {WORKFLOW_FILE}")
    print(f"📁 Repo: {REPO_OWNER}/{REPO_NAME}")
    print(f"🔗 URL: https://github.com/{REPO_OWNER}/{REPO_NAME}/actions/workflows/{WORKFLOW_FILE}")
    
    # Show workflow runs
    runs = get_workflow_runs(3)
    
    if runs:
        print(f"\n📊 Recent Runs:")
        for run in runs:
            icon = "✅" if run['conclusion'] == 'success' else "❌" if run['conclusion'] == 'failure' else "🔄"
            print(f"   {icon} {run['id']} | {run['status']} | {run['branch']}")

def main():
    """Main function"""
    print("=" * 60)
    print("🎮 GitHub Actions Workflow Manager for Pinball Game")
    print("=" * 60)
    
    import sys
    
    command = sys.argv[1] if len(sys.argv) > 1 else "status"
    
    if command == "trigger":
        trigger_workflow()
    elif command == "status":
        show_workflow_info()
        get_test_results()
    elif command == "wait":
        runs = get_workflow_runs(1)
        if runs:
            wait_for_completion(runs[0]['id'])
    elif command == "results":
        get_test_results()
    elif command == "runs":
        get_workflow_runs(10)
    elif command == "help":
        print("""
Usage: github_test.py [command]

Commands:
  trigger  - Trigger the CI/CD workflow
  status   - Show workflow status and recent runs
  results  - Get test results from latest run
  wait     - Wait for latest run to complete
  runs     - Show recent workflow runs (10)
  help     - Show this help

Examples:
  python github_test.py trigger
  python github_test.py status
  python github_test.py wait
        """)
    else:
        print(f"Unknown command: {command}")
        print("Run: python github_test.py help")

if __name__ == "__main__":
    main()
