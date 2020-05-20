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
            libcurl4-gnutls-dev \
            libproj-dev \
            lsb-release \
            software-properties-common

ENV RUNTIME_PACKAGES apt-transport-https \
            awscli \
            docker-ce=17.03.1~ce-0~ubuntu-xenial \
            elixir \
            esl-erlang \
            libproj-dev \
            libc6 \
            postgresql \
            postgresql-contrib \
            rsync \
            vagrant \
            zip

RUN apt-get update && \
    apt-get install -y --no-install-recommends $BUILD_PACKAGES && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" && \
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    wget http://download.osgeo.org/gdal/2.2.2/gdal-2.2.2.tar.gz && \
    tar -xvf gdal-2.2.2.tar.gz && \
    cd gdal-2.2.2 && \
    ./configure --with-curl=/usr/bin/curl-config --with-pg && \
    make && \
    make install && \
    apt-get update && \
    apt-get install -y $RUNTIME_PACKAGES

RUN wget https://github.com/heptio/ark/releases/download/v0.7.0/ark-v0.7.0-linux-amd64.tar.gz && \
    tar -xvzf ark-v0.7.0-linux-amd64.tar.gz && \
    chmod +x ark && \
    mv ark /usr/local/bin/ark

RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.14.0/confd-0.14.0-linux-amd64 && \
    mv confd-0.14.0-linux-amd64 /usr/local/bin/confd && \
    wget -O packer.zip https://releases.hashicorp.com/packer/1.1.2/packer_1.1.2_linux_amd64.zip?_ga=2.243599746.608711644.1512069049-1880364814.1510687238 && \
    unzip packer.zip && \
    mv packer /usr/local/bin/packer && \
    chmod 755 /usr/local/bin/confd && \
    wget https://storage.googleapis.com/kubernetes-helm/helm-v2.7.2-linux-amd64.tar.gz && \
    tar -xvzf helm-v2.7.2-linux-amd64.tar.gz && \
    chmod +x  linux-amd64/helm && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install Vault
RUN curl -O https://releases.hashicorp.com/vault/0.9.6/vault_0.9.6_linux_amd64.zip && \
    unzip vault_0.9.6_linux_amd64.zip && \
    mv vault /usr/local/bin && \
    chmod 755 /usr/local/bin/vault

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    pip install \
        elasticsearch-curator==5.4.0 \
        boto==2.48.0

ENTRYPOINT ["jenkins-slave"]
