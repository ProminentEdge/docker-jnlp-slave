# Jenkins Master



build:
	docker build --no-cache \
	-t prominentedgestatengine/jenkins:jnlp-slave-4.3-1-ruby .

push:
	docker push prominentedgestatengine/jenkins:jnlp-slave-4.3-1-ruby
