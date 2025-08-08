#!/bin/bash
# install-tekton-triggers.sh - Install Tekton Triggers

set -e

echo "📦 Installing Tekton Triggers..."
echo "================================"

# Check if Tekton Triggers is already installed
if kubectl get namespace tekton-pipelines-resolvers > /dev/null 2>&1; then
    echo "✅ Tekton Pipelines found"
else
    echo "❌ Please install Tekton Pipelines first using ./setup-ci-pipeline.sh"
    exit 1
fi

# Install Tekton Triggers
echo "📥 Installing Tekton Triggers..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml

echo "⏳ Waiting for Tekton Triggers to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-triggers --timeout=300s -n tekton-pipelines

echo "✅ Tekton Triggers installed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Deploy webhook components: kubectl apply -f webhook-*.yaml"
echo "2. Expose EventListener: ./expose-webhook.sh"
echo "3. Configure GitHub webhook with the provided URL"

