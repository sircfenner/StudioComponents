#!/bin/sh

set -e

DARKLUA_CONFIG=.darklua.json
SOURCEMAP=darklua-sourcemap.json
SERVE_DIR=serve

scripts/install-deps.sh

rm -f $SOURCEMAP
rm -rf $SERVE_DIR
mkdir -p $SERVE_DIR

cp model.project.json $SERVE_DIR/model.project.json
cp serve.project.json $SERVE_DIR/serve.project.json
cp -r src $SERVE_DIR/src
cp -rL node_modules $SERVE_DIR/node_modules

rojo sourcemap model.project.json -o $SOURCEMAP
#darklua process --config $DARKLUA_CONFIG src $SERVE_DIR/src
#darklua process --config $DARKLUA_CONFIG node_modules $SERVE_DIR/node_modules

rojo sourcemap --watch model.project.json -o $SOURCEMAP &
darklua process -w --config $DARKLUA_CONFIG src $SERVE_DIR/src &
darklua process -w --config $DARKLUA_CONFIG node_modules $SERVE_DIR/node_modules &

rojo serve $SERVE_DIR/serve.project.json
