import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_model.dart';
import '../providers/calendar_notifier.dart';

/// Widget hiển thị grid các ngày trong tháng
class CalendarGridWidget extends ConsumerWidget {
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? backgroundGridColor;
  final Color? selectedColor;
  final Color? inRangeColor;
  final Color? rangeStartColor;
  final Color? rangeEndColor;
  final Color? textColor;
  final Color? todayColor;
  final Color? textSelectedColor;
  final Color? textTodayColor;
  final Color? textCurrentMonthColor;
  final double? textFontSize;
  final TextStyle? textFontStyle;
  final FontWeight? textFontWeight;
  final FontWeight? textTodayFontWeight;
  final EdgeInsetsGeometry? padding;

  const CalendarGridWidget({
    super.key,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.backgroundGridColor,
    this.selectedColor,
    this.inRangeColor,
    this.rangeStartColor,
    this.rangeEndColor,
    this.textColor,
    this.textFontWeight,
    this.textTodayFontWeight,
    this.textFontSize,
    this.textFontStyle,
    this.textSelectedColor,
    this.textTodayColor,
    this.textCurrentMonthColor,
    this.todayColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state để widget được rebuild khi state thay đổi
    ref.watch(calendarNotifierProvider);
    final calendarNotifier = ref.read(calendarNotifierProvider.notifier);
    final weekDayNames = ref.watch(weekDayNamesProvider);
    final calendarDays = calendarNotifier.getCalendarDays();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Header với tên các ngày trong tuần
          _buildWeekDayHeader(weekDayNames),
          // Grid các ngày
          _buildCalendarGrid(context, calendarDays, calendarNotifier),
        ],
      ),
    );
  }

  /// Xây dựng header với tên các ngày trong tuần
  Widget _buildWeekDayHeader(List<String> weekDayNames) {
    return SizedBox(
      height: 32,
      child: Row(
        children: weekDayNames.map((dayName) {
          return Expanded(
            child: Center(
              child: Text(
                dayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Xây dựng grid các ngày
  Widget _buildCalendarGrid(
    BuildContext context,
    List<CalendarDay> calendarDays,
    CalendarNotifier calendarNotifier,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: childAspectRatio ?? 1,
        crossAxisSpacing: crossAxisSpacing ?? 2,
        mainAxisSpacing: mainAxisSpacing ?? 2,
      ),
      itemCount: calendarDays.length,
      itemBuilder: (context, index) {
        final day = calendarDays[index];
        return _buildDayCell(context, day, calendarNotifier);
      },
    );
  }

  /// Xây dựng một ô ngày
  Widget _buildDayCell(
    BuildContext context,
    CalendarDay day,
    CalendarNotifier calendarNotifier,
  ) {
    return GestureDetector(
      onTap: () {
        if (day.isCurrentMonth) {
          calendarNotifier.selectDate(day.date);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getDayBackgroundColor(context, day),
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          border: day.isToday
              ? border ??
                  Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1.4,
                  )
              : null,
        ),
        child: Center(
          child: Text(
            day.date.day.toString(),
            style: textFontStyle ??
                TextStyle(
                  fontSize: textFontSize ?? 14,
                  fontWeight: _getDayFontWeight(day),
                  color: _getDayTextColor(context, day),
                ),
          ),
        ),
      ),
    );
  }

  /// Lấy màu nền cho ô ngày
  Color _getDayBackgroundColor(BuildContext context, CalendarDay day) {
    if (day.isSelected) {
      return selectedColor ?? Theme.of(context).primaryColor;
    }

    if (day.isToday) {
      return todayColor ??
          Theme.of(context).primaryColor.withValues(alpha: 0.2);
    }

    if (day.isInRange) {
      return inRangeColor ?? Theme.of(context).primaryColor;
    }

    if (day.isRangeStart) {
      return rangeStartColor ?? Theme.of(context).primaryColor;
    }

    if (day.isRangeEnd) {
      return rangeEndColor ?? Theme.of(context).primaryColor;
    }
    if (!day.isCurrentMonth) {
      return Colors.transparent;
    }
    return backgroundGridColor ?? Colors.transparent;
  }

  /// Lấy màu chữ cho ô ngày
  Color _getDayTextColor(BuildContext context, CalendarDay day) {
    if (day.isSelected || day.isRangeStart || day.isRangeEnd) {
      return textSelectedColor ?? Colors.white;
    }

    if (day.isToday) {
      return textTodayColor ?? Theme.of(context).primaryColor;
    }

    if (!day.isCurrentMonth) {
      return textCurrentMonthColor ?? Colors.grey[400]!;
    }

    return textColor ?? Colors.black;
  }

  /// Lấy độ đậm của font cho ô ngày
  FontWeight _getDayFontWeight(CalendarDay day) {
    if (day.isSelected || day.isToday || day.isRangeStart || day.isRangeEnd) {
      return textTodayFontWeight ?? FontWeight.w600;
    }
    return textFontWeight ?? FontWeight.normal;
  }
}
