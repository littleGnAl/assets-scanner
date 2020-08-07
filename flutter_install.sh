#/bin/bash

echo "Installing Flutter SDK..."
cd /workspace && wget -qO flutter_sdk.tar.xz https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_v1.9.1+hotfix.4-stable.tar.xz && tar -xf flutter_sdk.tar.xz && rm -f flutter_sdk.tar.xz
      echo "Installing Android SDK..."
      mkdir -p /workspace/android-sdk && cd /workspace/android-sdk && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip -qq sdk-tools-linux-4333796.zip && rm -f sdk-tools-linux-4333796.zip
      echo y | /workspace/android-sdk/tools/bin/sdkmanager "platform-tools" "platforms;android-28" "build-tools;28.0.3"
      echo "Init Flutter..."
      flutter channel master
      flutter upgrade
      yes | flutter doctor --android-licenses
      cd /workspace/gitpod-flutter
      flutter pub get
      flutter config --enable-web
      flutter doctor