import 'dart:io' as io;

import 'package:assets_scanner/assets_scanner_builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _pkgName = 'pkg';

const _assetSrc = {
  '$_pkgName|assets/alarm.svg': '123',
  '$_pkgName|assets/arrows.svg': '456',
  '$_pkgName|lib/main.assets.dart': 'part "main.assets.g.dart";',
};

const _assetSubSrc = {
  '$_pkgName|assets/sub/alarm.svg': '123',
  '$_pkgName|assets/sub/arrows.svg': '456',
  '$_pkgName|lib/main.assets.dart': ''''
  part "main.assets.g.dart";

  const String assetPathPattern = "assets/sub/**";
  ''',
};

void main() {
  test("generate nothing without .assets.dart suffix", () async {
    final builder = assetsRootBuilder(BuilderOptions.empty);
    await testBuilder(builder, {
      '$_pkgName|lib/main.dart': '',
    }, outputs: {});
  });

  test("generate without assetPathPattern", () async {
    final dir = io.Directory.current.path;
    final pathAlarm = p.join(dir, 'assets/alarm.svg');
    final pathArrows = p.join(dir, 'assets/arrows.svg');
    final builder = assetsRootBuilder(BuilderOptions.empty);
    await testBuilder(builder, _assetSrc, generateFor: {
      '$_pkgName|lib/main.assets.dart'
    }, outputs: {
      '$_pkgName|lib/main.assets.generated.g.part': decodedMatches(endsWith(
          'class MainAssets {\n'
          '  static const package = "pkg";\n'
          '\n'
          '  /// ![]($pathAlarm)\n'
          '  static const alarm = "assets/alarm.svg";\n'
          '\n'
          '  /// ![]($pathArrows)\n'
          '  static const arrows = "assets/arrows.svg";\n'
          '\n'
          '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
          '}\n'
          '')),
    });
  });

  test("generate with assetPathPattern", () async {
    final dir = io.Directory.current.path;
    final pathAlarm = p.join(dir, 'assets/sub/alarm.svg');
    final pathArrows = p.join(dir, 'assets/sub/arrows.svg');
    final builder = assetsRootBuilder(BuilderOptions.empty);
    await testBuilder(builder, _assetSubSrc, generateFor: {
      '$_pkgName|lib/main.assets.dart'
    }, outputs: {
      '$_pkgName|lib/main.assets.generated.g.part': decodedMatches(endsWith(
          'class MainAssets {\n'
          '  static const package = "pkg";\n'
          '\n'
          '  /// ![]($pathAlarm)\n'
          '  static const alarm = "assets/sub/alarm.svg";\n'
          '\n'
          '  /// ![]($pathArrows)\n'
          '  static const arrows = "assets/sub/arrows.svg";\n'
          '\n'
          '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
          '}\n'
          '')),
    });
  });

  test("generate with file name custom.main.assets.dart", () async {
    final src = {
      '$_pkgName|assets/arrows.svg': '456',
      '$_pkgName|lib/custom.main.assets.dart':
          'part "custom.main.assets.g.dart";',
    };
    final builder = assetsRootBuilder(BuilderOptions.empty);
    await testBuilder(builder, src, generateFor: {
      '$_pkgName|lib/custom.main.assets.dart'
    }, outputs: {
      '$_pkgName|lib/custom.main.assets.generated.g.part':
          decodedMatches(contains('CustomMainAssets')),
    });
  });

  test("generate with file name custom_main.assets.dart", () async {
    final src = {
      '$_pkgName|assets/arrows.svg': '456',
      '$_pkgName|lib/custom_main.assets.dart':
          'part "custom_main.assets.g.dart";',
    };
    final builder = assetsRootBuilder(BuilderOptions.empty);
    await testBuilder(builder, src, generateFor: {
      '$_pkgName|lib/custom_main.assets.dart'
    }, outputs: {
      '$_pkgName|lib/custom_main.assets.generated.g.part':
          decodedMatches(contains('CustomMainAssets')),
    });
  });

  test("generate with isIgnoreComment", () async {
    final src = {
      '$_pkgName|assets/sub/alarm.svg': '123',
      '$_pkgName|assets/sub/arrows.svg': '456',
      '$_pkgName|lib/main.assets.dart': ''''
  part "main.assets.g.dart";

  const String assetPathPattern = "assets/sub/**";

  const bool isIgnoreComment = true;
  ''',
    };

    final builder = assetsRootBuilder(BuilderOptions.empty);
    await testBuilder(builder, src, generateFor: {
      '$_pkgName|lib/main.assets.dart'
    }, outputs: {
      '$_pkgName|lib/main.assets.generated.g.part': decodedMatches(endsWith(
          'class MainAssets {\n'
          '  static const package = "pkg";\n'
          '\n'
          '  static const alarm = "assets/sub/alarm.svg";\n'
          '\n'
          '  static const arrows = "assets/sub/arrows.svg";\n'
          '\n'
          '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
          '}\n'
          '')),
    });
  });
}
