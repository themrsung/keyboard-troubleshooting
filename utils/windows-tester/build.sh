#!/bin/sh
# Builds build/WindowsTester.app with swiftc (no Xcode project) and signs it ad hoc.
# A local developer build: rebuild it when needed, and delete it after.
set -eu
cd "$(dirname "$0")"
rm -rf build
mkdir -p build/WindowsTester.app/Contents/MacOS
swiftc -O -o build/WindowsTester.app/Contents/MacOS/WindowsTester Sources/*.swift
cp Info.plist build/WindowsTester.app/Contents/
codesign --force --sign - build/WindowsTester.app
build/WindowsTester.app/Contents/MacOS/WindowsTester --selftest
echo "open $(pwd)/build/WindowsTester.app"
