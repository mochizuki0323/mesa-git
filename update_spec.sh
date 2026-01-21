#!/bin/bash

PKG_DIR="mesa"

mkdir -p "$PKG_DIR"
cd "$PKG_DIR"

UPSTREAM_URL="https://raw.githubusercontent.com/vulturm/linux-graphics/master/fedora/mesa-git"
curl -O $UPSTREAM_URL/mesa.spec
curl -O $UPSTREAM_URL/Mesa-MLAA-License-Clarification-Email.txt

SPEC_FILE="mesa.spec"

sed -i 's/%bcond_with patented_video_codecs 0/%bcond_without patented_video_codecs/g' $SPEC_FILE

sed -i 's/.*-Dvideo-codecs=.*/  -Dvideo-codecs=all \\/g' $SPEC_FILE

echo "Success！"
