import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
//import '../flutter_flow/flutter_flow_util.dart';
import '../settings_page/settings_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:image_picker/image_picker.dart';
import '../main.dart';

// This app will use the main camera
// List<CameraDescription> cameras = <CameraDescription>[];

class CamViewWidget extends StatefulWidget {
  const CamViewWidget({Key? key}) : super(key: key);

  @override
  _CamViewWidgetState createState() => _CamViewWidgetState();
}

class _CamViewWidgetState extends State<CamViewWidget>
    with WidgetsBindingObserver {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // This variable will tell you whether the application is in foreground or not.
  bool _isInForeground = true;

  // The string text result from the OCR engine will be placed in here.
  // This string can be shown to the user, and is what gets copied to the
  // clipboard.
  String _scannedTextAsString = "Touch the camera area to begin scanning.";
  String _findText = "fox";
  final double _outputFontSize = 16.0;

  bool _findModeActive = true;

  bool _scanBusy = false; // Is the phone busy already scanning something?

  // We change the camera settings and whatnot with this.
  CameraController? controller;

  // Gets initialized later in `_resetScanTimer`. Used to periodically
  // save a photo and scan it with OCR.
  var _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {});

  // May or may not be used on some UI elements to give color feedback.
  Color _statusColor = Colors.white;

  TextSpan displayedScannedContents =
      TextSpan(children: [TextSpan(text: "helloo")]);

  FocusNode _focusNode = FocusNode();

  // for searching
  TextEditingController textController = TextEditingController();

  // for manual focus
   double sliderValue = 0.0;

  bool _torchActive = false;

  List<String> _splitKeepSeparator(String haystack, String needle) {
    var re = RegExp("((?=$needle)|(?<=$needle))");
    return haystack.split(re);
  }

  Text _buildTextSpanWithSplittedText(String textToSplit,
      {bool findMode = true}) {
    //https://stackoverflow.com/questions/55839275/flutter-changing-textstyle-of-textspan-with-tapgesturerecognizer
    //final splittedText = textToSplit.split(" ");
    List<TextSpan> spans = []; //List<TextSpan>();
    if (findMode) {
      List<String> splittedText = _splitKeepSeparator(textToSplit, _findText);
      for (int i = 0; i <= splittedText.length - 1; i++) {
        if (splittedText[i].toString().compareTo(_findText) == 0) {
          spans.add(TextSpan(
              text: splittedText[i].toString(),
              style: TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: _outputFontSize)));
        } else {
          spans.add(TextSpan(
              text: splittedText[i].toString(),
              style: TextStyle(color: Colors.black, fontSize: _outputFontSize)));
        }
      }
    } else {
      spans.add(TextSpan(
          text: textToSplit,
          style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0), fontSize: _outputFontSize))); // no splitting
    }

    return Text.rich(TextSpan(children: spans));
  }

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

      if (!_scanBusy) {
        _scanBusy = true;

        String _newText = await _performPicAndScan(controller);
        _scanBusy = false;
        // Update the UI, showing what text was just scanned and copied.
        setState(() {
          _scannedTextAsString = _newText;
        });
      }

      // if (counter == 0) {
      //   print('Cancel timer');
      //   timer.cancel();
      // }
    });

    return;
  }

  void initCamera(ResolutionPreset resolution) {
    //Future.delayed(const Duration(milliseconds: 500), () {
    // Initialize the camera and its settings
    controller = CameraController(cameras[0], resolution);
    controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      // Make sure auto focus and auto exposure are on
      controller?.setFocusMode(FocusMode.auto);
      controller?.setExposureMode(ExposureMode.auto);
      setState(() {});
    });

    //});
  }

  Future<void> _getCams() async {
    // Know what cameras we have before starting to use one
    cameras = await availableCameras();
  }

  /*
    Put initialization code here.
  */
  @override
  void initState() {
    super.initState();

    _getCams();

    //_focusNode = FocusNode();
    _focusNode.addListener(() {
      print(">>>> Listener");
    });

    //initCamera(ResolutionPreset.low);
    initCamera(resolutionPreference);
    //controller?.setFlashMode(FlashMode.off);

    WidgetsBinding.instance!.addObserver(this);

    textController = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    controller?.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        initCamera(
            resolutionPreference); // Reinitialize camera incase it got deactivated
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  /*
    For the search feature. Will find every needle in haystack, and populate
    a list
  */
  int stringSearch(String haystack, String needle, List<int> matches) {
    return 0;
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

  void _showKeyboard() {
    //_focusNode.requestFocus();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _searchButtonPressed() {
    print('searchButton pressed ...');

    _findModeActive = !_findModeActive;
    if (_findModeActive) {
      _showKeyboard();
    } else {
      _hideKeyboard();
    }
  }

  /* -----BUILD----------------------------------------------------------------
    This is where all the UI code goes! Everything below this point defines
    the visual structure of this app. After pasting the generated code from
    FlutterFlow, this is where you make the buttons call functions from above,
    and where you make other elements display data from variables above.
  */
  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     key: scaffoldKey,
  //     backgroundColor: Color(0xFF181818),
  //     body: SafeArea(
  //       child: GestureDetector(
  //         //onTap: () => FocusScope.of(context).unfocus(),
  //         onTapDown: (details) =>
  //             _startPeriodicScan(), // When you start touching the screen
  //         onTapUp: (details) =>
  //             _stopPeriodicScan(), // When you stop touching the screen
  //         onTapCancel: () =>
  //             _stopPeriodicScan(), // When you stop touching the screen
  //         child: Stack(
  //           children: [
  //             Column(
  //               mainAxisSize: MainAxisSize.max,
  //               children: [
  //                 Align(
  //                   alignment: AlignmentDirectional(0, -0.98),
  //                   child: Padding(
  //                     padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 20),
  //                     child: Container(
  //                       width: 340,
  //                       height: 480,
  //                       decoration: BoxDecoration(
  //                         color: Color(0xFF464646),
  //                         shape: BoxShape.rectangle,
  //                       ),
  //                       child: CameraPreview(controller!),
  //                     ),
  //                   ),
  //                 ),
  //                 Align(
  //                   alignment: AlignmentDirectional(0, 0.78),
  //                   child: Padding(
  //                     padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
  //                     child: Container(
  //                       width: 340,
  //                       height: 120,
  //                       decoration: BoxDecoration(
  //                         color: Color(0xFF323131),
  //                         //color: Color(0xFF0000FF),
  //                         shape: BoxShape.rectangle,
  //                       ),
  //                       child: SingleChildScrollView(
  //                         scrollDirection: Axis.vertical,
  //                         child: _buildTextSpanWithSplittedText(
  //                             _scannedTextAsString,
  //                             findMode: _findModeActive),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Row(
  //                   mainAxisSize: MainAxisSize.max,
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   crossAxisAlignment: CrossAxisAlignment.end,
  //                   children: [
  //                     Align(
  //                       alignment: AlignmentDirectional(-0.94, 0.95),
  //                       child: FlutterFlowIconButton(
  //                         borderColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         borderRadius: 30,
  //                         borderWidth: 0,
  //                         buttonSize: 40,
  //                         fillColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         icon: Icon(
  //                           Icons.search,
  //                           color: Colors.white,
  //                           size: 25,
  //                         ),
  //                         onPressed: () {
  //                           _searchButtonPressed();
  //                         },
  //                       ),
  //                     ),
  //                     Align(
  //                       alignment: AlignmentDirectional(-0.47, 0.95),
  //                       child: FlutterFlowIconButton(
  //                         borderColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         borderRadius: 30,
  //                         borderWidth: 0,
  //                         buttonSize: 40,
  //                         fillColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         icon: Icon(
  //                           Icons.share_sharp,
  //                           color: Colors.white,
  //                           size: 25,
  //                         ),
  //                         onPressed: () {
  //                           print('shareButton pressed ...');
  //                           _shareScannedText();
  //                         },
  //                       ),
  //                     ),
  //                     Align(
  //                       alignment: AlignmentDirectional(0, 0.95),
  //                       child: FlutterFlowIconButton(
  //                         borderColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         borderRadius: 30,
  //                         borderWidth: 0,
  //                         buttonSize: 40,
  //                         fillColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         icon: Icon(
  //                           Icons.photo_size_select_small,
  //                           color: Colors.white,
  //                           size: 25,
  //                         ),
  //                         onPressed: () {
  //                           print('selectionIcon pressed ...');
  //                         },
  //                       ),
  //                     ),
  //                     Align(
  //                       alignment: AlignmentDirectional(0.47, 0.95),
  //                       child: FlutterFlowIconButton(
  //                         borderColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         borderRadius: 30,
  //                         borderWidth: 0,
  //                         buttonSize: 40,
  //                         fillColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         icon: Icon(
  //                           Icons.edit,
  //                           color: Colors.white,
  //                           size: 25,
  //                         ),
  //                         onPressed: () {
  //                           print('editIcon pressed ...');
  //                         },
  //                       ),
  //                     ),
  //                     Align(
  //                       alignment: AlignmentDirectional(0.94, 0.95),
  //                       child: FlutterFlowIconButton(
  //                         borderColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         borderRadius: 30,
  //                         borderWidth: 0,
  //                         buttonSize: 40,
  //                         fillColor:
  //                             FlutterFlowTheme.of(context).primaryBackground,
  //                         icon: Icon(
  //                           Icons.settings,
  //                           color: Colors.white,
  //                           size: 30,
  //                         ),
  //                         onPressed: () async {
  //                           await Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (context) => SettingsPageWidget(),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
           onTapDown: (details) =>
              _startPeriodicScan(), // When you start touching the screen
          onTapUp: (details) =>
              _stopPeriodicScan(), // When you stop touching the screen
          onTapCancel: () =>
              _stopPeriodicScan(), // When you stop touching the screen
          child: Stack(
            children: [
              // if (responsiveVisibility(
              //   context: context,
              //   tablet: false,
              //   tabletLandscape: false,
              //   desktop: false,
              // ))
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional(0, -0.98),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(5, 0, 5, 10),
                            child: Container(
                              width: double.infinity,
                              height: 500,
                              decoration: BoxDecoration(
                                color: Color(0xFF95A1AC),
                                shape: BoxShape.rectangle,
                              ),
                              child: CameraPreview(controller!),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                        child: TextFormField(
                          controller: textController,
                          // onChanged: (_) => EasyDebounce.debounce(
                          //   'textController',
                          //   Duration(milliseconds: 2000),
                          //   () => setState(() {}),
                          // ),
                          onChanged: (String value){
                            setState(() {
                          _findText = value;
                        });
                          },
                          autofocus: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Search....',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x00000000),
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4.0),
                                topRight: Radius.circular(4.0),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x00000000),
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4.0),
                                topRight: Radius.circular(4.0),
                              ),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyText1,
                        ),
                      ),
                      Slider(
                        activeColor: FlutterFlowTheme.of(context).primaryColor,
                        inactiveColor: Color(0xFF9E9E9E),
                        min: 0,
                        max: 10,
                        value: sliderValue ??= 0,
                        onChanged: (newValue) {
                          setState(() => sliderValue = newValue);
                          if(newValue > 0.1){
                            controller?.setFocusMode(FocusMode.locked);
                          }else{
                            controller?.setFocusMode(FocusMode.auto);
                          }
                        },
                      ),
                      
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional(0, 0.78),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                            child: Container(
                              width: double.infinity,
                              height: 400,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 207, 211, 215),
                                shape: BoxShape.rectangle,
                              ),
                              child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: _buildTextSpanWithSplittedText(
                              _scannedTextAsString,
                              findMode: _findModeActive),
                        ),
                              alignment: AlignmentDirectional(0, 0),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(-0.94, 0.95),
                                child: FlutterFlowIconButton(
                                  borderColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: 30,
                                  borderWidth: 0,
                                  buttonSize: 40,
                                  fillColor: Color(0x00111518),
                                  icon: Icon(
                                    Icons.lightbulb,
                                    color: Color(0xFF6A7986),
                                    size: 25,
                                  ),
                                  onPressed: () {
                                    print('searchButton pressed ...');
                                     //_searchButtonPressed();
                                     _torchActive = !_torchActive;
                                     if(_torchActive){
                                       controller?.setFlashMode(FlashMode.torch);
                                     }else{
                                        controller?.setFlashMode(FlashMode.off);
                                     }
                                  },
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(-0.47, 0.95),
                                child: FlutterFlowIconButton(
                                  borderColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: 30,
                                  borderWidth: 0,
                                  buttonSize: 40,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  icon: Icon(
                                    Icons.share_sharp,
                                    color: Color(0xFF6A7986),
                                    size: 25,
                                  ),
                                  onPressed: () {
                                    print('shareButton pressed ...');
                                    _shareScannedText();
                                  },
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0, 0.95),
                                child: FlutterFlowIconButton(
                                  borderColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: 30,
                                  borderWidth: 0,
                                  buttonSize: 40,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  icon: Icon(
                                    Icons.photo_size_select_small,
                                    color: Color(0xFF6A7986),
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
                                  borderColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: 30,
                                  borderWidth: 0,
                                  buttonSize: 40,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  icon: Icon(
                                    Icons.edit,
                                    color: Color(0xFF6A7986),
                                    size: 25,
                                  ),
                                  onPressed: () {
                                    print('editIcon pressed ...');
                                  },
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.47, 0.95),
                                child: FlutterFlowIconButton(
                                  borderColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: 30,
                                  borderWidth: 0,
                                  buttonSize: 40,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  icon: Icon(
                                    Icons.insert_photo_outlined,
                                    color: Color(0xFF6A7986),
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    print('insertPhotoIcon pressed ...');
                                    final ImagePicker _picker = ImagePicker();
                            final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery);
                            final String imagePath = image!.path;
                            String _ocrTextResult =
                                await FlutterTesseractOcr.extractText(imagePath,
                                    language: 'eng',
                                    args: {
                                  "psm": "4",
                                  "preserve_interword_spaces": "1",
                                });
                            print(">>>>>>> OCR COMPLETE! THE TEXT SAYS " +
                                _ocrTextResult);
                            setState(() {
                              _scannedTextAsString = _ocrTextResult;
                            });
                                  },
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.94, 0.95),
                                child: FlutterFlowIconButton(
                                  borderColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: 30,
                                  borderWidth: 0,
                                  buttonSize: 40,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  icon: Icon(
                                    Icons.settings,
                                    color: Color(0xFF6A7986),
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SettingsPageWidget(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
    Calling this function will take a photo from the camera and scan it for
    text. Due to this, the function takes a significant amount of time to run.
    Returns the text as a future string.
  */
Future<String> _performPicAndScan(CameraController? controller) async {
  // if (_scanBusy) {
  //   // Prevent running into exceptions from taking another pic too soon
  //   return "";
  // }
  //_scanBusy = true;
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
  String _ocrTextResult =
      await FlutterTesseractOcr.extractText(savedpath, language: 'eng', args: {
    "psm": "4",
    "preserve_interword_spaces": "1",
  });
  print(">>>>>>> OCR COMPLETE! THE TEXT SAYS " + _ocrTextResult);
  // Now that we have the text, put it on the clipboard
  Clipboard.setData(ClipboardData(text: _ocrTextResult));

  // We're done, now clean up the cache
  await File(savedpath).delete();

  //_scanBusy = false;
  return _ocrTextResult;
}
