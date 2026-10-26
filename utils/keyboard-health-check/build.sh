#!/bin/sh
# Builds build/KeyboardHealthCheck.app with swiftc (no Xcode project) and signs it ad hoc.
# A local developer build: rebuild it when needed, and delete it after.
set -eu
cd "$(dirname "$0")"
rm -rf build
mkdir -p build/KeyboardHealthCheck.app/Contents/MacOS
swiftc -O -o build/KeyboardHealthCheck.app/Contents/MacOS/KeyboardHealthCheck Sources/*.swift
cp Info.plist build/KeyboardHealthCheck.app/Contents/
codesign --force --sign - build/KeyboardHealthCheck.app
build/KeyboardHealthCheck.app/Contents/MacOS/KeyboardHealthCheck --selftest
echo "open $(pwd)/build/KeyboardHealthCheck.app"
