import 'package:flutter/material.dart';
import 'store/app_store.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(TimetableApp(store: store));
}
