import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MapStorage {
  static const List<String> allowedExtensions = [
    '.svg',
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
  ];

  Future<Directory> get _mapsDirectory async {
    final docsDir = await getApplicationDocumentsDirectory();
    final mapsDir = Directory(p.join(docsDir.path, 'maps'));

    if (!await mapsDir.exists()) {
      await mapsDir.create(recursive: true);
    }
    return mapsDir;
  }

  /// Save a user-provided file (real File) into maps dir.
  Future<File> writeFile(String mapName, File sourceFile) async {
    final dir = await _mapsDirectory;

    String name = mapName;
    final nameExt = p.extension(mapName).toLowerCase();
    final srcExt = p.extension(sourceFile.path).toLowerCase();

    String effectiveExt;
    if (nameExt.isNotEmpty) {
      effectiveExt = nameExt;
    } else {
      effectiveExt = srcExt;
      name = '$mapName$effectiveExt';
    }

    _validateExtension(effectiveExt);

    final destPath = p.join(dir.path, name);
    return sourceFile.copy(destPath);
  }

  /// Save a Flutter asset into maps dir.
  Future<File> writeAsset(String assetPath, String mapName) async {
    final dir = await _mapsDirectory;

    final assetExt = p.extension(assetPath).toLowerCase();
    String name = mapName;
    final nameExt = p.extension(mapName).toLowerCase();

    String effectiveExt;
    if (nameExt.isNotEmpty) {
      effectiveExt = nameExt;
    } else {
      effectiveExt = assetExt;
      name = '$mapName$effectiveExt';
    }

    _validateExtension(effectiveExt);

    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();

    final destPath = p.join(dir.path, name);
    final file = File(destPath);
    return file.writeAsBytes(bytes, flush: true);
  }

  void _validateExtension(String ext) {
    if (!allowedExtensions.contains(ext)) {
      throw UnsupportedError(
        'Unsupported file type "$ext". Allowed: ${allowedExtensions.join(', ')}',
      );
    }
  }

  Future<String?> getFilePath(String mapName) async {
    final dir = await _mapsDirectory;
    final filePath = p.join(dir.path, mapName);
    final file = File(filePath);
    if (await file.exists()) {
      return filePath;
    }
    return null;
  }
}