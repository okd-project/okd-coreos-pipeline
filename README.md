# OKD CoreOS Build Pipeline

All the necessary yaml files to deploy a generic tekton pipeline to build a CoreOS image using coreos-assembler.

**NB** This is a WIP

## Description

The list of tasks are :
* cosa-init
* cosa-build
* cosa-buildextend
* cosa-test
* cosa-upload-images
* rpm-artifacts-copy

The pipeline uses [kvm-device-plugin](https://github.com/cgwalters/kvm-device-plugin),
which is now part of [KubeVirt](https://github.com/kubevirt).

## Installation

Clone the repository:

```bash
git clone https://github.com/okd-project/okd-coreos-pipeline.git
```

* For local (Kind or other) clusters, execute the following commands:
    ```bash
    # assume you logged into your local cluster

    # install tekton if haven't already
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

    # the local overlay includes a device-plugin-kvm daemonset
    kubectl apply -k environments/overlays/local

    # check that all resources have deployed
    kubectl get all -n okd-coreos-pipeline
    ```

    Once all pods are in the RUNNING status create a secret that will allow you to push to the selected
    registry (pipelineRun parameter target-repository), as in the example below:

    Sample secret file:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: my-secret
    data:
      .dockerconfigjson: ewo...p9
    type: kubernetes.io/dockerconfigjson
    ```

    Use this command to create the secret:
    ```bash
    kubectl apply -f ./my-secret.yaml -n okd-coreos-pipeline
    ```


* OKD team members may do the following for deploying to the OperateFirst by executing the following commands:
    ```bash
    # assume you logged into your kubernetes cluster on OperateFirst
    kubectl apply -k environments/overlays/operate-first

    # check that all resources have deployed
    kubectl get all -n okd-team
    ```

## Usage

Execute the following to start a pipelinerun locally:

Change the ${VERSION} values in the relevant file (okd-coreos-all-pipelinerun.yaml or okd-coreos-build-pipelinerun.yaml) 

Alternatively there is a utility script that you can use (execute-pipelinerun.sh)

This allows the pipelinerun to execute using specific versions of openshift . It mitigates the need for adding various pipelinerun versioned files to this repo

```bash
kubectl create \
    -n okd-coreos-pipeline \
    -f environments/overlays/local/pipelineruns/okd-coreos-all-pipelinerun.yaml

# see the logs
tkn pipelinerun logs -f \
    -n okd-coreos-pipeline \
    okd-coreos-all-pipelinerun-fooba
```

On OperateFirst, run:
```bash
kubectl create \
    -n okd-team \
    -f environments/overlays/operate-first/pipelineruns/okd-coreos-all-pipelinerun.yaml

# see the logs
tkn pipelinerun logs -f \
    -n okd-team \
    okd-coreos-all-pipelinerun-fooba
```

## TODO

* Push the image artifacts to S3 bucket
* Build and test images for more platforms
* Control the previous build, so that we build when needed

## Folder structure

The folder structure is as follows :

```bash
.
├── LICENSE
├── README.md
├── environments
│   └── overlays
│       ├── local
│       │   ├── kustomization.yaml
│       │   ├── namespace
│       │   │   └── namespace.yaml
│       │   └── pipelineruns
│       │       ├── okd-coreos-all-pipelinerun.yaml
│       │       └── okd-coreos-build-pipelinerun.yaml
│       └── operate-first
│           ├── kustomization.yaml
│           └── pipelineruns
│               ├── okd-coreos-all-pipelinerun.yaml
│               └── okd-coreos-build-pipelinerun.yaml
└── manifests
    └── tekton
        ├── daemonsets
        │   └── base
        │       ├── device-plugin-kvm-daemonset.yaml
        │       └── kustomization.yaml
        ├── pipelines
        │   └── base
        │       ├── kustomization.yaml
        │       ├── okd-coreos-all.yaml
        │       └── okd-coreos-build.yaml
        ├── rbac
        │   └── base
        │       ├── admin.yaml
        │       ├── edit.yaml
        │       ├── kustomization.yaml
        │       └── view.yaml
        └── tasks
            └── base
                ├── cosa-build-baseos.yaml
                ├── cosa-build-extensions.yaml
                ├── cosa-buildextend.yaml
                ├── cosa-init.yaml
                ├── cosa-test.yaml
                ├── cosa-upload.yaml
                ├── kustomization.yaml
                └── rpm-artifacts-copy.yaml

```
