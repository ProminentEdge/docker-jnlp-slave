# Jenkins Master



build:
	docker build \
	--no-cache \
	--network=host \
	-t prominentedgestatengine/jenkins:nfors-latest .

push:
	docker push prominentedgestatengine/jenkins:nfors-latest
