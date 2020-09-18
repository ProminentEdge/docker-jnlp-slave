# Jenkins JNLP Slave


ORG ?= 508654928277.dkr.ecr.us-east-1.amazonaws.com
REPO ?= dds-jnlp
ENVIRONMENT ?= development

login:
	$$(aws ecr get-login --no-include-email --region us-east-1)

build:
	docker build --no-cache \
        --no-cache \
        --network=host \
	-t $(ORG)/$(REPO):dds-jnlp .

	echo "TAG=${TAG}" > tag.properties

push:
	docker push $(ORG)/$(REPO):dds-jnlp


