#!/bin/bash

rm -r _demo/apk/*
rm -r _demo/canvaskit/*
rm -r _demo/html/*
flutter clean

flutter build apk --split-per-abi
cp build/app/outputs/apk/release/app-* _demo/apk/

flutter build web --web-renderer canvaskit --base-href /swipe_overlays/canvaskit/
cp -r build/web/* _demo/canvaskit

flutter build web --web-renderer html --base-href /swipe_overlays/html/
cp -r build/web/* _demo/html

git add .
git commit -m "update demo"
git push origin main
git subtree push --prefix _demo origin gh-pages
