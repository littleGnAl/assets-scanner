FROM gitpod/workspace-full-vnc

ENV ANDROID_HOME=/workspace/android-sdk \
    FLUTTER_ROOT=/workspace/flutter \
    FLUTTER_HOME=/workspace/flutter

USER root


# Install Xvfb, JavaFX-helpers and Openbox window manager
RUN apt-get update \
    && apt-get install -yq xvfb x11vnc xterm openjfx libopenjfx-java openbox \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# overwrite this env variable to use a different window manager
ENV WINDOW_MANAGER="openbox"


RUN apt-get update && \
    apt-get -y install build-essential libkrb5-dev gcc make gradle openjdk-8-jdk && \
    apt-get clean && \
    apt-get -y autoremove


RUN cd /workspace && wget -qO flutter_sdk.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.20.1-stable.tar.xz && tar -xf flutter_sdk.tar.xz && rm -f flutter_sdk.tar.xz
RUN      echo "Installing Android SDK..."
RUN       mkdir -p /workspace/android-sdk && cd /workspace/android-sdk && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip -qq sdk-tools-linux-4333796.zip && rm -f sdk-tools-linux-4333796.zip
RUN       echo y | /workspace/android-sdk/tools/bin/sdkmanager "platform-tools" "platforms;android-28" "build-tools;28.0.3"

RUN       echo "git clean"
RUN       cd /workspace/flutter
RUN       git clean  -d  -f .

RUN       echo "Init Flutter..."
RUN       flutter channel master
RUN       flutter upgrade
RUN       yes | flutter doctor --android-licenses
RUN       cd /workspace/gitpod-flutter
RUN       flutter pub get
RUN       flutter config --enable-web
RUN       flutter doctor
