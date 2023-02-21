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

    # install tekton if you haven't already
    kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml

    # the local overlay includes a device-plugin-kvm daemonset
    kubectl apply -k overlays/local

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
    kubectl apply -k overlays/operate-first

    # check that all resources have deployed
    kubectl get all -n okd-team
    ```

## Usage

Execute the following to start a pipelinerun locally:

```bash
kubectl create \
    -n okd-coreos-pipeline \
    -f overlays/local/pipelineruns/okd-coreos-build-4.12-pipelinerun.yaml

# see the logs
tkn pipelinerun logs -f \
    -n okd-coreos-pipeline \
    okd-coreos-build-4.12-pipelinerun-fooba
```

On OperateFirst, run:
```bash
kubectl create \
    -n okd-team \
    -f overlays/operate-first/pipelineruns/okd-coreos-all-4.12-pipelinerun.yaml

# see the logs
tkn pipelinerun logs -f \
    -n okd-team \
    okd-coreos-all-4.12-pipelinerun-fooba
```

## TODO

* Push the image artifacts to S3 bucket
* Build and test images for more platforms
* Control the previous build, so that we build when needed
