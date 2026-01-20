#!/bin/bash

PKG_DIR="mesa"

mkdir -p "$PKG_DIR"
cd "$PKG_DIR"

UPSTREAM_URL="https://raw.githubusercontent.com/vulturm/linux-graphics/master/fedora/mesa-git"
curl -O $UPSTREAM_URL/mesa.spec
curl -O $UPSTREAM_URL/Mesa-MLAA-License-Clarification-Email.txt

SPEC_FILE="mesa.spec"


sed -i 's/%bcond_with patented_video_codecs 0/%bcond_without patented_video_codecs/g' $SPEC_FILE

sed -i 's/%define _lto_cflags %{nil}/# %define _lto_cflags %{nil}/g' $SPEC_FILE

if ! grep -q "export CC=clang" $SPEC_FILE; then
    sed -i '/^%build/a \
export CC=clang \
export CXX=clang++ \
export AR=llvm-ar \
export NM=llvm-nm \
export RANLIB=llvm-ranlib \
export CFLAGS="-O3 -flto=thin -pipe" \
export CXXFLAGS="-O3 -flto=thin -pipe" \
export LDFLAGS="-flto=thin -fuse-ld=lld -Wl,--threads=1"' $SPEC_FILE
fi

if ! grep -q "\--optimization=3" $SPEC_FILE; then
    sed -i '/^%meson\([[:space:]\\]\|$\)/a \
  --optimization=3 \\\
  -Db_lto=true \\\
  -Db_lto_mode=thin \\' $SPEC_FILE
fi

sed -i 's/.*-Dvideo-codecs=.*/  -Dvideo-codecs=all \\/g' $SPEC_FILE

if ! grep -q "BuildRequires:  lld" $SPEC_FILE; then
    sed -i '/BuildRequires:  meson/a BuildRequires:  clang\nBuildRequires:  lld\nBuildRequires:  llvm-devel' $SPEC_FILE
fi


echo "Success！"
