#!/bin/sh

set -e

scripts/build-roblox-model.sh .darklua.json build/studiocomponents.rbxm
scripts/build-wally-package.sh
