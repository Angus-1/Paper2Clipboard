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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF3D0000),
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
                  style: FlutterFlowTheme.of(context).bodyText1,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                child: FlutterFlowRadioButton(
                  options: ['Super High', 'High', 'Medium', 'Low'].toList(),
                  onChanged: (value) {
                    setState(() => radioButtonValue = value.toString());
                  },
                  optionHeight: 25,
                  textStyle: FlutterFlowTheme.of(context).bodyText1.override(
                        fontFamily: 'Poppins',
                        color: Color(0xFFFBFBFB),
                      ),
                  buttonPosition: RadioButtonPosition.left,
                  direction: Axis.vertical,
                  radioButtonColor: Color(0xFF950101),
                  inactiveRadioButtonColor: Color(0xFFFBFBFB),
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
