# The MIT License
#
#  Copyright (c) 2015, CloudBees, Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM jenkinsci/slave:3.27-1
LABEL maintainer=devops@prominentedge.com

USER root

COPY jenkins-slave /usr/local/bin/jenkins-slave

ENV BUILD_PACKAGES apt-transport-https \
            build-essential \
            ca-certificates \
            curl \
            lsb-release \
            python-pip \
            software-properties-common

ENV RUNTIME_PACKAGES apt-transport-https \
            awscli \
            build-essential \
            docker-ce=17.06.2~ce-0~ubuntu \
            elixir \
            esl-erlang \
            g++ \
            libproj-dev \
            nodejs \
            postgresql \
            postgresql-contrib \
            rsync \
            software-properties-common \
            vagrant \
            zip \
            ruby-dev
RUN echo "151.101.32.162 registry.npmjs.org" >> /etc/hosts

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends $BUILD_PACKAGES && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" && \
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    apt-get install -y $RUNTIME_PACKAGES

RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    apt-get update && \
    apt-get install -y ansible

RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.14.0/confd-0.14.0-linux-amd64 && \
    mv confd-0.14.0-linux-amd64 /usr/local/bin/confd && \
    wget -O packer.zip https://releases.hashicorp.com/packer/1.4.0/packer_1.4.0_linux_amd64.zip?_ga=2.243599746.608711644.1512069049-1880364814.1510687238 && \
    unzip packer.zip && \
    mv packer /usr/local/bin/packer && \
    chmod 755 /usr/local/bin/confd && \
    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz && \
    tar -xvzf helm-v2.9.1-linux-amd64.tar.gz && \
    chmod +x  linux-amd64/helm && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

RUN wget https://github.com/heptio/ark/releases/download/v0.7.0/ark-v0.7.0-linux-amd64.tar.gz && \
    tar -xvzf ark-v0.7.0-linux-amd64.tar.gz && \
    chmod +x ark && \
    mv ark /usr/local/bin/ark

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    pip install \
        elasticsearch-curator==5.4.0 \
        boto==2.48.0 \
        anchorecli

# Install Vault
RUN curl -O https://releases.hashicorp.com/vault/0.9.6/vault_0.9.6_linux_amd64.zip && \
    unzip vault_0.9.6_linux_amd64.zip && \
    mv vault /usr/local/bin && \
    chmod 755 /usr/local/bin/vault
    
# Install Ruby bundler
RUN gem install bundler
    
# Clean up
#RUN apt-get remove -y --purge $BUILD_PACKAGES $RUNTIME_PACKAGES && \
#    rm -rf /var/lib/apt/lists/*

# yarn stuff
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt update && \
    apt install -y  yarn

# apk stuff
ENV GRADLE_HOME /opt/gradle/gradle-4.10.2
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64/

RUN wget https://services.gradle.org/distributions/gradle-4.10.2-bin.zip -P /tmp && \
    unzip -d /opt/gradle /tmp/gradle-*.zip

# Siege installation:
RUN wget http://download.joedog.org/siege/siege-latest.tar.gz && \
    tar -zxvf siege-latest.tar.gz && \
    cd siege-*/ && \
    ./configure && \
    make && \
    make install && \
    siege.config

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    pip install \
        ansible==2.4 \
        elasticsearch-curator==5.4.0 \
        boto==2.48.0 \
        pyopenssl \
        urllib3 \
        ndg-httpsclient \
        pyasn1 \
        sh \
        tabulate \
        troposphere \
        pytz \
        python-dateutil

ENTRYPOINT ["jenkins-slave"]
