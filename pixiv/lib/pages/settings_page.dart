import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'app_settings.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Color currentColor;
  late TextEditingController domainController;

  @override
  void initState() {
    super.initState();
    currentColor = AppSettings.themeColor;
  }

  void changeColor(Color color) => setState(() => currentColor = color);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: AppSettings.themeColor,
      ),
      body: ListView(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              setState(() {
                // 切换主题模式
                AppSettings.themeMode = AppSettings.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
              });
            },
            child: Text('切换主题'),
          ),
          ListTile(
            title: Text('Theme Color'),
            trailing: CircleAvatar(
              backgroundColor: currentColor,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: currentColor,
                        onColorChanged: changeColor,
                        showLabel: true,
                        pickerAreaHeightPercent: 0.8,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Got it'),
                        onPressed: () {
                          setState(() => AppSettings.themeColor = currentColor);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
