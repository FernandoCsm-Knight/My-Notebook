import 'package:my_notebook/settings/model/AppSettings.dart';
import 'package:my_notebook/settings/service/SettingsService.dart';

class SettingsProvider {
  AppSettings _settings = AppSettings();
  final SettingsService _settingsService = SettingsService();

  SettingsProvider() {
    loadSettings();
  }

  AppSettings get settings => _settings;

  Future<void> loadSettings() async {
    _settings = await _settingsService.loadPreferences();
  }

  void updateSettings({ bool? darkThemeEnabled, bool? onlySaveLocal, bool? randomProfilePicture }) {
    _settings.darkThemeEnabled = darkThemeEnabled ?? _settings.darkThemeEnabled;
    _settings.onlySaveLocal = onlySaveLocal ?? _settings.onlySaveLocal;
    _settings.randomProfilePicture = randomProfilePicture ?? _settings.randomProfilePicture;
    _settingsService.savePreferences(settings: settings);
  }
}