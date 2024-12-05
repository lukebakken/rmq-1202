#!/bin/sh

set -eux

for rmq in rmq0-us rmq1-us rmq2-us
do
    docker compose restart "$rmq"
    sleep 10
done

sleep 10

docker compose exec rmq0 rabbitmq-queues rebalance all
