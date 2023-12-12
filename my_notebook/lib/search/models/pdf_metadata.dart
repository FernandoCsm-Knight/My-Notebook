class UserEvaluation {
  String userId;
  String? userDisplayName;
  String? userPhotoUrl;
  String userEmail;
  DateTime date;
  String text;

  UserEvaluation({required this.userId, this.userDisplayName, this.userPhotoUrl, required this.userEmail, required this.date, required this.text});
}

class PdfMetadata {
  String userId;
  String? userDisplayName;
  String? userPhotoUrl;
  String userEmail;
  String pdfId;
  String title;
  String pdfUrl;
  String thumbnailUrl;
  DateTime uploadDate;
  List<UserEvaluation> evaluations;

  PdfMetadata({
    required this.userId,
    required this.userDisplayName,
    required this.userPhotoUrl,
    required this.userEmail,
    required this.pdfId,
    required this.title,
    required this.pdfUrl,
    required this.thumbnailUrl,
    required this.uploadDate,
    required this.evaluations,
  });
}