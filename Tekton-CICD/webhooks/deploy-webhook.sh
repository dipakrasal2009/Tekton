#!/bin/bash
# deploy-webhook.sh - Deploy all webhook components

set -e

echo "🚀 Deploying GitHub Webhook Components"
echo "======================================"

# Check if Tekton Triggers is installed
echo "📋 Checking Tekton Triggers installation..."
if ! kubectl get namespace tekton-pipelines > /dev/null 2>&1; then
    echo "❌ Tekton Pipelines not found. Please run ./setup-ci-pipeline.sh first"
    exit 1
fi

# Install Tekton Triggers if not already installed
if ! kubectl get deployment tekton-triggers-controller -n tekton-pipelines > /dev/null 2>&1; then
    echo "📦 Installing Tekton Triggers..."
    ./install-tekton-triggers.sh
else
    echo "✅ Tekton Triggers already installed"
fi

# Deploy webhook components
echo ""
echo "📦 Deploying webhook components..."

echo "  🔐 Creating webhook secret..."
kubectl apply -f webhook-secret.yaml

echo "  📋 Creating TriggerBinding..."
kubectl apply -f webhook-trigger-binding.yaml

echo "  📄 Creating TriggerTemplate..."
kubectl apply -f webhook-trigger-template.yaml

echo "  🎧 Creating EventListener..."
kubectl apply -f webhook-event-listener.yaml

echo ""
echo "⏳ Waiting for EventListener to be ready..."
kubectl wait --for=condition=ready pod -l eventlistener=github-webhook-listener -n tekton-ci --timeout=120s

echo ""
echo "🎉 Webhook components deployed successfully!"
echo ""
echo "📊 Verify deployment:"
echo "kubectl get eventlistener -n tekton-ci"
echo "kubectl get svc -n tekton-ci | grep webhook"
echo ""
echo "🚀 Next step: Run ./expose-webhook.sh to expose the webhook endpoint"
echo ""
echo "📝 GitHub Webhook Configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Get your webhook URL by running: ./expose-webhook.sh"
echo "2. Go to GitHub: Your Repo → Settings → Webhooks → Add webhook"
echo "3. Payload URL: [Your webhook URL from step 1]"
echo "4. Content type: application/json"
echo "5. Secret: mysecrettoken123"
echo "6. Events: Just the push event"
echo "7. Active: ✅ Checked"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

