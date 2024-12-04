#!/bin/sh

set -eux

docker compose exec rmq0 rabbitmq-queues rebalance all

sleep 10

for rmq in rmq0 rmq1
do
    docker compose exec "$rmq" rabbitmqctl stop_app
    docker compose exec "$rmq" rabbitmqctl reset
    docker compose exec "$rmq" rabbitmqctl start_app
done

sleep 10

docker compose exec rmq0 rabbitmq-queues rebalance all
