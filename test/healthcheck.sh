#!/bin/sh
until [ "$(docker inspect -f {{.State.Health.Status}} nginx-test)"=="healthy" ]; do
    sleep 0.5;
done;

echo "Finished waiting for nginx-test to start"