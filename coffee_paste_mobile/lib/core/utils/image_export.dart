import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

/// Memotret widget yang dibungkus `RepaintBoundary(key: key)` menjadi PNG.
/// Mengembalikan null bila widget belum tergambar.
Future<Uint8List?> capturePng(GlobalKey key, {double pixelRatio = 3}) async {
  final boundary = key.currentContext?.findRenderObject();
  if (boundary is! RenderRepaintBoundary) return null;

  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data?.buffer.asUint8List();
}

/// Menyimpan PNG ke galeri perangkat. Mengembalikan true bila berhasil
/// (false bila izin galeri ditolak atau penyimpanan gagal).
Future<bool> savePngToGallery(Uint8List bytes, String fileName) async {
  try {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName.png');
    await file.writeAsBytes(bytes, flush: true);

    if (!await Gal.hasAccess()) {
      if (!await Gal.requestAccess()) return false;
    }
    await Gal.putImage(file.path);
    return true;
  } catch (_) {
    return false;
  }
}

/// Memotret [key] lalu menyimpannya ke galeri. Mengembalikan true bila berhasil.
Future<bool> captureAndSave(GlobalKey key, String fileName) async {
  final bytes = await capturePng(key);
  if (bytes == null) return false;
  return savePngToGallery(bytes, fileName);
}
