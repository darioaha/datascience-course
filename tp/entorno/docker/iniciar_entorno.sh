#!/usr/bin/env bash

# export ENV="dev"
# export DIR_INSTALACION="/home/dalonso/dsg3/"
# export NOMBRE_RED="network_dsd3_${ENV}"
# export NOTEBOOKS_NAME="dsg3_${ENV}"
# export POSTGRES_NAME="pg_dsg3_${ENV}"
# export PG_PORT=54320


docker network create $NOMBRE_RED

docker run -d -it \
	-p 8888:8888 \
    	-v $DIR_INSTALACION:/home/DS-DH \
	--network $NOMBRE_RED \
	--cpu="2"
        --name $NOTEBOOKS_NAME dsdh/data 

docker run -d --rm \
	--network $NOMBRE_RED \
	--name $POSTGRES_NAME \
	-p $PG_PORT:5432 \
	-e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres \
	-v $HOME/docker/volumes/postgres:/var/lib/postgresql/data  postgres:9.6
