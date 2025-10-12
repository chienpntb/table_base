import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';
import 'package:table_base/widgets/custom_dropdown_button.dart';
import '../models/calendar_model.dart';
import '../providers/calendar_notifier.dart';

/// Widget để chọn năm và tháng
class CalendarHeaderWidget extends ConsumerStatefulWidget {
  final EdgeInsetsGeometry? paddingHeader;
  const CalendarHeaderWidget({super.key, this.paddingHeader});

  @override
  ConsumerState<CalendarHeaderWidget> createState() =>
      _CalendarHeaderWidgetState();
}

class _CalendarHeaderWidgetState extends ConsumerState<CalendarHeaderWidget> {
  late ScrollController monthScrollController;
  late ScrollController yearScrollController;
  late CustomDropdownController dropdownController;
  final double itemHeight = 34.0;
  final double spacing = 2.0;

  @override
  void initState() {
    super.initState();
    monthScrollController = ScrollController();
    yearScrollController = ScrollController();
    dropdownController = CustomDropdownController();
  }

  @override
  void dispose() {
    monthScrollController.dispose();
    yearScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedItems() {
    final calendarState = ref.read(calendarNotifierProvider);

    // Scroll đến tháng hiện tại
    if (monthScrollController.hasClients &&
        monthScrollController.position.hasContentDimensions) {
      final monthIndex = calendarState.currentMonth - 1;
      final totalItemHeight = itemHeight + spacing;
      final monthOffset = monthIndex * totalItemHeight;

      // Scroll để center item trong view (240px height container, center là 120px)
      final centerOffset = monthOffset - (120 - itemHeight / 2) + itemHeight;
      final maxScroll = monthScrollController.position.maxScrollExtent;
      monthScrollController.jumpTo(centerOffset.clamp(0.0, maxScroll));
    }

    // Scroll đến năm hiện tại
    if (yearScrollController.hasClients &&
        yearScrollController.position.hasContentDimensions) {
      final availableYears = ref.read(availableYearsProvider);
      final yearIndex = availableYears.indexOf(calendarState.currentYear);

      if (yearIndex != -1) {
        final totalItemHeight = itemHeight + spacing;
        final yearOffset = yearIndex * totalItemHeight;

        // Scroll để center item trong view
        final centerOffset = yearOffset - (120 - itemHeight / 2) + itemHeight;
        final maxScroll = yearScrollController.position.maxScrollExtent;

        yearScrollController.jumpTo(centerOffset.clamp(0.0, maxScroll));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final calendarNotifier = ref.read(calendarNotifierProvider.notifier);
    final availableYears = ref.watch(availableYearsProvider);
    final monthNames = ref.watch(monthNamesProvider);

    return Padding(
      padding: widget.paddingHeader ??
          const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút tháng trước
          IconButton(
            onPressed: () => calendarNotifier.previousMonth(),
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Tháng trước',
          ),
          // Dropdown chọn tháng và năm
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomDropdownButton(
                  controller: dropdownController,
                  maxWidth: 240,
                  maxHeight: 240,
                  heightButton: 42,
                  isPositionCenter: true,
                  onDropdownOpened: _scrollToSelectedItems,
                  label:
                      '${monthNames[calendarState.currentMonth - 1]}/${calendarState.currentYear}',
                  widget: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                height: itemHeight,
                                child: Text(
                                  'Tháng',
                                  style: AppFont.titleMedium.copyWith(
                                    color: AppColor.textDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: monthScrollController,
                                  child: Column(
                                    spacing: spacing,
                                    children: List.generate(12, (index) {
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          calendarNotifier.setMonth(index + 1);
                                          dropdownController.close();
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: itemHeight,
                                          decoration: BoxDecoration(
                                            color: index ==
                                                    calendarState.currentMonth -
                                                        1
                                                ? AppColor.greenLight
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              monthNames[index],
                                              style:
                                                  AppFont.titleSmall.copyWith(
                                                color: index ==
                                                        calendarState
                                                                .currentMonth -
                                                            1
                                                    ? AppColor.white
                                                    : AppColor.textDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          color: Colors.grey[300],
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                height: itemHeight,
                                child: Text(
                                  'Năm',
                                  style: AppFont.titleMedium.copyWith(
                                    color: AppColor.textDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: yearScrollController,
                                  child: Column(
                                    spacing: spacing,
                                    children:
                                        availableYears.map<Widget>((year) {
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          calendarNotifier.setYear(year);
                                          dropdownController.close();
                                        },
                                        child: Container(
                                          height: itemHeight,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: year ==
                                                    calendarState.currentYear
                                                ? AppColor.greenLight
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Năm $year",
                                              style:
                                                  AppFont.titleSmall.copyWith(
                                                color: year ==
                                                        calendarState
                                                            .currentYear
                                                    ? AppColor.white
                                                    : AppColor.textDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nút tháng sau
          IconButton(
            onPressed: () => calendarNotifier.nextMonth(),
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Tháng sau',
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị chế độ chọn ngày
class CalendarModeSelector extends ConsumerWidget {
  const CalendarModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final calendarNotifier = ref.read(calendarNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Chế độ chọn:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                // Single mode
                Expanded(
                  child: GestureDetector(
                    onTap: () => calendarNotifier
                        .setSelectionMode(DateSelectionMode.single),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: calendarState.selectionMode ==
                                DateSelectionMode.single
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Chọn 1 ngày',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: calendarState.selectionMode ==
                                  DateSelectionMode.single
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Range mode
                Expanded(
                  child: GestureDetector(
                    onTap: () => calendarNotifier
                        .setSelectionMode(DateSelectionMode.range),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: calendarState.selectionMode ==
                                DateSelectionMode.range
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Chọn khoảng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: calendarState.selectionMode ==
                                  DateSelectionMode.range
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
