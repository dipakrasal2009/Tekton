# Tekton Pipeline: Clone, Build & Push Docker Image

This repository demonstrates a Tekton CI/CD pipeline that:
- Clones a repository from GitHub
- Builds a Docker image from a Dockerfile  
- Pushes the image to Docker Hub

## Prerequisites

- Kubernetes cluster access with `kubectl`
- Tekton Pipelines and Tekton CLI (`tkn`) installed
- Docker Hub account and credentials

## Pipeline Overview

The pipeline consists of two key tasks:
- **git-clone:** Clones the source code from GitHub
- **kaniko/buildah:** Builds a Docker image and pushes it to Docker Hub

---

## Complete Tekton Commands Reference

### 1. Installation & Setup Commands

#### Install Tekton Pipelines
```bash
kubectl apply --filename \
  https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```
**Explanation:** Installs the latest version of Tekton Pipelines on your Kubernetes cluster.

#### Install Tekton CLI (tkn)
```bash
# macOS
brew install tektoncd-cli

# Linux (download and extract)
curl -LO https://github.com/tektoncd/cli/releases/download/v0.32.0/tkn_0.32.0_Linux_x86_64.tar.gz
sudo tar xvzf tkn_0.32.0_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn
```
**Explanation:** Installs the Tekton CLI for easier interaction with Tekton resources.

### 2. Task Management Commands

#### Install Tasks from Tekton Hub
```bash
tkn hub install task git-clone
tkn hub install task kaniko  
tkn hub install task buildah
```
**Explanation:** Downloads and installs commonly used tasks from Tekton Hub to your cluster.

#### List Available Tasks
```bash
tkn task list
tkn task list -n <namespace>
```
**Explanation:** Shows all tasks available in the current namespace or specified namespace.

#### Describe a Task
```bash
tkn task describe <task-name>
tkn task describe git-clone
```
**Explanation:** Shows detailed information about a specific task including parameters and workspaces.

#### Create a Custom Task
```bash
kubectl apply -f my-task.yaml
tkn task create -f my-task.yaml
```
**Explanation:** Creates a custom task from a YAML file.

#### Delete a Task
```bash
tkn task delete <task-name>
kubectl delete task <task-name>
```
**Explanation:** Removes a task from your cluster.

### 3. Pipeline Management Commands

#### Create a Pipeline
```bash
kubectl apply -f pipeline.yaml
tkn pipeline create -f pipeline.yaml
```
**Explanation:** Creates a pipeline definition from a YAML file.

#### List Pipelines
```bash
tkn pipeline list
tkn pipeline list -n <namespace>
```
**Explanation:** Shows all pipelines in the current or specified namespace.

#### Describe a Pipeline
```bash
tkn pipeline describe <pipeline-name>
tkn pipeline describe clone-build-push
```
**Explanation:** Shows detailed information about a specific pipeline including tasks and parameters.

#### Start a Pipeline
```bash
tkn pipeline start <pipeline-name>
tkn pipeline start clone-build-push \
  --param repo-url=https://github.com/user/repo.git \
  --param image-reference=docker.io/user/image:tag \
  --workspace name=shared-data,claimName=workspace-pvc
```
**Explanation:** Starts a pipeline execution with specified parameters and workspaces.

#### Delete a Pipeline
```bash
tkn pipeline delete <pipeline-name>
kubectl delete pipeline <pipeline-name>
```
**Explanation:** Removes a pipeline from your cluster.

### 4. PipelineRun Management Commands

#### List PipelineRuns
```bash
tkn pipelinerun list
tkn pipelinerun list -n <namespace>
```
**Explanation:** Shows all pipeline runs and their status.

#### Describe a PipelineRun
```bash
tkn pipelinerun describe <pipelinerun-name>
tkn pr describe <pipelinerun-name>
```
**Explanation:** Shows detailed information about a specific pipeline run.

#### View PipelineRun Logs
```bash
tkn pipelinerun logs <pipelinerun-name> -f
tkn pr logs <pipelinerun-name> --follow
```
**Explanation:** Shows logs from a pipeline run. The `-f` flag follows logs in real-time.

#### Cancel a PipelineRun
```bash
tkn pipelinerun cancel <pipelinerun-name>
```
**Explanation:** Cancels a running pipeline.

#### Delete PipelineRuns
```bash
tkn pipelinerun delete <pipelinerun-name>
tkn pr delete <pipelinerun-name>
```
**Explanation:** Removes completed pipeline runs from your cluster.

### 5. TaskRun Management Commands

#### List TaskRuns
```bash
tkn taskrun list
tkn taskrun list -n <namespace>
```
**Explanation:** Shows all task runs and their status.

#### Describe a TaskRun
```bash
tkn taskrun describe <taskrun-name>
tkn tr describe <taskrun-name>
```
**Explanation:** Shows detailed information about a specific task run.

#### View TaskRun Logs
```bash
tkn taskrun logs <taskrun-name> -f
tkn tr logs <taskrun-name> --follow
```
**Explanation:** Shows logs from a task run with optional real-time following.

#### Start a Task
```bash
tkn task start <task-name>
tkn task start git-clone \
  --param url=https://github.com/user/repo.git \
  --workspace name=output,claimName=source-pvc
```
**Explanation:** Starts a single task with parameters and workspaces.

#### Cancel a TaskRun
```bash
tkn taskrun cancel <taskrun-name>
```
**Explanation:** Cancels a running task.

#### Delete TaskRuns
```bash
tkn taskrun delete <taskrun-name>
tkn tr delete <taskrun-name>
```
**Explanation:** Removes completed task runs from your cluster.

### 6. Secret Management Commands

#### Create Docker Registry Secret
```bash
kubectl create secret docker-registry docker-credentials \
  --docker-username=<DOCKER_USERNAME> \
  --docker-password=<DOCKER_PASSWORD> \
  --docker-email=<YOUR_EMAIL> \
  --docker-server=https://index.docker.io/v1/
```
**Explanation:** Creates a secret containing Docker Hub credentials for image push operations.

#### Create Generic Secret
```bash
kubectl create secret generic my-secret \
  --from-literal=username=myuser \
  --from-literal=password=mypass
```
**Explanation:** Creates a generic secret with key-value pairs.

#### Create Secret from File
```bash
kubectl create secret generic docker-config \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson
```
**Explanation:** Creates a Docker config secret from your local Docker configuration.

### 7. ServiceAccount Management Commands

#### Create ServiceAccount
```bash
kubectl create serviceaccount tekton-service-account
```
**Explanation:** Creates a service account for pipeline authentication.

#### Create ServiceAccount Token (Kubernetes 1.24+)
```bash
kubectl create token tekton-service-account
```
**Explanation:** Creates a time-limited token for the service account.

#### Create Long-lived ServiceAccount Token
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: tekton-service-account-token
  annotations:
    kubernetes.io/service-account.name: tekton-service-account
type: kubernetes.io/service-account-token
EOF
```
**Explanation:** Creates a persistent token secret for the service account.

### 8. Workspace Management Commands

#### Create PVC for Workspace
```bash
kubectl create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: tekton-workspace-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```
**Explanation:** Creates a persistent volume claim for pipeline workspaces.

#### Using Workspace in Pipeline Runs
```bash
tkn pipeline start my-pipeline \
  --workspace name=shared-data,claimName=tekton-workspace-pvc \
  --workspace name=docker-credentials,secret=docker-credentials
```
**Explanation:** Specifies different types of workspaces when starting a pipeline.

### 9. Tekton Hub Commands

#### Search Hub for Tasks
```bash
tkn hub search
tkn hub search --kind task
tkn hub search git
```
**Explanation:** Searches Tekton Hub for available tasks and resources.

#### Get Hub Resource Information
```bash
tkn hub info task git-clone
tkn hub info task git-clone --from tekton --version 0.8
```
**Explanation:** Shows detailed information about a specific Hub resource.

#### Install from Hub
```bash
tkn hub install task git-clone
tkn hub install task git-clone --from tekton --version 0.8
```
**Explanation:** Installs a specific task version from Tekton Hub.

#### Reinstall Hub Resource
```bash
tkn hub reinstall task git-clone --from tekton --version 0.9
```
**Explanation:** Updates an existing task to a newer version.

### 10. Debugging & Monitoring Commands

#### View All Resources
```bash
tkn list
```
**Explanation:** Shows a summary of all Tekton resources in the current namespace.

#### Watch Pipeline Progress
```bash
watch tkn pipelinerun list
```
**Explanation:** Continuously monitors pipeline run status.

#### Get Resource YAML
```bash
tkn pipeline describe <pipeline-name> -o yaml
tkn task describe <task-name> -o json
```
**Explanation:** Exports resource definitions in YAML or JSON format.

#### View Events
```bash
kubectl get events --sort-by='.metadata.creationTimestamp'
```
**Explanation:** Shows cluster events related to Tekton resources.

### 11. Cleanup Commands

#### Delete All PipelineRuns
```bash
tkn pipelinerun delete --all
```
**Explanation:** Removes all pipeline runs from the current namespace.

#### Delete All TaskRuns
```bash
tkn taskrun delete --all
```
**Explanation:** Removes all task runs from the current namespace.

#### Delete All Tekton Resources
```bash
kubectl delete pipelines,tasks,pipelineruns,taskruns --all
```
**Explanation:** Removes all Tekton resources from the current namespace.

### 12. Advanced Commands

#### Pipeline with Matrix Parameters
```bash
tkn pipeline start build-matrix \
  --param platforms='["linux/amd64","linux/arm64"]' \
  --workspace name=source,claimName=source-pvc
```
**Explanation:** Starts a pipeline with matrix parameters for parallel execution.

#### Custom Resource Definitions
```bash
kubectl get crds | grep tekton
```
**Explanation:** Lists all Tekton Custom Resource Definitions.

#### Export Pipeline Run
```bash
tkn pipelinerun describe <pipelinerun-name> -o yaml > pipelinerun-backup.yaml
```
**Explanation:** Exports a pipeline run definition for backup or analysis.

---

## Quick Setup Example

Here's a complete example to get you started:

```bash
# 1. Install required tasks
tkn hub install task git-clone
tkn hub install task kaniko

# 2. Create Docker credentials secret
kubectl create secret docker-registry docker-credentials \
  --docker-username=<YOUR_USERNAME> \
  --docker-password=<YOUR_PASSWORD> \
  --docker-email=<YOUR_EMAIL> \
  --docker-server=https://index.docker.io/v1/

# 3. Create workspace PVC
kubectl create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: workspace-pvc
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
EOF

# 4. Apply your pipeline
kubectl apply -f pipeline.yaml

# 5. Start the pipeline
tkn pipeline start clone-build-push \
  --param repo-url=https://github.com/yourusername/your-repo.git \
  --param image-reference=docker.io/yourusername/your-image:latest \
  --workspace name=shared-data,claimName=workspace-pvc \
  --workspace name=docker-credentials,secret=docker-credentials \
  --showlog
```

## Example Pipeline Files

See the included `pipeline.yaml` and `pipelinerun.yaml` files in this repository for complete examples.

## Useful Tips

1. **Namespace Management:** Always specify the namespace with `-n <namespace>` if not using the default namespace.

2. **Log Following:** Use `-f` or `--follow` flags to watch logs in real-time.

3. **Resource Cleanup:** Regularly clean up completed PipelineRuns and TaskRuns to avoid cluttering your cluster.

4. **Parameter Defaults:** Use `--use-param-defaults` to automatically use default parameter values.

5. **Workspace Types:** Remember the different workspace types:
   - `claimName=<pvc-name>` for PersistentVolumeClaim
   - `secret=<secret-name>` for Secret
   - `config=<configmap-name>` for ConfigMap
   - `emptyDir=""` for temporary storage

## Notes

- Ensure you update all placeholder values before running commands
- Keep your secrets safe—don't commit real secrets to version control
- Tasks and Pipelines must be in the same namespace to work together
- Use `tkn --help` or `tkn <command> --help` for detailed command information

**Happy building with Tekton!**
