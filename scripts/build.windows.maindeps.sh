#!/bin/bash
mkdir "$USERPROFILE/maindeps"
cd "$USERPROFILE/maindeps"
set -xe

git clone --branch curl-8_18_0 --single-branch --depth 1 https://github.com/curl/curl
cd curl
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS_RELEASE="$C_FLAGS" \
    -DBUILD_CURL_EXE=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_INSTALL_PREFIX="$MINGW_PREFIX" \
    -DCURL_BROTLI=OFF \
    -DCURL_USE_LIBPSL=OFF \
    -DCURL_USE_LIBSSH2=OFF \
    -DCURL_USE_SCHANNEL=ON \
    -DCURL_ZLIB=OFF \
    -DCURL_ZSTD=OFF \
    -DHTTP_ONLY=ON \
    -DUSE_LIBIDN2=OFF \
    -DUSE_NGHTTP2=OFF \
    -G "Unix Makefiles" \
    -DENABLE_UNICODE=OFF \
    -DENABLE_IPV6=OFF \
    -DCURL_DISABLE_DICT=ON \
    -DCURL_DISABLE_GOPHER=ON \
    -DCURL_DISABLE_TELNET=ON \
    -DCURL_DISABLE_TFTP=ON \
    -DCURL_DISABLE_IMAP=ON \
    -DCURL_DISABLE_POP3=ON \
    -DCURL_DISABLE_SMTP=ON \
    -DCURL_DISABLE_LDAP=ON \
    -DCURL_DISABLE_RTSP=ON \
    -DENABLE_UNIX_SOCKETS=OFF \
    -DCURL_DISABLE_ALTSVC=ON \
    -DCURL_DISABLE_AWS=ON \
    -DCURL_DISABLE_COOKIES=ON \
    -DCURL_DISABLE_DIGEST_AUTH=ON \
    -DCURL_DISABLE_DOH=OFF \
    -DCURL_DISABLE_FORM_API=ON \
    -DCURL_DISABLE_HSTS=ON \
    -DCURL_DISABLE_KERBEROS_AUTH=ON \
    -DCURL_DISABLE_MIME=ON \
    -DCURL_DISABLE_NEGOTIATE_AUTH=ON \
    -DCURL_DISABLE_NETRC=ON \
    -DCURL_DISABLE_NTLM=ON \
    -DCURL_DISABLE_OPENSSL_AUTO_LOAD_CONFIG=ON \
    -DCURL_DISABLE_PARSEDATE=ON \
    -DCURL_DISABLE_PROGRESS_METER=ON \
    -DCURL_DISABLE_SHUFFLE_DNS=ON \
    -DCURL_DISABLE_SOCKETPAIR=ON \
    -DCURL_DISABLE_VERBOSE_STRINGS=ON \
    -DCURL_DISABLE_WEBSOCKETS=ON \
    .

make VERBOSE=1 install -j
cd ..

git clone --depth 1 https://github.com/jbeder/yaml-cpp
cd yaml-cpp
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS_RELEASE="$CXX_FLAGS" \
    -DCMAKE_INSTALL_PREFIX="$MINGW_PREFIX" \
    -G "Unix Makefiles" \
    -DBUILD_TESTING=OFF \
    -DYAML_CPP_BUILD_CONTRIB=OFF \
    -DYAML_CPP_BUILD_TOOLS=OFF \
    -DYAML_ENABLE_PIC=OFF \
    .

make VERBOSE=1 install -j
cd ..

git clone --depth 1 https://github.com/Tencent/rapidjson
cd rapidjson
cmake \
    -DCMAKE_INSTALL_PREFIX="$MINGW_PREFIX" \
    -G "Unix Makefiles" \
    -DBUILD_TESTING=OFF \
    -DRAPIDJSON_BUILD_DOC=OFF \
    -DRAPIDJSON_BUILD_EXAMPLES=OFF \
    -DRAPIDJSON_BUILD_TESTS=OFF \
    -DRAPIDJSON_ENABLE_INSTRUMENTATION_OPT=OFF \
    .

make VERBOSE=1 install -j
cd ..

git clone --branch dev --single-branch --depth 1 https://github.com/pngwriter/pngwriter
cd pngwriter
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS_RELEASE="$CXX_FLAGS" \
    -DCMAKE_INSTALL_PREFIX="$MINGW_PREFIX" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -G "Unix Makefiles" \
    .

make VERBOSE=1 install -j
cd ..

set +xe
