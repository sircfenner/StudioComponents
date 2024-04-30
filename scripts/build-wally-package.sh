#!/bin/sh

set -e

TEMP_DIR=temp
WALLY_PACKAGE=build/wally

scripts/install-deps.sh

rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

cp -r src $TEMP_DIR/src
rm -rf $WALLY_PACKAGE

mkdir -p $WALLY_PACKAGE
cp LICENSE $WALLY_PACKAGE/LICENSE

node ./scripts/npm-to-wally.js package.json $WALLY_PACKAGE/wally.toml $WALLY_PACKAGE/default.project.json $TEMP_DIR/wally-package.project.json

cp .darklua-wally.json $TEMP_DIR
cp -r node_modules/.luau-aliases/* $TEMP_DIR

rojo sourcemap $TEMP_DIR/wally-package.project.json --output $TEMP_DIR/sourcemap.json

darklua process --config $TEMP_DIR/.darklua-wally.json $TEMP_DIR/src $WALLY_PACKAGE/src

rm -rf $TEMP_DIR

wally package --project-path $WALLY_PACKAGE --list