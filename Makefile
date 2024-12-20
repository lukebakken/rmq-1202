.PHONY: clean down up perms rmq-perms logs

DOCKER_FRESH ?= false
RABBITMQ_DOCKER_TAG ?= rabbitmq:3-management

clean: perms
	git clean -xffd

down:
	docker compose down
$(CURDIR)/tls-gen/basic/result/server_rmq0.local_certificate.pem:
	$(MAKE) -C $(CURDIR)/tls-gen/basic CN=rmq0.local gen
	cp -v $(CURDIR)/tls-gen/basic/result/ca_certificate.pem $(CURDIR)/rmq0
	cp -v $(CURDIR)/tls-gen/basic/result/*rmq0*.pem $(CURDIR)/rmq0
rmq0-cert: $(CURDIR)/tls-gen/basic/result/server_rmq0.local_certificate.pem

$(CURDIR)/tls-gen/basic/result/server_rmq1.local_certificate.pem:
	$(MAKE) -C $(CURDIR)/tls-gen/basic CN=rmq1.local gen-client gen-server
	cp -v $(CURDIR)/tls-gen/basic/result/ca_certificate.pem $(CURDIR)/rmq1
	cp -v $(CURDIR)/tls-gen/basic/result/*rmq1*.pem $(CURDIR)/rmq1
rmq1-cert: $(CURDIR)/tls-gen/basic/result/server_rmq1.local_certificate.pem

$(CURDIR)/tls-gen/basic/result/server_rmq2.local_certificate.pem:
	$(MAKE) -C $(CURDIR)/tls-gen/basic CN=rmq2.local gen-client gen-server
	cp -v $(CURDIR)/tls-gen/basic/result/ca_certificate.pem $(CURDIR)/rmq2
	cp -v $(CURDIR)/tls-gen/basic/result/*rmq2*.pem $(CURDIR)/rmq2
rmq2-cert: $(CURDIR)/tls-gen/basic/result/server_rmq2.local_certificate.pem

$(CURDIR)/tls-gen/basic/result/server_rmq0-us.local_certificate.pem:
	$(MAKE) -C $(CURDIR)/tls-gen/basic CN=rmq0-us.local gen-client gen-server
	cp -v $(CURDIR)/tls-gen/basic/result/ca_certificate.pem $(CURDIR)/rmq0-us
	cp -v $(CURDIR)/tls-gen/basic/result/*rmq0-us*.pem $(CURDIR)/rmq0-us
rmq0-us-cert: $(CURDIR)/tls-gen/basic/result/server_rmq0-us.local_certificate.pem

$(CURDIR)/tls-gen/basic/result/server_rmq1-us.local_certificate.pem:
	$(MAKE) -C $(CURDIR)/tls-gen/basic CN=rmq1-us.local gen-client gen-server
	cp -v $(CURDIR)/tls-gen/basic/result/ca_certificate.pem $(CURDIR)/rmq1-us
	cp -v $(CURDIR)/tls-gen/basic/result/*rmq1-us*.pem $(CURDIR)/rmq1-us
rmq1-us-cert: $(CURDIR)/tls-gen/basic/result/server_rmq1-us.local_certificate.pem

$(CURDIR)/tls-gen/basic/result/server_rmq2-us.local_certificate.pem:
	$(MAKE) -C $(CURDIR)/tls-gen/basic CN=rmq2-us.local gen-client gen-server
	cp -v $(CURDIR)/tls-gen/basic/result/ca_certificate.pem $(CURDIR)/rmq2-us
	cp -v $(CURDIR)/tls-gen/basic/result/*rmq2-us*.pem $(CURDIR)/rmq2-us
rmq2-us-cert: $(CURDIR)/tls-gen/basic/result/server_rmq2-us.local_certificate.pem

# NB: rmq0-cert MUST be first
certs: rmq0-cert rmq1-cert rmq2-cert rmq0-us-cert rmq1-us-cert rmq2-us-cert

up: certs rmq-perms
ifeq ($(DOCKER_FRESH),true)
	docker compose build --no-cache --pull --build-arg RABBITMQ_DOCKER_TAG=$(RABBITMQ_DOCKER_TAG)
	docker compose up --pull always --remove-orphans
else
	docker compose build --build-arg RABBITMQ_DOCKER_TAG=$(RABBITMQ_DOCKER_TAG)
	docker compose up --remove-orphans
endif

perms:
	sudo chown -R "$$(id -u):$$(id -g)" data log

rmq-perms:
	sudo chown -R '999:999' data log

logs:
	docker compose logs rmq0-us > $(CURDIR)/rmq0-us-docker.log
	docker compose logs rmq1-us > $(CURDIR)/rmq1-us-docker.log
	docker compose logs rmq2-us > $(CURDIR)/rmq2-us-docker.log
	docker compose logs rmq0 > $(CURDIR)/rmq0-docker.log
	docker compose logs rmq1 > $(CURDIR)/rmq1-docker.log
	docker compose logs rmq2 > $(CURDIR)/rmq2-docker.log
