#!/bin/bash

# check if the docker container has been built if it hasn't build it

DB_NAME="village_dev"

# Check if the image exists and if not build it
image=$( docker images -q $DB_NAME )
if [[ -n "$image" ]]; then
    echo "Docker image tagged as $DB_NAME exists."
else
    echo "Docker image tagged as $DB_NAME does not exist. Building..."
    ./db/build.sh
fi

docker run -p 5432:5432 village_dev