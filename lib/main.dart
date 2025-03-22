import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS || Platform.isIOS){
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  if (kIsWeb){
    sqfliteFfiInit();
    databaseFactory =databaseFactoryFfiWeb;
  }
  runApp(const App());
}
