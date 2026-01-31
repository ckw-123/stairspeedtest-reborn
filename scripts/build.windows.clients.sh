#!/bin/bash
mkdir "$USERPROFILE/clients"
mkdir "$USERPROFILE/clients/built"
cd "$USERPROFILE/clients"
set -xe

git clone --branch v2.28.10 --depth 1 https://github.com/Mbed-TLS/mbedtls
cd mbedtls
cmake \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS_RELEASE="$C_FLAGS" \
    -DENABLE_PROGRAMS=OFF \
    -DENABLE_TESTING=OFF \
    -DMBEDTLS_FATAL_WARNINGS=OFF \
    -DCMAKE_INSTALL_PREFIX="$MINGW_PREFIX" \
    -G "Unix Makefiles" \
    .

make VERBOSE=1 install -j
cd ..

curl -LO https://github.com/shadowsocks/libev/archive/mingw.tar.gz
tar xvf mingw.tar.gz
cd libev-mingw
mkdir build
CFLAGS="$C_FLAGS -Wno-error=incompatible-pointer-types -Wno-error=int-conversion" \
./configure \
    --disable-silent-rules \
    --disable-shared \
    --enable-static \
    --prefix="$PWD/build"
  
make install -j
cd ..

export LIBEV_PATH="$PWD/libev-mingw/build"

git clone --depth 1 https://github.com/shadowsocks/simple-obfs
cd simple-obfs
git submodule update --init --depth 1
./autogen.sh
CFLAGS="$C_FLAGS -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-error=implicit-function-declaration" \
./configure \
    --disable-assert \
    --disable-documentation \
    --disable-shared \
    --disable-silent-rules \
    --disable-ssp \
    --enable-static \
    --with-ev="$LIBEV_PATH"

make -j

gcc $LD_FLAGS $(find src/ -name "obfs_local-*.o") $(find . -name "*.a" ! -name "*.dll.a") "$LIBEV_PATH/lib/libev.a" -o simple-obfs -static -lws2_32
mv simple-obfs.exe ../built/
cd ..

git clone --filter=blob:none https://github.com/shadowsocks/shadowsocks-libev
cd shadowsocks-libev
git checkout --detach c2fc967
git submodule update --init --recursive
./autogen.sh
CFLAGS="$C_FLAGS" \
./configure \
        --disable-assert \
        --disable-connmarktos \
        --disable-documentation \
        --disable-nftables \
        --disable-shared \
        --disable-silent-rules \
        --disable-ssp \
        --enable-static \
        --with-ev="$LIBEV_PATH"

# fix codes
sed -i "s/%I/%z/g" src/utils.h
make -j
gcc $LD_FLAGS $(find src/ -name "ss_local-*.o") $(find . -name "*.a" ! -name "*.dll.a") "$LIBEV_PATH/lib/libev.a" -o ss-local -static -lws2_32 -lsodium -lmbedtls -lmbedcrypto -lpcre
mv ss-local.exe ../built/
cd ..

git clone --branch Akkariiin/develop --single-branch --depth 1 https://github.com/shadowsocksrr/shadowsocksr-libev
cd shadowsocksr-libev

# build ahead to reconfigure
cd libudns
CFLAGS="$C_FLAGS" \
./configure \
    --disable-assert \
    --disable-silent-rules \
    --disable-shared \
    --enable-static
make -j
cd ..

CFLAGS="$C_FLAGS -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-error=implicit-function-declaration" \
./configure \
    --disable-assert \
    --disable-documentation \
    --disable-shared \
    --disable-silent-rules \
    --disable-ssp \
    --disable-zlib \
    --enable-static

# fix codes
sed -i "s/^const/extern const/g" src/tls.h
sed -i "s/^const/extern const/g" src/http.h
make -j

gcc $LD_FLAGS $(find src/ -name "ss_local-*.o") $(find . -name "*.a" ! -name "*.dll.a") "$LIBEV_PATH/lib/libev.a" -o ssr-local -static -lpcre -lssl -lcrypto -lws2_32 -lcrypt32
mv ssr-local.exe ../built/
cd ..

git clone --branch dev --single-branch --depth 1 https://github.com/trojan-gfw/trojan
cd trojan
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS_RELEASE="$CXX_FLAGS -fno-exceptions" \
    -DENABLE_MYSQL=OFF \
    -DENABLE_NAT=OFF \
    -DENABLE_REUSE_PORT=OFF \
    -DENABLE_SSL_KEYLOG=OFF \
    -DSYSTEMD_SERVICE=OFF \
    -G "Unix Makefiles" \
    .

make VERBOSE=1 -j
g++ $LD_FLAGS -o trojan $(find CMakeFiles/trojan.dir/src/ -name "*.obj") -static -lssl -lcrypto -lws2_32 -lwsock32 -lboost_program_options-mt -lcrypt32  -lsecur32 -lshlwapi -lbcrypt
mv trojan.exe ../built/
cd ..

curl -LO https://github.com/v2fly/v2ray-core/releases/download/v4.45.2/v2ray-windows-64.zip
curl -LO https://github.com/joewalnes/websocketd/releases/download/v0.4.1/websocketd-0.4.1-windows_amd64.zip
curl -LO https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-windows-amd64-v1.3.2.tar.gz

curl -LO https://github.com/shadowsocks/shadowsocks-windows/releases/download/4.4.1.0/Shadowsocks-4.4.1.0.zip
unzip Shadowsocks-4.4.1.0.zip Shadowsocks.exe
mv Shadowsocks.exe built/shadowsocks-win.exe

curl -LO https://github.com/shadowsocksrr/shadowsocksr-csharp/releases/download/4.9.2/ShadowsocksR-win-4.9.2.zip
7z x ShadowsocksR-win-4.9.2.zip ShadowsocksR-win-4.9.2/ShadowsocksR-dotnet2.0.exe
mv ShadowsocksR-win-4.9.2/ShadowsocksR-dotnet2.0.exe built/shadowsocksr-win.exe

unzip v2ray*.zip v2ray.exe v2ctl.exe
unzip websocketd*.zip websocketd.exe
tar xvf v2ray-plugin*.gz
rm v2ray-plugin*.gz
mv v2ray-plugin* built/v2ray-plugin.exe
mv v2ray.exe v2ctl.exe built/
mv websocketd.exe built/websocketd.exe

set +xe
