#!/bin/sh
# Builds build/KeyGroups.app with swiftc (no Xcode project), signs it ad hoc, then runs the self-test.
# A local developer build: rebuild it when needed, and delete build/ after.
set -eu
cd "$(dirname "$0")"
rm -rf build
mkdir -p build/KeyGroups.app/Contents/MacOS
swiftc -O -o build/KeyGroups.app/Contents/MacOS/KeyGroups Sources/*.swift
cp Info.plist build/KeyGroups.app/Contents/
codesign --force --sign - build/KeyGroups.app
build/KeyGroups.app/Contents/MacOS/KeyGroups --selftest
echo "open $(pwd)/build/KeyGroups.app"
