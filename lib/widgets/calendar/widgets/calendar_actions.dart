import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';
import '../models/calendar_model.dart';
import '../providers/calendar_notifier.dart';

/// Widget chứa các nút action ở dưới cùng của calendar
class CalendarBottomActions extends ConsumerWidget {
  final VoidCallback? onCancel;
  final Function(DateTime?, DateRange?)? onConfirm;

  const CalendarBottomActions({
    super.key,
    this.onCancel,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final calendarNotifier = ref.read(calendarNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 16, right: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút bỏ chọn (chỉ hiển thị khi ở range mode và có selection)
          if (calendarState.selectionMode == DateSelectionMode.range &&
              !calendarState.dateRange.isEmpty)
            _buildClearSelectionButton(context, calendarNotifier),

          // Row chứa nút Huỷ và Xác nhận
          Row(
            children: [
              // Nút Huỷ
              Expanded(
                child: _buildCancelButton(context),
              ),

              const SizedBox(width: 12),

              // Nút Xác nhận
              Expanded(
                child: _buildConfirmButton(context, calendarState),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tạo nút bỏ chọn
  Widget _buildClearSelectionButton(
      BuildContext context, CalendarNotifier notifier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => notifier.clearSelection(),
          icon: const Icon(Icons.clear, size: 18, color: Colors.white),
          label: const Text('Bỏ chọn'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: Colors.redAccent),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }

  /// Tạo nút Huỷ
  Widget _buildCancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (onCancel != null) {
          onCancel!();
        } else {
          Navigator.of(context).pop();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.greenDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        'Huỷ',
        style: AppFont.buttonText.copyWith(color: Colors.white),
      ),
    );
  }

  /// Tạo nút Xác nhận
  Widget _buildConfirmButton(BuildContext context, CalendarPickerState state) {
    final isEnabled = state.canConfirm;

    return ElevatedButton(
      onPressed: isEnabled ? () => _handleConfirm(context, state) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? AppColor.greenLight : Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        disabledBackgroundColor: Colors.grey[300],
        disabledForegroundColor: Colors.grey[500],
      ),
      child: Text(
        'Xác nhận',
        style: AppFont.buttonText
            .copyWith(color: isEnabled ? Colors.white : Colors.grey[400]),
      ),
    );
  }

  /// Xử lý khi nhấn nút Xác nhận
  void _handleConfirm(BuildContext context, CalendarPickerState state) {
    if (onConfirm != null) {
      switch (state.selectionMode) {
        case DateSelectionMode.single:
          onConfirm!(state.selectedDate, null);
          break;
        case DateSelectionMode.range:
          onConfirm!(null, state.dateRange);
          break;
      }
    } else {
      // Default behavior: return result via Navigator
      switch (state.selectionMode) {
        case DateSelectionMode.single:
          Navigator.of(context).pop(state.selectedDate);
          break;
        case DateSelectionMode.range:
          Navigator.of(context).pop(state.dateRange);
          break;
      }
    }
  }
}

/// Widget hiển thị trạng thái selection ở dưới cùng
class CalendarSelectionStatus extends ConsumerWidget {
  const CalendarSelectionStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarNotifierProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildStatusText(context, calendarState),
    );
  }

  Widget _buildStatusText(BuildContext context, CalendarPickerState state) {
    switch (state.selectionMode) {
      case DateSelectionMode.single:
        if (state.selectedDate == null) {
          return Text(
            'Chọn ngày',
            style: AppFont.titleMedium.copyWith(color: AppColor.textDark),
          );
        }
        return Text(
          '${state.selectedDate!.day}/${state.selectedDate!.month}/${state.selectedDate!.year}',
          style: AppFont.titleMedium.copyWith(color: AppColor.textDark),
        );

      case DateSelectionMode.range:
        final range = state.dateRange;

        if (range.isEmpty) {
          return Text(
            '--/--/---- - --/--/----',
            style: AppFont.titleMedium.copyWith(color: AppColor.textDark),
          );
        }

        if (range.hasStartDate && !range.hasEndDate) {
          return Text(
            '${range.startDate!.day}/${range.startDate!.month}/${range.startDate!.year} - --/--/----',
            style: AppFont.titleMedium.copyWith(color: AppColor.textDark),
          );
        }

        if (range.isValid) {
          return Text(
            '${range.startDate!.day}/${range.startDate!.month}/${range.startDate!.year} - ${range.endDate!.day}/${range.endDate!.month}/${range.endDate!.year}',
            style: AppFont.titleMedium.copyWith(color: AppColor.textDark),
          );
        }

        return const SizedBox.shrink();
    }
  }
}
