#!/bin/bash

# Thanks to https://gist.github.com/wenzhixin/43cf3ce909c24948c6e7
# Execute this script in your home directory. Lines 17 and 21 will prompt you for a y/n

# Install Oracle JDK 8
add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install -y oracle-java8-installer
apt-get install -y make # NDK stuff

# Get SDK tools (link from https://developer.android.com/studio/index.html#downloads)
wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
tar xf android-sdk*-linux.tgz

# Get NDK (https://developer.android.com/ndk/downloads/index.html)
wget https://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip
uznip android-ndk*.zip

apt-get install -y android-sdk \
                   android-sdk-platform-23 \
                   libgradle-android-plugin-java \
                   maven

# Let it update itself and install some stuff
#cd android-sdk-linux/tools
#./android update sdk --no-ui

# Download every build-tools version that has ever existed
# This will save you time! Thank me later for this
#./android update sdk --all --no-ui --filter $(seq -s, 27)

# If you need additional packages for your app, check available packages with:
# ./android list sdk --all

# install certain packages with:
# ./android update sdk --no-ui --all --filter 1,2,3,<...>,N
# where N is the number of the package in the list (see previous command)


# Add the directory containing executables in PATH so that they can be found
echo 'export ANDROID_HOME=$HOME/android-sdk-linux' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.bashrc

source ~/.bashrc

# Make sure you can execute 32 bit executables if this is 64 bit machine, otherwise skip this
dpkg --add-architecture i386
apt-get update
apt-get install -y libc6:i386 libstdc++6:i386 zlib1g:i386

# Add some swap space, useful if you've got less than 2G of RAM
fallocate -l 2G /swapfile 
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Optionally run build system as daemon (speeds up build process)
mkdir ~/.gradle
echo 'org.gradle.daemon=true' >> ~/.gradle/gradle.properties
# See here: https://www.timroes.de/2013/09/12/speed-up-gradle/

yes | /tmp/tools/bin/sdkmanager --licenses

/tmp/tools/bin/sdkmanager "platforms;android-27"
/tmp/tools/bin/sdkmanager "build-tools;27.0.3"

