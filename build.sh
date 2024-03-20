#/bin/bash

IMAGE=onec_file
RELEASE="8_3_22_1851"
CONTAINER=onec_file_container

docker stop $CONTAINER
docker build -t $IMAGE:$RELEASE .
docker save -o $IMAGE"_"$RELEASE".tar" $IMAGE:$RELEASE
docker rm $CONTAINER
docker run -p 8088:80 -v /home/salam4ik/work/bases:/infobases --name $CONTAINER -d $IMAGE:$RELEASE
