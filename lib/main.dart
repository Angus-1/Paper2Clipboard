import 'dart:async';
//import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_icon_button.dart';
import 'package:share_plus/share_plus.dart';

//import '../flutter_flow/flutter_flow_util.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// This app will use the main camera
List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Know what cameras we have before starting to use one
  cameras = await availableCameras();

  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromARGB(255, 0, 0, 0),
      systemNavigationBarIconBrightness: Brightness.light));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper2Clipboard',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Paper2Clipboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // The string text result from the OCR engine will be placed in here.
  // This string can be shown to the user, and is what gets copied to the
  // clipboard.
  String _scannedTextAsString = "Waiting for first scan result...";

  bool _scanBusy = false; // Is the phone busy already scanning something?

  // We change the camera settings and whatnot with this.
  CameraController? controller;

  // Gets initialized later in `_resetScanTimer`. Used to periodically
  // save a photo and scan it with OCR.
  var _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {});

  // May or may not be used on some UI elements to give color feedback.
  Color _statusColor = Colors.white;

  /*
    (Re)initializes and starts the `_scanTimer`. Run this when you want to begin
    continual scanning.
  */
  void _resetScanTimer() {
    print(">>>> TIMER RESET");
    _scanTimer.cancel(); // Avoid making multiple timers

    _scanTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      print(">>>>>> TIMER TICK! ${timer.tick}");

      String _newText = await _performPicAndScan();
      // Update the UI, showing what text was just scanned and copied.
      setState(() {
        _scannedTextAsString = _newText;
      });

      // if (counter == 0) {
      //   print('Cancel timer');
      //   timer.cancel();
      // }
    });

    return;
  }

  /*
    Put initialization code here.
  */
  @override
  void initState() {
    super.initState();

    // Initialize the camera and its settings
    controller = CameraController(cameras[0], ResolutionPreset.low);
    controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    //controller?.setFlashMode(FlashMode.off);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  /*
    For the search feature. Will find every needle in haystack, and populate
    a list
  */
  int stringSearch(String haystack, String needle, List<int> matches) {
    return 0;
  }

  /*
    Calling this function will take a photo from the camera and scan it for
    text. Due to this, the function takes a significant amount of time to run.
    Returns the text as a future string.
  */
  Future<String> _performPicAndScan() async {
    if (_scanBusy) {
      // Prevent running into exceptions from taking another pic too soon
      return "";
    }
    _scanBusy = true;
    // Grab a picture from the camera and save it to our temporary directory so
    // we can feed it to the OCR engine

    controller?.setFlashMode(FlashMode.off);
    final savedimg = await controller?.takePicture();
    final savedpath = savedimg!.path;

    // Fix the save image orientation. The OCR engine needs a correct
    // orientation to work as expected.
    final img.Image capturedImage =
        img.decodeImage(await File(savedpath).readAsBytes())!;
    final img.Image orientedImage = img.bakeOrientation(capturedImage);
    await File(savedpath).writeAsBytes(img.encodeJpg(orientedImage));

    print(">>>>>>> SAVED TO " + savedpath);
    // Now do ocr on it
    String _ocrTextResult = await FlutterTesseractOcr.extractText(savedpath,
        language: 'eng',
        args: {
          "psm": "4",
          "preserve_interword_spaces": "1",
        });
    print(">>>>>>> OCR COMPLETE! THE TEXT SAYS " + _ocrTextResult);
    // Now that we have the text, put it on the clipboard
    Clipboard.setData(ClipboardData(text: _ocrTextResult));

    // We're done, now clean up the cache
    await File(savedpath).delete();

    _scanBusy = false;
    return _ocrTextResult;
  }

  /*
    Resets the `_scanTimer` and provides feedback of this event. Run this
    when you want to begin or resume live scanning.
  */
  void _startPeriodicScan() {
    print(">>>> TOUCHED, STARTING SCAN TIMER");
    _statusColor = Colors.yellow;
    // Reset the timer
    _resetScanTimer();
    return;
  }

  /*
    Cancels the `_scanTimer` and provides feedback of this event. Run this
    when you want to stop or pause live scanning.
  */
  void _stopPeriodicScan() {
    print(">>>> TOUCHED, stopping SCAN TIMER");
    _statusColor = Colors.white;
    // Just stop the timer
    _scanTimer.cancel();
    return;
  }

  /*
    Runs when the user wants to share their scanned text. Should be called
    from a "share" button.
  */
  void _shareScannedText() {
    Share.share('$_scannedTextAsString', subject: 'From my Paper2Clipboard');
    return;
  }

  /* -----BUILD----------------------------------------------------------------
    This is where all the UI code goes! Everything below this point defines
    the visual structure of this app. After pasting the generated code from
    FlutterFlow, this is where you make the buttons call functions from above,
    and where you make other elements display data from variables above.
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldKey,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          //onTap: () => FocusScope.of(context).unfocus(),
          onTapDown: (details) =>
              _startPeriodicScan(), // When you start touching the screen
          onTapUp: (details) =>
              _stopPeriodicScan(), // When you stop touching the screen
          onTapCancel: () =>
              _stopPeriodicScan(), // When you stop touching the screen
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0, -0.98),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 20),
                      child: Container(
                        width: 340,
                        height: 480,
                        decoration: BoxDecoration(
                          color: Color(0xFF464646),
                          shape: BoxShape.rectangle,
                        ),
                        child: CameraPreview(controller!),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0, 0.78),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                      child: Container(
                        width: 340,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Color(0xFF323131),
                        ),
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(_scannedTextAsString,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-0.94, 0.95),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.black,
                          borderRadius: 30,
                          borderWidth: 1,
                          buttonSize: 40,
                          fillColor: Colors.black,
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {
                            print('searchButton pressed ...');
                          },
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(-0.47, 0.95),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30,
                          borderWidth: 1,
                          buttonSize: 40,
                          fillColor: Colors.black,
                          icon: Icon(
                            Icons.share_sharp,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {
                            print('shareButton pressed ...');
                          },
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0, 0.95),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30,
                          borderWidth: 1,
                          buttonSize: 40,
                          fillColor: Colors.black,
                          icon: Icon(
                            Icons.photo_size_select_small,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {
                            print('selectionIcon pressed ...');
                          },
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.47, 0.95),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30,
                          borderWidth: 1,
                          buttonSize: 40,
                          fillColor: Colors.black,
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {
                            print('editIcon pressed ...');
                          },
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.94, 0.95),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30,
                          borderWidth: 1,
                          buttonSize: 40,
                          fillColor: Colors.black,
                          icon: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () async {
                            print("boop");
                            // await Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => SettingsPageWidget(),
                            //   ),
                            // );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     //key: scaffoldKey,
  //     backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
  //     body: SafeArea(
  //       child: GestureDetector(
  //         //onTap: () => FocusScope.of(context).unfocus(), // FlutterFlow added this.
  //         //onTap: () =>
  //         //    _shareScannedText(), // How to use the share function. Put this on a button asap.
  //         onTapDown: (details) =>
  //             _startPeriodicScan(), // When you start touching the screen
  //         onTapUp: (details) =>
  //             _stopPeriodicScan(), // When you stop touching the screen
  //         onTapCancel: () =>
  //             _stopPeriodicScan(), // When you stop touching the screen
  //         child: Stack(
  //           children: [
  //             Align(
  //               alignment: AlignmentDirectional(-0.94, 0.95),
  //               child: Icon(
  //                 Icons.search_rounded,
  //                 color: FlutterFlowTheme.of(context).primaryColor,
  //                 size: 40,
  //               ),
  //             ),
  //             Align(
  //               alignment: AlignmentDirectional(-0.47, 0.95),
  //               child: Icon(
  //                 Icons.content_copy_rounded,
  //                 color: FlutterFlowTheme.of(context).primaryColor,
  //                 size: 40,
  //               ),
  //             ),
  //             Align(
  //               alignment: AlignmentDirectional(0, 0.95),
  //               child: Icon(
  //                 Icons.crop_rounded,
  //                 color: FlutterFlowTheme.of(context).primaryColor,
  //                 size: 40,
  //               ),
  //             ),
  //             Align(
  //               alignment: AlignmentDirectional(0.47, 0.95),
  //               child: Icon(
  //                 Icons.edit,
  //                 color: FlutterFlowTheme.of(context).primaryColor,
  //                 size: 40,
  //               ),
  //             ),
  //             Align(
  //               alignment: AlignmentDirectional(0, -0.8),
  //               child: Container(
  //                 width: 340,
  //                 height: 500,
  //                 decoration: BoxDecoration(
  //                   color: Color(0xFF464646),
  //                   shape: BoxShape.rectangle,
  //                 ),
  //                 child: CameraPreview(controller!),
  //               ),
  //             ),
  //             Align(
  //               alignment: AlignmentDirectional(0, 0.75),
  //               child: Container(
  //                 width: 340,
  //                 height: 120,
  //                 decoration: BoxDecoration(
  //                   color: Color.fromARGB(255, 224, 224, 224),
  //                 ),
  //                 child: FittedBox(
  //                     fit: BoxFit.fitHeight,
  //                     child: Text('$_scannedTextAsString')),
  //               ),
  //             ),
  //             Align(
  //               alignment: AlignmentDirectional(0.94, 0.95),
  //               child: Icon(
  //                 Icons.settings,
  //                 color: FlutterFlowTheme.of(context).primaryColor,
  //                 size: 40,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
