import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:analyzer/dart/element/element.dart';

class AssetsGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    if (!inputId.path.endsWith(".assets.dart")) return null;

    final assetPathPatternElement =
        library.element.topLevelElements.firstWhere((e) {
      return e is PropertyAccessorElement &&
          e.variable.isConst &&
          e.returnType.isDartCoreString &&
          e.displayName == "assetPathPattern";
    }, orElse: () => null);

    final assetPathPattern =
        (assetPathPatternElement as PropertyAccessorElement)
                ?.variable
                ?.computeConstantValue()
                ?.toStringValue() ??
            "assets/**";

    var fileName = inputId.pathSegments.last.replaceAll(".assets.dart", "");
    fileName = fileName.replaceAll(".", "_");
    final classNameSb = StringBuffer();
    for (final segment in fileName.split("_")) {
      classNameSb.write(segment.substring(0, 1).toUpperCase());
      classNameSb.write(segment.substring(1));
    }
    final className = classNameSb.toString();

    final assets = await buildStep.findAssets(Glob(assetPathPattern)).toList();
    StringBuffer sb = StringBuffer();
    sb.writeln("static const package = \"${inputId.package}\";");
    sb.writeln();
    for (final asset in assets) {
      final lastSegment = asset.pathSegments.last;
      final name = lastSegment.substring(0, lastSegment.indexOf("."));
      final assetPath = asset.path;
      if (name.isNotEmpty) {
        sb.writeln("/// ![](${p.absolute(assetPath)})");
        sb.writeln("static const $name = \"${assetPath}\";");
        sb.writeln();
      }
    }

    final ignoreForFile = '// ignore_for_file:'
        'lines_longer_than_80_chars,'
        'constant_identifier_names';

    sb.write(ignoreForFile);

    return '''
      class ${className}Assets {
        ${sb.toString()}
      }
    ''';
  }
}
