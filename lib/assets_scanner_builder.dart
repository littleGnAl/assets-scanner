import 'package:assets_scanner/src/assets_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder assetsRootBuilder(BuilderOptions builderOptions) =>
    SharedPartBuilder([AssetsGenerator()], "generated");
