import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';
import '../models/calendar_model.dart';
import '../providers/calendar_notifier.dart';
import 'calendar_header.dart';
import 'calendar_grid.dart';
import 'calendar_actions.dart';

/// Custom Calendar Picker Widget chính
class CustomCalendarPicker extends ConsumerStatefulWidget {
  final DateSelectionMode initialMode;
  final DateTime? initialDate;
  final DateRange? initialDateRange;
  final VoidCallback? onCancel;
  final Function(DateTime?, DateRange?)? onConfirm;
  final bool showModeSelector;
  final bool showSelectionInfo;
  final double? maxHeight;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final void Function(DateRange?)? onRangeChanged;
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
  final bool isShowSelectionStatus;
  final bool isShowBottomActions;
  final bool isBoxDecoration;
  final EdgeInsetsGeometry? paddingHeader;
  final EdgeInsetsGeometry? paddingGrid;

  const CustomCalendarPicker({
    super.key,
    this.initialMode = DateSelectionMode.single,
    this.initialDate,
    this.initialDateRange,
    this.onCancel,
    this.onConfirm,
    this.showModeSelector = true,
    this.showSelectionInfo = true,
    this.maxHeight,
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
    this.todayColor,
    this.textSelectedColor,
    this.textTodayColor,
    this.textCurrentMonthColor,
    this.textFontSize,
    this.textFontStyle,
    this.textFontWeight,
    this.textTodayFontWeight,
    this.isShowSelectionStatus = true,
    this.isShowBottomActions = true,
    this.isBoxDecoration = true,
    this.paddingHeader,
    this.paddingGrid,
    this.onRangeChanged,
  });

  @override
  ConsumerState<CustomCalendarPicker> createState() =>
      _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends ConsumerState<CustomCalendarPicker> {
  final List<String> listDate = [
    'Hôm nay',
    '7 ngày qua',
    '30 ngày qua',
    'Tháng này',
    'Tháng trước',
    'Chọn khoảng',
  ];
  String? _hoveredValue;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();

    // Khởi tạo state ban đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(calendarNotifierProvider.notifier);

      // Set mode
      notifier.setSelectionMode(widget.initialMode);

      // Set initial values
      if (widget.initialDate != null) {
        notifier.selectDate(widget.initialDate!);
        notifier.setYear(widget.initialDate!.year);
        notifier.setMonth(widget.initialDate!.month);
      } else if (widget.initialDateRange != null &&
          widget.initialDateRange!.hasStartDate) {
        notifier.selectDate(widget.initialDateRange!.startDate!);
        if (widget.initialDateRange!.hasEndDate) {
          notifier.selectDate(widget.initialDateRange!.endDate!);
        }
        notifier.setYear(widget.initialDateRange!.startDate!.year);
        notifier.setMonth(widget.initialDateRange!.startDate!.month);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi date range để callback trực tiếp không cần onConfirm
    ref.listen<DateRange>(
      calendarNotifierProvider.select((state) => state.dateRange),
      (previous, next) {
        if (previous != next) {
          widget.onRangeChanged?.call(next);
        }
      },
    );
    return Container(
      padding: const EdgeInsets.only(top: 12),
      constraints: widget.maxHeight != null
          ? BoxConstraints(maxHeight: widget.maxHeight!)
          : null,
      decoration: widget.isBoxDecoration
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Column(
              children: [
                ...listDate.map(
                  (value) {
                    return InkWell(
                      onTap: () {
                        final notifier =
                            ref.read(calendarNotifierProvider.notifier);
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);

                        if (value == 'Hôm nay') {
                          notifier.setSelectionMode(DateSelectionMode.single);
                          notifier.selectDate(today);
                          notifier.setYear(today.year);
                          notifier.setMonth(today.month);
                          setState(() {
                            _selectedValue = value;
                          });
                          return;
                        }

                        if (value == '7 ngày qua') {
                          final start = today.subtract(const Duration(days: 6));
                          notifier.setSelectionMode(DateSelectionMode.range);
                          notifier.setYear(start.year);
                          notifier.setMonth(start.month);
                          notifier.selectDate(start);
                          notifier.selectDate(today);
                          setState(() {
                            _selectedValue = value;
                          });
                          return;
                        }

                        if (value == '30 ngày qua') {
                          final start =
                              today.subtract(const Duration(days: 29));
                          notifier.setSelectionMode(DateSelectionMode.range);
                          notifier.setYear(start.year);
                          notifier.setMonth(start.month);
                          notifier.selectDate(start);
                          notifier.selectDate(today);
                          setState(() {
                            _selectedValue = value;
                          });
                          return;
                        }

                        if (value == 'Tháng này') {
                          final start = DateTime(today.year, today.month, 1);
                          final end = today;
                          notifier.setSelectionMode(DateSelectionMode.range);
                          notifier.setYear(start.year);
                          notifier.setMonth(start.month);
                          notifier.selectDate(start);
                          notifier.selectDate(end);
                          setState(() {
                            _selectedValue = value;
                          });
                          return;
                        }

                        if (value == 'Tháng trước') {
                          final firstOfThisMonth =
                              DateTime(today.year, today.month, 1);
                          final lastOfPrevMonth = firstOfThisMonth
                              .subtract(const Duration(days: 1));
                          final startPrev = DateTime(
                              lastOfPrevMonth.year, lastOfPrevMonth.month, 1);
                          final endPrev = lastOfPrevMonth;
                          notifier.setSelectionMode(DateSelectionMode.range);
                          notifier.setYear(startPrev.year);
                          notifier.setMonth(startPrev.month);
                          notifier.selectDate(startPrev);
                          notifier.selectDate(endPrev);
                          setState(() {
                            _selectedValue = value;
                          });
                          return;
                        }

                        if (value == 'Chọn khoảng') {
                          notifier.setSelectionMode(DateSelectionMode.range);
                          notifier.clearSelection();
                          setState(() {
                            _selectedValue = value;
                          });
                          return;
                        }
                      },
                      onHover: (isHover) {
                        setState(() {
                          _hoveredValue = isHover ? value : null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _hoveredValue == value
                              ? AppColor.greenLight
                              : _selectedValue == value
                                  ? AppColor.greenLight
                                  : AppColor.white,
                        ),
                        child: Center(
                          child: Text(
                            value,
                            style: AppFont.buttonText.copyWith(
                              color: _hoveredValue == value
                                  ? AppColor.textWhite
                                  : _selectedValue == value
                                      ? AppColor.textWhite
                                      : AppColor.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header với navigation và year/month selection
                  CalendarHeaderWidget(paddingHeader: widget.paddingHeader),

                  // Mode selector (nếu enabled)
                  if (widget.showModeSelector) const CalendarModeSelector(),

                  CalendarGridWidget(
                    padding: widget.paddingGrid,
                    childAspectRatio: widget.childAspectRatio,
                    crossAxisSpacing: widget.crossAxisSpacing,
                    mainAxisSpacing: widget.mainAxisSpacing,
                    backgroundColor: widget.backgroundColor,
                    borderRadius: widget.borderRadius,
                    border: widget.border,
                    backgroundGridColor: widget.backgroundGridColor,
                    selectedColor: widget.selectedColor,
                    inRangeColor: widget.inRangeColor,
                    rangeStartColor: widget.rangeStartColor,
                    rangeEndColor: widget.rangeEndColor,
                    textColor: widget.textColor,
                    todayColor: widget.todayColor,
                    textSelectedColor: widget.textSelectedColor,
                    textTodayColor: widget.textTodayColor,
                    textCurrentMonthColor: widget.textCurrentMonthColor,
                    textFontSize: widget.textFontSize,
                    textFontStyle: widget.textFontStyle,
                    textFontWeight: widget.textFontWeight,
                    textTodayFontWeight: widget.textTodayFontWeight,
                  ),
                  if (!widget.isShowSelectionStatus) const SizedBox(height: 12),
                  // Selection status
                  if (widget.isShowSelectionStatus)
                    const CalendarSelectionStatus(),
                  // Bottom actions
                  if (widget.isShowBottomActions)
                    CalendarBottomActions(
                      onCancel: widget.onCancel,
                      onConfirm: widget.onConfirm,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog wrapper cho Calendar Picker
class CalendarPickerDialog extends StatelessWidget {
  final DateSelectionMode initialMode;
  final DateTime? initialDate;
  final DateRange? initialDateRange;
  final bool showModeSelector;

  const CalendarPickerDialog({
    super.key,
    this.initialMode = DateSelectionMode.single,
    this.initialDate,
    this.initialDateRange,
    this.showModeSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 650, // Tăng từ 600 lên 650
        ),
        child: CustomCalendarPicker(
          initialMode: initialMode,
          initialDate: initialDate,
          initialDateRange: initialDateRange,
          showModeSelector: showModeSelector,
          maxHeight: 600, // Tăng từ 550 lên 600
        ),
      ),
    );
  }

  /// Show calendar picker dialog
  static Future<T?> show<T>(
    BuildContext context, {
    DateSelectionMode initialMode = DateSelectionMode.single,
    DateTime? initialDate,
    DateRange? initialDateRange,
    bool showModeSelector = true,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => CalendarPickerDialog(
        initialMode: initialMode,
        initialDate: initialDate,
        initialDateRange: initialDateRange,
        showModeSelector: showModeSelector,
      ),
    );
  }
}

/// Bottom sheet wrapper cho Calendar Picker
class CalendarPickerBottomSheet extends StatelessWidget {
  final DateSelectionMode initialMode;
  final DateTime? initialDate;
  final DateRange? initialDateRange;
  final bool showModeSelector;

  const CalendarPickerBottomSheet({
    super.key,
    this.initialMode = DateSelectionMode.single,
    this.initialDate,
    this.initialDateRange,
    this.showModeSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Calendar picker
          Flexible(
            child: CustomCalendarPicker(
              initialMode: initialMode,
              initialDate: initialDate,
              initialDateRange: initialDateRange,
              showModeSelector: showModeSelector,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
          ),
        ],
      ),
    );
  }

  /// Show calendar picker bottom sheet
  static Future<T?> show<T>(
    BuildContext context, {
    DateSelectionMode initialMode = DateSelectionMode.single,
    DateTime? initialDate,
    DateRange? initialDateRange,
    bool showModeSelector = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarPickerBottomSheet(
        initialMode: initialMode,
        initialDate: initialDate,
        initialDateRange: initialDateRange,
        showModeSelector: showModeSelector,
      ),
    );
  }
}
