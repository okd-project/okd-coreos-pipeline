#!/bin/bash
#

set -o pipefail

if [ "$#" -lt 3 ]
then
  echo " "
  echo -e "\033[0;95musage   execute-pipelinerun.sh <operate-first|local> <ocp-version> <all|build>>\033[0m"
  echo -e "\033[0;93mexample execute-pipelinerun.sh local 4.13 all\033[0m"
  echo " "
  exit 1
fi


echo -e "\033[0;96mensure your are logged into the $1 cluster\033[0m"

cat << EOF > environments/overlays/local/pipelineruns/patches/patch-version.yaml
- op: replace
  path: "/spec/params/3/value"
  value:
    "$2"

- op: replace
  path: "/spec/params/4/value"
  value:
    "registry.ci.openshift.org/origin/$2:artifacts"
EOF

echo -e "\033[0;95mdeploying to $1 with version $2 using the $3 pipelinerun file\033[0m"
echo " "

if [ "$3" == "build" ];
then
    kustomize build environments/overlays/$1/pipelineruns/ | csplit - '/---$/' && cat xx01 | awk FNR!=1 | kubectl apply -f -
else
    kustomize build environments/overlays/$1/pipelineruns/ | csplit - '/---$/' && cat xx00 | kubectl apply -f - 
fi

