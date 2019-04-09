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
            libbz2-dev \
            libcurl4-gnutls-dev \
            libc6-dev \
            libgdbm-dev \
            libproj-dev \
            libsasl2-dev \
            libpng-dev \
            libmemcached-dev \
            zlib1g-dev \
            lsb-release \
            autoconf \
            libtool \
            python-opengl \
            python-imaging \
            python-pyrex \
            python-flake8 \
            python-pyside.qtopengl \
            idle-python2.7 \
            qt4-dev-tools \
            qt4-designer \
            libqtgui4 \
            libqtcore4 \
            libqt4-xml \
            libqt4-test \
            libqt4-script \
            libqt4-network \
            libqt4-dbus \
            python-qt4 \
            python-qt4-gl \
            libgle3 \
            pkgconf \
            software-properties-common \
            libreadline-gplv2-dev \
            libncursesw5-dev \
            libsqlite3-dev \
            libgit2-dev \
            tk-dev \
            jq

ENV RUNTIME_PACKAGES apt-transport-https \
            awscli \
            build-essential \
            docker-ce=17.03.1~ce-0~debian-stretch \
            file \
            libc6 \
            libffi-dev \
            libssl-dev \
            libxml2-dev \
            libxslt1-dev \
            postgresql \
            postgresql-contrib \
            python-dev \
            python2.7-dev \
            ruby \
            ruby-dev \
            rubygems-integration \
            unzip \
            zip \
            zlib1g-dev

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
             apt-transport-https \
             ca-certificates \
             curl \
             gnupg2 \
             software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && \
    add-apt-repository \
             "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
             $(lsb_release -cs) \
             stable" && \
    apt-get update

RUN apt-get update && \
    apt-get install -y --no-install-recommends $BUILD_PACKAGES && \
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

# Install the fastlane:
RUN gem install fastlane -NV

# NodeJS 8.x
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt install nodejs

# Bower stuff
RUN npm install -g bower

# Gulp stuff
RUN npm install --global gulp-cli

# Install Vault
RUN curl -O https://releases.hashicorp.com/vault/0.9.6/vault_0.9.6_linux_amd64.zip && \
    unzip vault_0.9.6_linux_amd64.zip && \
    mv vault /usr/local/bin && \
    chmod 755 /usr/local/bin/vault

# yarn stuff
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt update && \
    apt install -y  yarn

# apk stuff
ENV GRADLE_HOME /opt/gradle/gradle-4.10.2
ENV ANDROID_HOME /tmp/android-sdk-linux/
ENV PATH ${GRADLE_HOME}/bin:${PATH}:${ANDROID_HOME}platform-tools/:$ANDROID_HOME/../tools/bin/
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64/

RUN wget https://services.gradle.org/distributions/gradle-4.10.2-bin.zip -P /tmp && \
    unzip -d /opt/gradle /tmp/gradle-*.zip

COPY android-sdk.sh /tmp/android-sdk.sh

RUN chmod +x /tmp/android-sdk.sh

COPY sdk-tools-linux-4333796.zip /tmp/android-sdk-linux/

RUN cd /tmp/android-sdk-linux/ && \
    unzip sdk-tools-linux-4333796.zip

RUN cd /tmp && \
    ./android-sdk.sh

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
