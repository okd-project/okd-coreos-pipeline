# Tekton Operator Build Pipeline

## Intro

All the necessary yaml files to deploy a generic tekton pipeline to build SCOS image

**NB** This is a WIP 

## Description

The pipeline uses a single task for now, `scos-build`, which runs on a `core-assembler` image.

Within the task
* a step that builds the SCOS image
* future (separate) step to test the image
* future step to push the image to an S3 bucket

## Installation

### Install Tekton Operator

Install the tekton cli and tekton resources before continuing (see https://tekton.dev/docs/pipelines/install)

### Clone the repository

```bash
git clone git@github.com:okd-project/cosa-pipeline.git
```

### Install the operator tekton pipeline with kustomize

The pipeline is using [kvm-device-plugin](https://github.com/cgwalters/kvm-device-plugin), which is now part of [KubeVirt](https://github.com/kubevirt). 

The daemonset for kvm-device-plugin will be available on the OKD cluster in OperateFirst, but needs to be installed for your local clusters.

* For OperateFirst OKD cluster, execute the following commands

    ```bash
    # assume you logged into your kubernetes cluster on OperateFirst
    kubectl apply -k environments/overlays/operate-first

    # check that all resources have deployed
    kubectl get all -n cosa-pipeline

    # once all pods are in the RUNNING status create a configmap as follows
    # this assumes you have the correct credentials and have logged into the registry to push images to
    kubectl create configmap docker-config --from-file=/$HOME/.docker/config.json -n cosa-pipeline
    ```
* For local (Kind or other) clusters, execute the following commands:
    ```bash
    # assume you logged into your kubernetes cluster on OperateFirst
    kubectl apply -k environments/overlays/local

    # check that all resources have deployed
    kubectl get all -n cosa-pipeline

    # once all pods are in the RUNNING status create a configmap as follows
    # this assumes you have the correct credentials and have logged into the registry to push images to
    kubectl create configmap docker-config --from-file=/$HOME/.docker/config.json -n cosa-pipeline
    ```


## Usage

Execute the following to start a pipeline run

```bash
tkn pipeline start scos-all \
--param version=4.12 \
--workspace name=shared-workspace,volumeClaimTemplateFile=manifests/tekton/pipelineruns/workspace-template.yaml \
-n okd-team
```

## Next Steps

* Task 2: Test the image
* Task 3: Push the image to S3
* Control previous image, so that we build only upon need
* Use a workspace to share the image built in first task with the other tasks

## Folder structure

The folder structure is as follows :

```bash
├── environments
│   └── overlays
│       ├── local
│       │   ├── kustomization.yaml
│       │   └── namespace
│       │       └── namespace.yaml
│       └── operate-first
│           └── kustomization.yaml
├── LICENSE
├── manifests
│   └── tekton
│       ├── daemonsets
│       │   └── base
│       │       ├── kustomization.yaml
│       │       └── kvm-dev-plg-ds.yaml
│       ├── pipelineruns
│       │   └── workspace-template.yaml
│       ├── pipelines
│       │   └── base
│       │       ├── kustomization.yaml
│       │       ├── pipeline-scos-all.yaml
│       │       └── pipeline-scos-build.yaml
│       ├── rbac
│       │   └── base
│       │       ├── admin.yaml
│       │       ├── edit.yaml
│       │       ├── kustomization.yaml
│       │       └── view.yaml
│       └── tasks
│           └── base
│               ├── kustomization.yaml
│               ├── scos-build.yaml
│               ├── scos-cosa-buildextend.yaml
│               ├── scos-cosa-build.yaml
│               ├── scos-cosa-copy.yaml
│               ├── scos-cosa-init.yaml
│               └── scos-cosa-test.yaml
└── README.md

```
