import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class _AssetsScannerOptions {
  const _AssetsScannerOptions._(
      {this.path = "lib", this.className = "R", this.ignoreComment = false});
  factory _AssetsScannerOptions() => _AssetsScannerOptions._();
  factory _AssetsScannerOptions.fromYamlMap(YamlMap map) {
    return _AssetsScannerOptions._(
        path: map["path"] ?? "lib",
        className: map["className"] ?? "R",
        ignoreComment: map["ignoreComment"] ?? false);
  }

  /// The path where the `r.dart` file locate. Note that the `path` should be
  /// sub-path of `lib/`.
  final String path;

  /// The class name of the `r.dart`.
  final String className;

  /// Indicate the comments need to be generated or not. Note that the you can't
  /// preview the images assets if `ignoreComment` is `true`.
  final bool ignoreComment;

  @override
  String toString() =>
      "_AssetsScannerOptions(path: $path, className: $className, ignoreComment: $ignoreComment)";
}

/// [AssetsBuilder] will get the assets path from `pubspec.yaml` and generate
/// a `r.dart` with `const` properties of assets path by default. You can custom
/// it by adding an `assets_scanner_options.yaml` file, and the supported key
/// is same with [_AssetsScannerOptions]'s properties name.
class AssetsBuilder extends Builder {
  @override
  Map<String, List<String>> get buildExtensions {
    final options = _getOptions();
    String extensions = 'r.dart';
    if (options.path != 'lib' && options.path.startsWith("lib/")) {
      extensions = options.path.replaceFirst("lib/", "") + "/" + extensions;
    }
    // TODO(littlegnal): It's so wired that this works, but the `buildExtensions` here not
    // match the `build_extensions` in the `build.yaml` file. Need more research see
    // if it's a correct way.
    return {
      r'$lib$': ["$extensions"]
    };
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final globList = await _createAssetsGlobListPubspec(buildStep);
    if (globList.isEmpty) return;

    final options = _getOptions();
    if (!options.path.startsWith('lib')) {
      log.severe(
          "The custom path in assets_scanner_options.yaml should be sub-path of lib/.");
      return;
    }
    final rContent = StringBuffer();

    final assetsList = await _getAssetsList(buildStep, globList);
    for (final asset in assetsList) {
      final assetPath = asset.path;
      // Ignore the parent path to make the property name shorter.
      final propertyName = assetPath
          .substring(assetPath.indexOf("/") + 1, assetPath.indexOf("."))
          .replaceAll('/', '_');
      if (propertyName.isNotEmpty) {
        if (!options.ignoreComment) {
          rContent.writeln("  /// ![](${p.absolute(assetPath)})");
        }
        rContent.writeln("  static const $propertyName = \"${assetPath}\";");
        rContent.writeln();
      }
    }

    final ignoreForFile = '// ignore_for_file:'
        'lines_longer_than_80_chars,'
        'constant_identifier_names';

    rContent.write(ignoreForFile);

    final rClass = '/// GENERATED BY assets_scanner. DO NOT MODIFY.\n'
        '/// See more detail on https://github.com/littleGnAl/assets-scanner.\n'
        'class ${options.className} {\n'
        '  static const package = "${buildStep.inputId.package}";\n\n'
        '${rContent.toString()}\n'
        '}\n';

    final dir = options.path.startsWith('lib') ? options.path : 'lib';
    final output = AssetId(buildStep.inputId.package, p.join(dir, "r.dart"));
    await buildStep.writeAsString(output, rClass);
  }

  /// Get `assets` value from `pubspec.yaml` file.
  Future<List<Glob>> _createAssetsGlobListPubspec(BuildStep buildStep) async {
    final pubspecAssetId = AssetId(buildStep.inputId.package, 'pubspec.yaml');
    final pubspecContent = await buildStep.readAsString(pubspecAssetId);
    final pubspecMap = loadYaml(pubspecContent);

    List<Glob> globList = [];
    if (pubspecMap is YamlMap && pubspecMap.containsKey("flutter")) {
      final flutterMap = pubspecMap["flutter"];
      if (flutterMap is YamlMap && flutterMap.containsKey("assets")) {
        YamlList assetsList = flutterMap["assets"];
        for (final asset in assetsList.toSet()) {
          if (asset.endsWith("/")) {
            globList.add(Glob("$asset*"));
          } else {
            globList.add(Glob(asset));
          }
        }
      }
    }

    return globList;
  }

  Future<List<AssetId>> _getAssetsList(
      BuildStep buildStep, List<Glob> globList) async {
    // It's valid that set the same asset path multiple times in pubspec.yaml,
    // so the assets can be duplicate, use `Set` here to filter the same asset path.
    Set<AssetId> assetsSet = {};
    // On iOS it will create a .DS_Store file in assets folder, so use
    // the regular expression to match the valid assets path.
    final rexp = RegExp(r'^([a-zA-Z0-9]+\/)*([a-zA-Z0-9]+.)+\.[a-z]+');
    for (final glob in globList) {
      final assets = await buildStep.findAssets(glob).toList();
      assetsSet.addAll(assets.where((e) => rexp.hasMatch(e.path)));
    }

    return assetsSet.toList();
  }

  /// Create [_AssetsScannerOptions] from `assets_scanner_options.yaml` file
  _AssetsScannerOptions _getOptions() {
    final optionsFile = File("assets_scanner_options.yaml");
    if (optionsFile.existsSync()) {
      final optionsContent = optionsFile.readAsStringSync();
      if (optionsContent?.isNotEmpty ?? false) {
        return _AssetsScannerOptions.fromYamlMap(loadYaml(optionsContent));
      }
    }

    return _AssetsScannerOptions();
  }
}