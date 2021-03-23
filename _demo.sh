#!/bin/bash

flutter clean
flutter build web --web-renderer canvaskit --release
#flutter build web --web-renderer html --release

rm -r _demo/*
cp -r build/web/* _demo/

sed -i 's|\="/"|\="/swipe_overlays/"|' _demo/index.html

# git subtree push --prefix _demo origin gh-pages
