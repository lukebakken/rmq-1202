#!/bin/sh

set -eux

for rmq in rmq0 rmq1 rmq2
do
    docker compose restart "$rmq"
    sleep 10
done

sleep 10

docker compose exec rmq0 rabbitmq-queues rebalance all
