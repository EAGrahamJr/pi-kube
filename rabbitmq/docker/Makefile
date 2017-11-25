######################################################################################
# Make Rabbit MQ Docker image for Raspberry PI
#
# Requires REPO environment variable to be set for "tag" and "push" targets

IMAGE="rabbit"
VERSION="2"

# Rabbit
RVER="3.6.14"
DEB="rabbitmq-server_$(RVER)-1_all.deb"
MQ_URL="https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_14/$(DEB)"

# Autocluster plugins
AUTOVER="0.10.0"
AUTO_URL="https://github.com/rabbitmq/rabbitmq-autocluster/releases/download/$(AUTOVER)"
AUTO_FILE="autocluster-$(AUTOVER).ez"
AUTO_AWS="rabbitmq_aws-$(AUTOVER).ez"


clean:
	@-docker rmi -f $(shell docker images -q $(IMAGE))

really: clean
	@rm -rvf *.deb *.ez

# Main rabbit
download:
	@echo "Fetching .deb file for RabbitMQ"
	#echo $(MQ_URL)
	@curl -LOf $(MQ_URL)

plugins:
	@echo "Fetching autocluster plugin, version $AUTOVER"
	#@echo "$(AUTO_URL)/$(AUTO_FILE)"
	@curl -LOf $(AUTO_URL)/$(AUTO_FILE)

build: download plugins
	docker build -t $(IMAGE):$(VERSION) --build-arg RVER=$(RVER) --build-arg DEB=$(DEB) .

tag: build
	# Note: relies on env variable REPO
	@docker tag $(IMAGE):$(VERSION) $(REPO)/$(IMAGE):$(VERSION)

push: tag
	@docker push $(REPO)/$(IMAGE):$(VERSION)
