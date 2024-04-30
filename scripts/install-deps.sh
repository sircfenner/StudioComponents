#!/bin/sh

set -e

if [ ! -d node_modules ]; then
    npm install
fi

if [ ! -d node_modules/.luau-aliases ]; then
    npm run prepare
fi