# Tekton CI/CD Pipeline with GitHub Webhook Automation

This project provides a complete Continuous Integration and Continuous Deployment (CI/CD) pipeline using Tekton that automatically builds Docker images, pushes them to Docker Hub, and deploys your application to Kubernetes whenever you push code to your GitHub repository.

## 🎯 What This Pipeline Does

### Continuous Integration (CI)
1. **Monitors GitHub Repository** – Listens for push events via webhooks.
2. **Clones Source Code** – Automatically clones the exact commit that triggered the pipeline.
3. **Builds Docker Image** – Uses your Dockerfile to build container images.
4. **Tags with Commit SHA** – Tags images with short commit SHA (e.g., `myapp:a1b2c3d4`).
5. **Pushes to Docker Hub** – Publishes images to your Docker Hub repository.

### Continuous Deployment (CD)
6. **Patches Kubernetes Deployment** – Updates your app with the newly built image tag.
7. **Manages Rollout** – Kubernetes safely deploys the new version to your cluster.
8. **Verifies Deployment** – Confirms the rollout completed successfully.

## 📋 Prerequisites

- ✅ **Kubernetes cluster** (minikube, kind, or cloud cluster).
- ✅ **kubectl** configured to access your cluster.
- ✅ **tkn CLI** installed (Tekton CLI).
- ✅ **Docker Hub account** with username and password/token.
- ✅ **GitHub repository** with a Dockerfile.
- ✅ **ngrok account** (for webhook exposure) – Sign up at <https://ngrok.com>.

## 🚀 Step-by-Step Deployment Guide

### Phase 1: Core Pipeline Setup

#### Step 1: Deploy Core Tekton CI Pipeline
```bash
./setup-ci-pipeline.sh   # installs Tekton and CI components
```

#### Step 2: Configure Docker Hub Credentials
```bash
nano secrets.yaml  # update username & password, then
kubectl apply -f secrets.yaml
```

#### Step 3: Test Manual Pipeline Run
```bash
nano simple-pipelinerun.yaml  # set git-url & image-name
kubectl create -f simple-pipelinerun.yaml

# watch logs
tkn pipelinerun logs --last -n tekton-ci -f
```

---

### Phase 2: Webhook Automation Setup

#### Step 4: Deploy Webhook Components
```bash
cd webhooks && ./deploy-webhook.sh
```

#### Step 5: Expose Webhook Endpoint via ngrok
```bash
./expose-webhook.sh   # choose ngrok option and follow prompts
```

#### Step 6: Configure GitHub Webhook
Add a webhook in your repo with:
- **Payload URL:** `https://<YOUR_NGROK_URL>.ngrok.io`
- **Content type:** `application/json`
- **Secret:** same as in `webhook-secret.yaml`.

#### Step 7: Test Automated Pipeline
```bash
echo "# test" >> README.md
git add . && git commit -m "test webhook" && git push

# watch run
tkn pipelinerun logs --last -n tekton-ci -f
```

---

### Phase 3: Continuous Deployment (CD) Setup

#### Step 8: Deploy CD Components
```bash
kubectl apply -f cd-deploy-task.yaml
kubectl apply -f cd-pipeline.yaml
kubectl apply -f ci-cd-pipeline.yaml
```

#### Step 9: Create Initial Kubernetes Deployment
```bash
kubectl apply -f k8s-deployment.yaml
```

#### Step 10: Update Webhook Template to Use CI-CD Pipeline
```bash
nano webhooks/webhook-trigger-template.yaml  # set pipelineRef to ci-cd-pipeline
kubectl apply -f webhooks/webhook-trigger-template.yaml
```

#### Step 11: Test Full CI/CD Flow
```bash
git commit --allow-empty -m "trigger full pipeline" && git push

tkn pipelinerun logs --last -n tekton-ci -f
kubectl rollout status deployment/ip-viewer-app -n default
```

---

## 📁 File Structure
```
Tekton-CICD/
├── buildah-task.yaml           # Build & push image
├── ci-pipeline-simple.yaml     # CI pipeline
├── ci-cd-pipeline.yaml         # Combined CI/CD pipeline
├── cd-deploy-task.yaml         # CD deploy task
├── cd-pipeline.yaml            # CD pipeline
├── k8s-deployment.yaml         # App Deployment manifest
├── simple-git-clone-task.yaml  # Git clone task
├── simple-pipelinerun.yaml     # Manual run template
├── secrets.yaml                # Docker Hub creds
├── serviceaccount.yaml         # Pipeline SA
├── rbac.yaml                   # RBAC rules
├── setup-ci-pipeline.sh        # Install script
└── webhooks/                   # Webhook assets
```

## 🔧 Key Configurations
- **`secrets.yaml`** – Docker Hub `username` & `password`.
- **`simple-pipelinerun.yaml`** – `git-url`, `image-name`.
- **`webhook-secret.yaml`** – secure `secretToken`.
- **`k8s-deployment.yaml`** – container `image` & `containerPort`.

## 📊 Monitoring & Troubleshooting
```bash
# Pipelines
tkn pipelinerun ls -n tekton-ci
# Live logs
tkn pipelinerun logs --last -n tekton-ci -f
# Deployment rollout
kubectl rollout status deployment/ip-viewer-app -n default
```

Common fixes:
- **ImagePullBackOff:** check image tag matches push.
- **Webhook not firing:** confirm ngrok tunnel & GitHub delivery logs.
- **RBAC errors:** ensure `ci-pipeline-sa` has edit/patch permissions.

## 💡 Security Notes
- Use Docker Hub access tokens (not passwords).
- Regenerate a strong webhook secret: `openssl rand -hex 32`.
- Replace ngrok with Ingress for production clusters.

## 🌐 Service Exposure
- **Minikube:** NodePort service.
- **OpenShift:** Route resource for external URL.

## 🎉 Success Checklist
- ✅ CI builds & pushes image.
- ✅ CD patches deployment with new tag.
- ✅ Kubernetes rollout succeeds.
- ✅ App accessible with latest change.

Enjoy your fully-automated Tekton CI/CD pipeline! 🚀

