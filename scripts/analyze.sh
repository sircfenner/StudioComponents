#!/bin/sh

set -e

TYPES_FILE=globalTypes.d.lua

if [ ! -f "$TYPES_FILE" ]; then
    curl https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.lua > $TYPES_FILE
fi

luau-lsp analyze --base-luaurc=.luaurc --definitions=$TYPES_FILE src
