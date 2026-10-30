class DateFormatter {
  static String toPersianDigits(dynamic input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    String text = input.toString();
    for (int i = 0; i < english.length; i++) {
      text = text.replaceAll(english[i], persian[i]);
    }
    return text;
  }

  static String timeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.tryParse(dateString.replaceAll(' ', 'T')) ?? DateTime.now();
      final diff = DateTime.now().difference(date);

      if (diff.inSeconds < 60) {
        return 'همین الان';
      } else if (diff.inMinutes < 60) {
        return '${toPersianDigits(diff.inMinutes)} دقیقه پیش';
      } else if (diff.inHours < 24) {
        return '${toPersianDigits(diff.inHours)} ساعت پیش';
      } else if (diff.inDays < 7) {
        return '${toPersianDigits(diff.inDays)} روز پیش';
      } else if (diff.inDays < 30) {
        final weeks = (diff.inDays / 7).floor();
        return '${toPersianDigits(weeks)} هفته پیش';
      } else if (diff.inDays < 365) {
        final months = (diff.inDays / 30).floor();
        return '${toPersianDigits(months)} ماه پیش';
      } else {
        final years = (diff.inDays / 365).floor();
        return '${toPersianDigits(years)} سال پیش';
      }
    } catch (_) {
      return dateString;
    }
  }
}
