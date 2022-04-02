#!/bin/bash

set -euox pipefail

build_mode="${1:-release}"

cd /workspaces/zygisk-test/zygisk/module

debug_mode=1
if [[ "$build_mode" == "release" ]]; then
    debug_mode=0
fi
$NDK_ROOT/ndk-build NDK_DEBUG=$debug_mode

cd /workspaces/zygisk-test

mkdir -p bin
mv zygisk/module/libs/arm64-v8a/*.so bin/arm64-v8a.so \
    && mv zygisk/module/libs/armeabi-v7a/*.so bin/armeabi-v7a.so \
    && mv zygisk/module/libs/x86/*.so bin/x86.so \
    && mv zygisk/module/libs/x86_64/*.so bin/x86_64.so

rm -rf .tmp
mkdir -p .tmp
mv bin .tmp/zygisk
cp -r module/* .tmp

cd .tmp

mkdir -p META-INF/com/google/android
wget -qO- https://raw.githubusercontent.com/topjohnwu/Magisk/master/scripts/module_installer.sh > META-INF/com/google/android/update-binary

rm ../module.zip
zip -r9 ../module.zip .

# docker build -t builder .
# docker run -v ${PWD}:/tmp
