# Jenkins Master



build:
	docker build \
	--no-cache \
	-t prominentedgestatengine/jenkins:firecares-latest .

push:
	docker push prominentedgestatengine/jenkins:firecares-latest
