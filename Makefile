# Jenkins Master



build:
	docker build \
	-t prominentedgestatengine/jenkins:firecares-latest .

push:
	docker push prominentedgestatengine/jenkins:firecares-latest
