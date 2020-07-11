## 1.1.0+1
Support [package assets](https://flutter.dev/docs/development/ui/assets-and-images#bundling-of-package-assets). 

## 1.0.1
Fix the generated content not respect the directory behavior of assets, that describe on https://flutter.dev/docs/development/ui/assets-and-images#specifying-assets

> Note: Only files located directly in the directory are included. To add files located in subdirectories, create an entry per directory.

## 1.0.0
Refactor the assets_scanner to generate the `r.dart` file, and custom it by adding `assets_scanner_options.yaml` file, see more detail from `README.md`.

## 0.0.2
Allow not generate comment for asset path by setting `const bool isIgnoreComment = true;`

## 0.0.1
Release 0.0.1
