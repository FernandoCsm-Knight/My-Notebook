import 'package:flutter/material.dart';
import 'package:my_notebook/main.dart';
import 'package:my_notebook/settings/model/AppSettings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SharedPreferences? _prefs;

  Future<AppSettings> loadPreferences() async {
    await _init();
    
    AppSettings settings = AppSettings(
      darkThemeEnabled: _prefs!.getBool('darkThemeEnabled') ?? false,
      onlySaveLocal: _prefs!.getBool('onlySaveLocal') ?? false,
      randomProfilePicture: _prefs!.getBool('randomProfilePicture') ?? false,
    );

    return settings;
  }

  Future<void> savePreferences({ required AppSettings settings }) async {
    await _init();
    await _prefs!.setBool('darkThemeEnabled', settings.darkThemeEnabled);
    await _prefs!.setBool('onlySaveLocal', settings.onlySaveLocal);
    await _prefs!.setBool('randomProfilePicture', settings.randomProfilePicture);
    ThemeMode themeMode = settings.darkThemeEnabled ? ThemeMode.dark : ThemeMode.light;
    MyNotebook.themeNotifier.value = themeMode;
  }

  Future<void> clearPreferences() async {
    await _init();
    await _prefs!.clear();
  }

  Future<void> _init() async {
    if(_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }
}
