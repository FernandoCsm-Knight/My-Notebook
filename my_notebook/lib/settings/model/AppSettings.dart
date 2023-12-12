class AppSettings {
  bool _darkThemeEnabled = false;
  bool _onlySaveLocal = false;
  bool _randomProfilePicture = false;

  AppSettings({
    bool darkThemeEnabled = false,
    bool onlySaveLocal = false,
    bool randomProfilePicture = false,
  }) : _darkThemeEnabled = darkThemeEnabled,
       _onlySaveLocal = onlySaveLocal,
       _randomProfilePicture = randomProfilePicture;

  void set darkThemeEnabled(bool value) {
    _darkThemeEnabled = value;
  }

  void set onlySaveLocal(bool value) {
    _onlySaveLocal = value;
  }

  void set randomProfilePicture(bool value) {
    _randomProfilePicture = value;
  }

  bool get darkThemeEnabled => _darkThemeEnabled;

  bool get onlySaveLocal => _onlySaveLocal;

  bool get randomProfilePicture => _randomProfilePicture;

  AppSettings.fromMap(Map<String, dynamic> json) {
    darkThemeEnabled = json['darkThemeEnabled'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['darkThemeEnabled'] = darkThemeEnabled;
    return data;
  }
}