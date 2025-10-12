import 'package:flutter/foundation.dart';

/// Enum để xác định loại chọn ngày
enum DateSelectionMode {
  single,  // Chọn 1 ngày
  range,   // Chọn khoảng ngày
}

/// Model đại diện cho một ngày trong calendar
class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool isInRange;
  final bool isRangeStart;
  final bool isRangeEnd;

  const CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    this.isSelected = false,
    this.isInRange = false,
    this.isRangeStart = false,
    this.isRangeEnd = false,
  });

  CalendarDay copyWith({
    DateTime? date,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isSelected,
    bool? isInRange,
    bool? isRangeStart,
    bool? isRangeEnd,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
      isInRange: isInRange ?? this.isInRange,
      isRangeStart: isRangeStart ?? this.isRangeStart,
      isRangeEnd: isRangeEnd ?? this.isRangeEnd,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarDay &&
        other.date.day == date.day &&
        other.date.month == date.month &&
        other.date.year == date.year;
  }

  @override
  int get hashCode => date.hashCode;
}

/// Model đại diện cho date range được chọn
class DateRange {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRange({
    this.startDate,
    this.endDate,
  });

  bool get isValid => startDate != null && endDate != null;
  bool get hasStartDate => startDate != null;
  bool get hasEndDate => endDate != null;
  bool get isEmpty => startDate == null && endDate == null;

  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRange(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  DateRange clear() {
    return const DateRange();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate);

  @override
  String toString() {
    if (isEmpty) return 'DateRange(empty)';
    if (hasStartDate && hasEndDate) {
      return 'DateRange(${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year})';
    }
    if (hasStartDate) {
      return 'DateRange(start: ${startDate!.day}/${startDate!.month}/${startDate!.year})';
    }
    return 'DateRange(incomplete)';
  }
}

/// Model chính cho Calendar Picker state
@immutable
class CalendarPickerState {
  final DateSelectionMode selectionMode;
  final int currentYear;
  final int currentMonth;
  final DateTime? selectedDate;  // Cho single mode
  final DateRange dateRange;     // Cho range mode
  final DateTime today;

  const CalendarPickerState({
    required this.selectionMode,
    required this.currentYear,
    required this.currentMonth,
    this.selectedDate,
    this.dateRange = const DateRange(),
    required this.today,
  });

  factory CalendarPickerState.initial({
    DateSelectionMode mode = DateSelectionMode.single,
  }) {
    final now = DateTime.now();
    return CalendarPickerState(
      selectionMode: mode,
      currentYear: now.year,
      currentMonth: now.month,
      today: DateTime(now.year, now.month, now.day),
    );
  }

  /// Lấy ngày đầu tháng hiện tại
  DateTime get firstDayOfMonth => DateTime(currentYear, currentMonth, 1);
  
  /// Lấy ngày cuối tháng hiện tại
  DateTime get lastDayOfMonth => DateTime(currentYear, currentMonth + 1, 0);

  /// Kiểm tra xem có thể confirm được không
  bool get canConfirm {
    switch (selectionMode) {
      case DateSelectionMode.single:
        return selectedDate != null;
      case DateSelectionMode.range:
        return dateRange.isValid;
    }
  }

  CalendarPickerState copyWith({
    DateSelectionMode? selectionMode,
    int? currentYear,
    int? currentMonth,
    DateTime? selectedDate,
    DateRange? dateRange,
    DateTime? today,
  }) {
    return CalendarPickerState(
      selectionMode: selectionMode ?? this.selectionMode,
      currentYear: currentYear ?? this.currentYear,
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      dateRange: dateRange ?? this.dateRange,
      today: today ?? this.today,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarPickerState &&
        other.selectionMode == selectionMode &&
        other.currentYear == currentYear &&
        other.currentMonth == currentMonth &&
        other.selectedDate == selectedDate &&
        other.dateRange == dateRange &&
        other.today == today;
  }

  @override
  int get hashCode => Object.hash(
        selectionMode,
        currentYear,
        currentMonth,
        selectedDate,
        dateRange,
        today,
      );
}