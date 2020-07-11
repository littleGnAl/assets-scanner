// Copyright (C) 2020 littlegnal
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'package:assets_scanner/src/assets_builder.dart';
import 'package:build/build.dart';

/// A [Builder] that get the assets path from `pubspec.yaml` and generate
/// a `r.dart` with `const` properties of assets path. See [AssetsBuilder]
/// for more detail.
Builder assetScannerBuilder(BuilderOptions builderOptions) => AssetsBuilder();
