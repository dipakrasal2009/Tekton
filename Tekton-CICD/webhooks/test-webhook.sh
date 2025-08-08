#!/bin/bash
# test-webhook.sh - Test webhook locally

set -e

echo "🧪 Testing GitHub Webhook Locally"
echo "================================="

# Check if EventListener is running
if ! kubectl get pod -l eventlistener=github-webhook-listener -n tekton-ci | grep -q Running; then
    echo "❌ EventListener not running. Please run ./deploy-webhook.sh first"
    exit 1
fi

echo "📋 EventListener Status:"
kubectl get pod -l eventlistener=github-webhook-listener -n tekton-ci

echo ""
echo "🔌 Starting port forward..."
kubectl port-forward svc/el-github-webhook-listener -n tekton-ci 8080:8080 &
PORT_FORWARD_PID=$!

sleep 3

echo "🧪 Sending test webhook payload..."

# Create test payload
cat > test-payload.json << EOF
{
  "repository": {
    "clone_url": "https://github.com/dipakrasal2009/ip-viewer-app.git",
    "name": "ip-viewer-app",
    "owner": {
      "login": "dipakrasal2009"
    }
  },
  "after": "test-commit-sha-12345678",
  "ref": "refs/heads/main",
  "head_commit": {
    "message": "Test webhook trigger",
    "author": {
      "name": "Test User"
    }
  }
}
EOF

# Send test webhook
curl -X POST \
  http://localhost:8080 \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: sha256=test" \
  -d @test-payload.json

echo ""
echo "✅ Test payload sent!"

# Clean up
kill $PORT_FORWARD_PID 2>/dev/null || true
rm -f test-payload.json

echo ""
echo "📊 Check if pipeline was triggered:"
echo "tkn pipelinerun ls -n tekton-ci"
echo ""
echo "🔍 Monitor latest pipeline run:"
echo "tkn pipelinerun logs --last -n tekton-ci -f"

