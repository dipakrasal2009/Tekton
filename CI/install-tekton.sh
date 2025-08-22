#!/bin/bash
# install-tekton.sh - Script to install Tekton Pipelines on Kubernetes/Minikube

set -e

echo "🚀 Installing Tekton Pipelines"
echo "================================"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command_exists kubectl; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

echo "✅ kubectl found"

# Install Tekton Pipelines
echo "📦 Installing Tekton Pipelines..."

kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

echo "✅ Tekton Pipelines installation triggered"

# Wait for pods to be ready
echo "⏳ Waiting for Tekton Pipelines pods to be ready..."
kubectl wait --for=condition=Available deployment --all -n tekton-pipelines --timeout=180s

echo "🚀 Installing Tekton Dashboard..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml

echo "⏳ Waiting for Tekton Dashboard pods to be ready..."
kubectl wait --for=condition=Available deployment --all -n tekton-pipelines --timeout=180s

echo "✅ Tekton Dashboard installed successfully!"

echo "🔍 To access Tekton Dashboard, run the following command:"
echo "kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097"
echo "Then open http://localhost:9097 in your browser 🚀"

echo "🎉 Tekton Pipelines successfully installed!"
echo "👉 You can now create Tasks, Pipelines, and PipelineRuns."

