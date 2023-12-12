class StoragePaths {
  static String get users => 'users/';
  static String get profile => 'profile/';
  static String get profileImage => 'image.png';
  static String get pdf => 'pdfs/';

  static String user(String uid) => '${users}$uid/';
  static String userImage(String uid) => '${user(uid)}${profile}${profileImage}';
  static String userPdf(String uid) => '${user(uid)}${pdf}';
  static String allUsersPdf() => '${pdf}';
}