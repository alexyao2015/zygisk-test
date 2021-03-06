ARG DEBUG_BUILD=0
FROM saschpe/android-ndk:32-jdk11.0.14.1_1-ndk23.1.7779620-cmake3.18.1 as zygisk-builder
ARG DEBUG_BUILD

RUN set -x \
    && apt-get update \
    && apt-get install -y build-essential

WORKDIR /buildroot

COPY zygisk .

WORKDIR /buildroot/module

RUN set -x \
    && $NDK_ROOT/ndk-build NDK_DEBUG=$DEBUG_BUILD \
    && mkdir bin \
    && mv libs/arm64-v8a/*.so bin/arm64-v8a.so \
    && mv libs/armeabi-v7a/*.so bin/armeabi-v7a.so \
    && mv libs/x86/*.so bin/x86.so \
    && mv libs/x86_64/*.so bin/x86_64.so

FROM alpine:latest
WORKDIR /build/module

# Create directory for installer
RUN set -x \
    && apk add \
        zip \
    && mkdir -p META-INF/com/google/android

COPY --from=zygisk-builder /buildroot/module/bin zygisk

COPY module .

# After copying so this gets run every time
RUN set -x \
    && wget -qO- https://raw.githubusercontent.com/topjohnwu/Magisk/master/scripts/module_installer.sh > META-INF/com/google/android/update-binary

RUN set -x \
    && zip -r9 ../module.zip .

CMD ["cp", "/build/module.zip", "/tmp/zygisk-latest.zip"]
