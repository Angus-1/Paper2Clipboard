import 'package:camera/camera.dart';
import 'package:paper2clipboard/main.dart';

import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_radio_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
//import '../flutter_flow/flutter_flow_util.dart';
import '../settings_page/settings_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraSettingsPageWidget extends StatefulWidget {
  const CameraSettingsPageWidget({Key? key}) : super(key: key);

  @override
  _CameraSettingsPageWidgetState createState() =>
      _CameraSettingsPageWidgetState();
}

class _CameraSettingsPageWidgetState extends State<CameraSettingsPageWidget> {
  String radioButtonValue = "";
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // Switch: Options to select from are Low, Medium, High, Very High, Ultra High, and Max.
  // From  those selected option, do what is expected of that choice, that is, set the resolution to Low, Medium, High, Very High, Ultra High, or Max.
  // If neither of those options are selected, then break and inform the user that they have selected an invalid option.
  void _changeResolutionPrefFromStr(value) {
    switch (value) {
      case 'Low':
        resolutionPreference = ResolutionPreset.low;
        break;
      case 'Medium':
        resolutionPreference = ResolutionPreset.medium;
        break;
      case 'High':
        resolutionPreference = ResolutionPreset.high;
        break;
      case 'Very High':
        resolutionPreference = ResolutionPreset.veryHigh;
        break;
      case 'Ultra High':
        resolutionPreference = ResolutionPreset.ultraHigh;
        break;
      case 'Max':
        resolutionPreference = ResolutionPreset.max;
        break;
      default:
        print("Incorrect resolution option \"$value\"");
        resolutionPreference = ResolutionPreset.low;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        // The following line produced an error when testing the application. Will have to return to correct this.
        // backgroundColor: FlutterFlowTheme.of(context).bannerColor
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          borderWidth: 1,
          buttonSize: 60,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPageWidget(),
              ),
            );
          },
        ),
        title: Text(
          'Camera',
          style: FlutterFlowTheme.of(context).title2.override(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 22,
              ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 20, 0, 0),
                child: Text(
                  'Camera Resolution',
                  style: FlutterFlowTheme.of(context).subtitle1.override(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                child: FlutterFlowRadioButton(
                  options: [
                    'Low',
                    'Medium',
                    'High',
                    'Very High',
                    'Ultra High',
                    'Max'
                  ].toList(),
                  onChanged: (value) {
                    setState(() => radioButtonValue = value.toString());
                    _changeResolutionPrefFromStr(value);
                  },
                  optionHeight: 25,
                  textStyle: FlutterFlowTheme.of(context).bodyText1.override(
                        fontFamily: 'Poppins',
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                  buttonPosition: RadioButtonPosition.left,
                  direction: Axis.vertical,
                  radioButtonColor: Color(0xFF950101),
                  inactiveRadioButtonColor:
                      FlutterFlowTheme.of(context).secondaryText,
                  toggleable: false,
                  horizontalAlignment: WrapAlignment.start,
                  verticalAlignment: WrapCrossAlignment.start,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
