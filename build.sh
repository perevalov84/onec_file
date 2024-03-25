#/bin/bash

set -o errexit
set -o nounset
set -o pipefail

IMAGE=onec_file
RELEASE="8_3_23_2040" # Укажите вашу версию платформы 1с
CONTAINER=onec_file_container

docker buildx build -t $IMAGE:$RELEASE .
docker save -o $IMAGE"_"$RELEASE".tar" $IMAGE:$RELEASE

