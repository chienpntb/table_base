import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/calendar_model.dart';

part 'calendar_notifier.g.dart';

@riverpod
class CalendarNotifier extends _$CalendarNotifier {
  @override
  CalendarPickerState build() {
    return CalendarPickerState.initial();
  }

  /// Thay đổi chế độ chọn ngày (single/range) - Updated comment
  void setSelectionMode(DateSelectionMode mode) {
    state = state.copyWith(
      selectionMode: mode,
      selectedDate: null,
      dateRange: const DateRange(),
    );
  }

  /// Thay đổi năm hiện tại
  void setYear(int year) {
    state = state.copyWith(currentYear: year);
  }

  /// Thay đổi tháng hiện tại
  void setMonth(int month) {
    state = state.copyWith(currentMonth: month);
  }

  /// Chuyển sang tháng trước
  void previousMonth() {
    if (state.currentMonth == 1) {
      state = state.copyWith(
        currentMonth: 12,
        currentYear: state.currentYear - 1,
      );
    } else {
      state = state.copyWith(currentMonth: state.currentMonth - 1);
    }
  }

  /// Chuyển sang tháng sau
  void nextMonth() {
    if (state.currentMonth == 12) {
      state = state.copyWith(
        currentMonth: 1,
        currentYear: state.currentYear + 1,
      );
    } else {
      state = state.copyWith(currentMonth: state.currentMonth + 1);
    }
  }

  /// Chọn ngày
  void selectDate(DateTime date) {
    switch (state.selectionMode) {
      case DateSelectionMode.single:
        _selectSingleDate(date);
        break;
      case DateSelectionMode.range:
        _selectRangeDate(date);
        break;
    }
  }

  /// Chọn ngày cho chế độ single
  void _selectSingleDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// Chọn ngày cho chế độ range
  void _selectRangeDate(DateTime date) {
    final currentRange = state.dateRange;
    
    // Nếu chưa có ngày nào được chọn hoặc đã có cả start và end
    if (currentRange.isEmpty || currentRange.isValid) {
      state = state.copyWith(
        dateRange: DateRange(startDate: date),
      );
    } 
    // Nếu chỉ có start date
    else if (currentRange.hasStartDate && !currentRange.hasEndDate) {
      final startDate = currentRange.startDate!;
      
      // Nếu ngày được chọn trước ngày start, thì đặt nó làm start mới
      if (date.isBefore(startDate)) {
        state = state.copyWith(
          dateRange: DateRange(startDate: date),
        );
      } 
      // Nếu ngày được chọn sau ngày start, thì đặt nó làm end
      else {
        state = state.copyWith(
          dateRange: DateRange(
            startDate: startDate,
            endDate: date,
          ),
        );
      }
    }
  }

  /// Xóa lựa chọn (dành cho range mode)
  void clearSelection() {
    switch (state.selectionMode) {
      case DateSelectionMode.single:
        state = state.copyWith(selectedDate: null);
        break;
      case DateSelectionMode.range:
        state = state.copyWith(dateRange: const DateRange());
        break;
    }
  }

  /// Reset về trạng thái ban đầu
  void reset() {
    state = CalendarPickerState.initial(mode: state.selectionMode);
  }

  /// Lấy danh sách các ngày trong tháng để hiển thị
  List<CalendarDay> getCalendarDays() {
    final firstDay = state.firstDayOfMonth;
    
    // Tìm ngày đầu tiên của tuần chứa ngày đầu tháng
    // weekday: Monday = 1, Sunday = 7
    // Chúng ta muốn Sunday = 0, Monday = 1, ...
    int daysFromSunday = firstDay.weekday % 7;
    final startOfCalendar = firstDay.subtract(Duration(days: daysFromSunday));
    
    // Tạo danh sách 35 ngày (5 tuần x 7 ngày)
    final days = <CalendarDay>[];
    
    for (int i = 0; i < 35; i++) {
      final date = startOfCalendar.add(Duration(days: i));
      final isCurrentMonth = date.month == state.currentMonth;
      final isToday = _isSameDay(date, state.today);
      
      bool isSelected = false;
      bool isInRange = false;
      bool isRangeStart = false;
      bool isRangeEnd = false;

      // Xác định trạng thái selected/range cho ngày
      switch (state.selectionMode) {
        case DateSelectionMode.single:
          isSelected = state.selectedDate != null && 
                      _isSameDay(date, state.selectedDate!);
          break;
        case DateSelectionMode.range:
          final range = state.dateRange;
          if (range.hasStartDate) {
            isRangeStart = _isSameDay(date, range.startDate!);
            
            if (range.hasEndDate) {
              isRangeEnd = _isSameDay(date, range.endDate!);
              isInRange = !isRangeStart && !isRangeEnd && 
                         date.isAfter(range.startDate!) && 
                         date.isBefore(range.endDate!);
            }
          }
          isSelected = isRangeStart || isRangeEnd;
          break;
      }

      days.add(CalendarDay(
        date: date,
        isCurrentMonth: isCurrentMonth,
        isToday: isToday,
        isSelected: isSelected,
        isInRange: isInRange,
        isRangeStart: isRangeStart,
        isRangeEnd: isRangeEnd,
      ));
    }
    
    return days;
  }

  /// Kiểm tra hai ngày có cùng ngày không
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

/// Provider cho danh sách năm có thể chọn
final availableYearsProvider = Provider<List<int>>((ref) {
  final currentYear = DateTime.now().year;
  final years = <int>[];
  
  // Tạo danh sách từ 100 năm trước đến 100 năm sau
  for (int i = currentYear - 100; i <= currentYear + 100; i++) {
    years.add(i);
  }
  
  return years;
});

/// Provider cho tên tháng
final monthNamesProvider = Provider<List<String>>((ref) {
  return [
    'Tháng 1',
    'Tháng 2', 
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12',
  ];
});

/// Provider cho tên các ngày trong tuần
final weekDayNamesProvider = Provider<List<String>>((ref) {
  return ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
});