#!/usr/bin/env bash

# export DB_PATH="/home/dalonso/dsg3/g3_unc_anonimo_negocio.sql"
# export POSTGRES_NAME="pg_dsg3_${ENV}"

docker exec -it $POSTGRES_NAME bash -c 'createdb -U postgres db_g3'
docker cp $DB_PATH $POSTGRES_NAME:/database.sql
docker exec -u postgres $POSTGRES_NAME psql 'dbname=db_g3 options=--search_path=db_g3' postgres -p 5432 -a -q -f database.sql


# 172.27.100.115 port 54320 database db_g3
# docker inspect -f '{{ json .Mounts }}' $POSTGRES_NAME | python -m json.tool
