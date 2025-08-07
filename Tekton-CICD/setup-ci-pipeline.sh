#!/bin/bash
# setup-ci-pipeline.sh - Script to set up Tekton CI Pipeline

set -e

echo "🚀 Setting up Tekton CI Pipeline"
echo "=================================="

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

if ! command_exists minikube; then
    echo "❌ minikube is not installed. Please install minikube first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Start minikube if not running
echo "🔧 Checking minikube status..."
if ! minikube status > /dev/null 2>&1; then
    echo "🚀 Starting minikube..."
    minikube start --memory=4096 --cpus=2
else
    echo "✅ Minikube is already running"
fi

# Install Tekton Pipelines if not already installed
echo "📦 Checking Tekton Pipelines installation..."
if ! kubectl get namespace tekton-pipelines > /dev/null 2>&1; then
    echo "📦 Installing Tekton Pipelines..."
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

    echo "⏳ Waiting for Tekton Pipelines to be ready..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-pipelines --timeout=300s -n tekton-pipelines
else
    echo "✅ Tekton Pipelines already installed"
fi

# Deploy CI pipeline components
echo "📦 Deploying CI Pipeline components..."

echo "  📄 Creating namespace..."
kubectl apply -f namespace.yaml

echo "  🔐 Creating secrets..."
kubectl apply -f secrets.yaml

echo "  👤 Creating service account..."
kubectl apply -f serviceaccount.yaml

echo "  🔒 Creating RBAC..."
kubectl apply -f rbac.yaml

echo "  💾 Creating PVC..."
kubectl apply -f pvc.yaml

echo "  📋 Creating tasks..."
kubectl apply -f git-clone-task.yaml
kubectl apply -f buildah-task.yaml

echo "  🔄 Creating pipeline..."
kubectl apply -f ci-pipeline.yaml

echo ""
echo "🎉 CI Pipeline setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Edit 02-secrets.yaml and replace YOUR_DOCKERHUB_USERNAME and YOUR_DOCKERHUB_PASSWORD"
echo "2. Edit 09-pipelinerun.yaml and update git-url and image-name parameters"
echo "3. Run the pipeline: kubectl create -f 09-pipelinerun.yaml"
echo ""
echo "📊 Verify installation:"
echo "kubectl get all -n tekton-ci"
echo ""
echo "🔍 Check pipeline:"
echo "kubectl get pipeline -n tekton-ci"
echo ""
echo "💡 Monitor pipeline runs:"
echo "kubectl get pipelinerun -n tekton-ci"
echo "kubectl logs -n tekton-ci -l tekton.dev/pipelineRun=<pipelinerun-name> -f"

