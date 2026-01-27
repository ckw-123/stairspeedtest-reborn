#!/bin/bash
mkdir "$USERPROFILE/maindeps"
cd "$USERPROFILE/maindeps"
set -xe

if [ ! -d curl/ ]; then
    git clone https://github.com/curl/curl \
        --branch curl-8_18_0 \
        --depth 1 \
        --single-branch
fi

cd curl
git pull --ff-only
cmake -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_CURL_EXE=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX="$MINGW_PREFIX" \
    -DCURL_BROTLI=OFF \
    -DCURL_USE_LIBPSL=OFF \
    -DCURL_USE_LIBSSH2=OFF \
#    -DCURL_USE_OPENSSL=ON
#    -DCURL_USE_SCHANNEL=OFF
    -DCURL_USE_SCHANNEL=ON \
    -DCURL_ZLIB=OFF \
    -DCURL_ZSTD=OFF \
    -DHTTP_ONLY=ON \
    -DUSE_LIBIDN2=OFF \
    -DUSE_NGHTTP2=OFF \
    -G "Unix Makefiles" \
    .
make install -j4
cd ..

if [ ! -d yaml-cpp/ ]; then git clone https://github.com/jbeder/yaml-cpp --depth=1; fi
cd yaml-cpp
git pull --ff-only
cmake -DCMAKE_BUILD_TYPE=Release -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DCMAKE_INSTALL_PREFIX="$MINGW_PREFIX" -G "Unix Makefiles" .
make install -j4
cd ..

if [ ! -d rapidjson/ ]; then git clone https://github.com/Tencent/rapidjson --depth=1; fi
cd rapidjson
git pull --ff-only
cmake -DRAPIDJSON_BUILD_DOC=OFF -DRAPIDJSON_BUILD_EXAMPLES=OFF -DRAPIDJSON_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX="$MINGW_PREFIX" -G "Unix Makefiles" .
make install -j4
cd ..

if [ ! -d pngwriter/ ]; then git clone https://github.com/pngwriter/pngwriter --depth=1; fi
cd pngwriter
git pull --ff-only
cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_INSTALL_PREFIX="$MINGW_PREFIX" -G "Unix Makefiles" .
make install -j4
cd ..

set +xe
