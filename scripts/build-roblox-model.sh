#!/bin/sh

set -e

DARKLUA_CONFIG=$1
BUILD_OUTPUT=$2
SOURCEMAP=darklua-sourcemap.json
TEMP_DIR=temp

scripts/install-deps.sh

rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

cp -r src/ $TEMP_DIR/
cp -rL node_modules/ $TEMP_DIR/

cp "$DARKLUA_CONFIG" "$TEMP_DIR/$DARKLUA_CONFIG"
rojo sourcemap model.project.json -o $TEMP_DIR/$SOURCEMAP

cd $TEMP_DIR

darklua process --config "$DARKLUA_CONFIG" src src
darklua process --config "$DARKLUA_CONFIG" node_modules node_modules

cd ..

cp model.project.json $TEMP_DIR/

rm -f "$BUILD_OUTPUT"
mkdir -p $(dirname "$BUILD_OUTPUT")

rojo build $TEMP_DIR/model.project.json -o "$BUILD_OUTPUT"

rm -rf $TEMP_DIR