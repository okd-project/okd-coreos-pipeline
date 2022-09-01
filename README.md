# OKD CoreOS Build Pipeline

All the necessary yaml files to deploy a generic tekton pipeline to build a CoreOS image using coreos-assembler.

**NB** This is a WIP

## Description

The list of tasks are :
* cosa-init
* cosa-build
* cosa-buildextend
* cosa-test

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

    # once all pods are in the RUNNING status create a configmap as follows
    # this assumes you have the correct credentials and have logged into the registry to push images to
    kubectl create configmap docker-config --from-file=/$HOME/.docker/config.json -n okd-coreos-pipeline
    ```

* For OperateFirst OKD cluster, execute the following commands
    ```bash
    # assume you logged into your kubernetes cluster on OperateFirst
    kubectl apply -k environments/overlays/operate-first

    # check that all resources have deployed
    kubectl get all -n okd-team

    # once all pods are in the RUNNING status create a configmap as follows
    # this assumes you have the correct credentials and have logged into the registry to push images to
    kubectl create configmap docker-config --from-file=/$HOME/.docker/config.json -n okd-team
    ```

## Usage

Execute the following to start a pipeline run:

```bash
kubectl create \
    -n okd-coreos-pipeline \
    -f environments/overlays/local/pipelineruns/okd-coreos-all-pipelinerun.yaml

# see the logs
tkn pipelinerun logs -f \
    -n okd-coreos-pipeline \
    okd-coreos-all-pipelinerun-fooba
```

## TODO

* Test the image
* Push the image artifacts to S3 bucket
* Push container and extensions to quay.io
* Control previous image, so that we build only upon need

The pipeline uses [kvm-device-plugin](https://github.com/cgwalters/kvm-device-plugin), which is now part of [KubeVirt](https://github.com/kubevirt).

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
│       │   ├── namespace.yaml
│       │   └── pipelineruns
│       │       ├── okd-coreos-all-pipelinerun.yaml
│       │       └── okd-coreos-build-pipelinerun.yaml
│       └── operate-first
│           ├── kustomization.yaml
│           └── pipelineruns
│               ├── okd-coreos-all-pipelinerun.yaml
│               └── okd-coreos-build-pipelinerun-.yaml
└── manifests
    ├── apps
    └── tekton
        ├── daemonsets
        │   └── base
        │       ├── kustomization.yaml
        │       └── device-plugin-kvm-daemonset.yaml
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
                ├── cosa-build.yaml
                ├── cosa-buildextend.yaml
                ├── cosa-init.yaml
                ├── cosa-test.yaml
                ├── kustomization.yaml
                └── rpm-artifacts-copy.yaml

```
