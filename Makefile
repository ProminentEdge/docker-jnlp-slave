# Jenkins Master



build:
	docker build \
	--no-cache \
	--network=host \
	-t prominentedgestatengine/jenkins:gdal-latest .

push:
	docker push prominentedgestatengine/jenkins:gdal-latest
