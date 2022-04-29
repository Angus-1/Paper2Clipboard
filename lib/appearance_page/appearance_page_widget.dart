import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
//import '../flutter_flow/flutter_flow_util.dart';
import '../settings_page/settings_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class AppearancePageWidget extends StatefulWidget {
  const AppearancePageWidget({Key? key}) : super(key: key);

  @override
  _AppearancePageWidgetState createState() => _AppearancePageWidgetState();
}

class _AppearancePageWidgetState extends State<AppearancePageWidget> {
  bool lightModeValue = false;
  bool switchListTileValue = false;
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
          'Appearance',
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
      backgroundColor: Color(0xFF181818),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: SwitchListTile(
                    value: lightModeValue ??= true,
                    // onChanged: (newValue) =>
                    //     setState(() => lightModeValue = newValue),
                    onChanged: (newValue) {
                      setState(() => lightModeValue = newValue);
                      //MyAppState.setThemeMode();
                    },
                    title: Text(
                      'Light Mode',
                      style: FlutterFlowTheme.of(context).title3.override(
                            fontFamily: 'Poppins',
                            fontSize: 17,
                          ),
                    ),
                    tileColor: Color(0xFF950101),
                    dense: false,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                ),
              ),
              SwitchListTile(
                value: switchListTileValue ??= true,
                onChanged: (newValue) =>
                    setState(() => switchListTileValue = newValue),
                title: Text(
                  'Change Theme Color',
                  style: FlutterFlowTheme.of(context).title3.override(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                      ),
                ),
                tileColor: Color(0xFF950101),
                dense: false,
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
