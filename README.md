# OKD CoreOS Build Pipeline

All the necessary resources to deploy a generic Tekton pipeline to build CoreOS boot and container images using rpm-ostree and coreos-assembler.

## Usage in a Kind cluster

For Kind (and possibly other) clusters, execute the following commands:

```bash
# create and log into your cluster
kind create cluster

# clone repo
git clone https://github.com/okd-project/okd-coreos-pipeline.git
cd okd-coreos-pipeline

# install tekton
kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml

# create task and pipeline definitions
kubectl apply -k environments/kind

# check all resources have been deployed
kubectl get all -n okd-coreos
```

Once all pods are in the RUNNING status create a secret that will allow you to push to the selected
registry (pipelineRun parameter target-repository), as in the example below:

Sample registry auth secret file:

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
kubectl apply -f ./my-secret.yaml -n okd-coreos

# run pipeline
kubectl create \
-n okd-coreos \
-f environments/kind/pipelineruns/okd-coreos-build-4.14-pipelinerun.yaml

# see the logs
tkn pipelinerun logs -f \
-n okd-coreos \
okd-coreos-build-4.14-pipelinerun-fooba
```

### Sending pipeline status notifications to a Matrix channel

In order for the pipeline to be able to send its status to a matrix room, make sure you create a secret, `matrix-access-token`, of type generic with a single key, `token`, containing the access token to the matrix endpoint.

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: matrix-access-token
stringData:
  token: {OAuth token for the bot app}
```

The pipeline run `environments/moc/pipelineruns/okd-coreos-all-4.*-pipelinerun.yaml` uses the following parameters:
* `matrix-room` : containing the matrix roomID where the notification will be sent
* `matrix-endpoint`: URI of the matrix server hosting the room

## MOC

For manually creating pipelineruns on the MOC build farm, execute the following commands:

```bash
# log into MOC build farm cluster

# apply resource changes
kubectl apply -k environments/moc

# check all resources have been deployed
kubectl get all -n okd-coreos

# run pipeline
kubectl create \
    -n okd-coreos \
    -f environments/moc/pipelineruns/okd-coreos-all-4.14-pipelinerun.yaml

# see the logs
tkn pipelinerun logs -f \
    -n okd-coreos \
    okd-coreos-all-4.14-pipelinerun-fooba

```
