import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:Paper2Clipboard/cam_view/cam_view_widget.dart';
//import '/cam_view/cam_view_widget.dart';
import 'home_page/home_page_widget.dart';
//import 'test_page/test_page_widget.dart';
import 'flutter_flow/flutter_flow_theme.dart';

import 'flutter_flow/flutter_flow_util.dart';
//import 'flutter_flow/internationalization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/src/services/system_chrome.dart';
import 'package:camera/camera.dart';

// This app will use the main camera
List<CameraDescription> cameras = <CameraDescription>[];

// Resolution preference
ResolutionPreset resolutionPreference = ResolutionPreset.low;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterFlowTheme.initialize();

  // Know what cameras we have before starting to use one
  cameras = await availableCameras();

  runApp(MyApp());
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     systemNavigationBarColor: Color.fromARGB(255, 0, 0, 0),
  //     systemNavigationBarIconBrightness: Brightness.light));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  void setLocale(Locale value) => setState(() => _locale = value);
  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper2Clipboard',
      // localizationsDelegates: [
      //   //FFLocalizationsDelegate(),
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // locale: _locale,
      // supportedLocales: const [Locale('en', '')],
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,
      home: HomePageWidget(),
    );
  }
}
