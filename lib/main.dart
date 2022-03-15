import 'dart:async';
//import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import '../flutter_flow/flutter_flow_theme.dart';
//import '../flutter_flow/flutter_flow_util.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(const MyApp());
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
      home: const MyHomePage(title: 'Paper2Clipboard: Humble Beginnings'),
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
  int _counter = 0;
  String _text = "Waiting for first scan result...";
  bool _scanBusy = false;
  CameraController? controller;
  var _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {});
  Color _statusColor = Colors.white;

  void _resetScanTimer() {
    print(">>>> TIMER RESET");
    _scanTimer.cancel(); // Avoid making multiple timers

    _scanTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      print(">>>>>> TIMER TICK! ${timer.tick}");

      String _newText = await _performPicAndScan();
      // Update the UI, showing what text was just scanned and copied.
      setState(() {
        _text = _newText;
      });

      // if (counter == 0) {
      //   print('Cancel timer');
      //   timer.cancel();
      // }
    });

    return;
  }

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

    // Initialize periodic timer for periodic scanning
    //_resetScanTimer();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

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

    _scanBusy = false;
    return _ocrTextResult;
  }

  void _screentap() async {
    // print(">>>>>> tapped!");
    // String _newText = await _performPicAndScan();
    // // Update the UI, showing what text was just scanned and copied.
    // setState(() {
    //   _text = _newText;
    // });
    return;
  }

  void _startPeriodicScan() {
    print(">>>> TOUCHED, STARTING SCAN TIMER");
    _statusColor = Colors.yellow;
    // Reset the timer
    _resetScanTimer();
    return;
  }

  void _stopPeriodicScan() {
    print(">>>> TOUCHED, stopping SCAN TIMER");
    _statusColor = Colors.white;
    // Just stop the timer
    _scanTimer.cancel();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Align(
                alignment: AlignmentDirectional(-0.94, 0.95),
                child: Icon(
                  Icons.search_rounded,
                  color: FlutterFlowTheme.of(context).primaryColor,
                  size: 40,
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-0.47, 0.95),
                child: Icon(
                  Icons.content_copy_rounded,
                  color: FlutterFlowTheme.of(context).primaryColor,
                  size: 40,
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0, 0.95),
                child: Icon(
                  Icons.crop_rounded,
                  color: FlutterFlowTheme.of(context).primaryColor,
                  size: 40,
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.47, 0.95),
                child: Icon(
                  Icons.edit,
                  color: FlutterFlowTheme.of(context).primaryColor,
                  size: 40,
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0, -0.8),
                child: Container(
                  width: 340,
                  height: 500,
                  decoration: BoxDecoration(
                    color: Color(0xFF464646),
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0, 0.75),
                child: Container(
                  width: 340,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 78, 78, 78),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.94, 0.95),
                child: Icon(
                  Icons.settings,
                  color: FlutterFlowTheme.of(context).primaryColor,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   if (!controller!.value.isInitialized) {
  //     return Container();
  //   }
  //   return MaterialApp(
  //       home: Scaffold(
  //     appBar: AppBar(
  //       centerTitle: true,
  //       title: Text("Paper2Clipboard Alpha"),
  //     ),
  //     body: GestureDetector(
  //       behavior: HitTestBehavior.opaque,
  //       //onTap: () => print('Tapped'),
  //       onTap: () => _screentap(),
  //       onTapDown: (details) =>
  //           _startPeriodicScan(), // When you start touching the screen
  //       onTapUp: (details) =>
  //           _stopPeriodicScan(), // When you stop touching the screen
  //       onTapCancel: () =>
  //           _stopPeriodicScan(), // When you stop touching the screen
  //       //child: CameraPreview(controller!),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           // Text(
  //           //   '$_text',
  //           //   style: Theme.of(context).textTheme.titleLarge,
  //           // ),
  //           Container(
  //               height: 100,
  //               width: 350,
  //               color: _statusColor,
  //               child: FittedBox(fit: BoxFit.fitHeight, child: Text('$_text'))),

  //           CameraPreview(controller!),
  //         ],
  //       ),
  //     ),
  //   ));
  // }

}
