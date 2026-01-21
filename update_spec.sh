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
export LDFLAGS="-flto=thin -fuse-ld=lld"' $SPEC_FILE
fi

if ! grep -q "CLANG_RESOURCE_DIR" $SPEC_FILE; then
    sed -i '/^%build/a \
# Dynamically fix missing opencl-c-base.h for Clang multilib builds\
CLANG_RESOURCE_DIR=\$(clang -print-resource-dir 2>/dev/null || echo "")\
if [ -n "\$CLANG_RESOURCE_DIR" ]; then\
    OPENCL_HEADER=\$(find %{_libdir} -type f -name opencl-c-base.h 2>/dev/null | head -n1)\
    if [ -n "\$OPENCL_HEADER" ]; then\
        mkdir -p "\${CLANG_RESOURCE_DIR}/include"\
        ln -sf "\$OPENCL_HEADER" "\${CLANG_RESOURCE_DIR}/include/opencl-c-base.h"\
        echo "Fixed opencl-c-base.h by linking \$OPENCL_HEADER"\
    fi\
fi\
' $SPEC_FILE
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
