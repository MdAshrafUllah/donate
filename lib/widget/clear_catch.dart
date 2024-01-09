import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> deleteCacheDir() async {
  Directory tempDir = await getTemporaryDirectory();

  if (tempDir.existsSync()) {
    tempDir.deleteSync(recursive: true);
  }
}

Future<void> deleteAppDir() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();

  if (appDocDir.existsSync()) {
    appDocDir.deleteSync(recursive: true);
  }
}
