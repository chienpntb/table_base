/// Format a date as dd/MM/yyyy
String formatDate(DateTime? date, {String? textDateNull}) {
  if (date == null) return textDateNull ?? 'Chọn ngày';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
