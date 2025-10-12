import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';
import 'package:table_base/core/themes/app_icon_svg.dart';
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';

/// Widget hiển thị tiêu đề cột có thể sắp xếp và lọc
class SortableHeaderWidget<T> extends ConsumerWidget {
  /// Tên tiêu đề cột
  final String title;

  /// Chỉ số cột
  final int columnIndex;

  /// Provider quản lý trạng thái bảng
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  >
  tableProvider;

  /// Màu text header
  final Color textHeaderColor;

  /// Số lượng hiển thị tối đa cho filter
  final int showPageSizeFilter;

  /// Callback hiển thị menu lọc
  final Future<void> Function(String, int, Offset) onShowFilterMenu;

  const SortableHeaderWidget({
    super.key,
    required this.title,
    required this.columnIndex,
    required this.tableProvider,
    required this.textHeaderColor,
    required this.showPageSizeFilter,
    required this.onShowFilterMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);
    final isCurrentSortColumn = tableState.sortState.columnIndex == columnIndex;
    final isFilterable = _isColumnFilterable();
    final currentFilter = tableState.filterState.columnFilters[columnIndex];

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Khoảng cách cho icon filter
        if (isFilterable) const SizedBox(width: 20),

        // Khoảng cách cho icon sắp xếp
        if (isCurrentSortColumn) const SizedBox(width: 12),

        // Text tiêu đề
        Expanded(
          child: Text(
            title,
            style: AppFont.buttonText.copyWith(color: textHeaderColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

        // Icon sắp xếp (mũi tên lên/xuống)
        if (isCurrentSortColumn) _buildSortIcons(tableState),

        // Icon lọc
        if (isFilterable) _buildFilterIcon(currentFilter),
      ],
    );
  }

  /// Kiểm tra xem cột có thể lọc được không
  bool _isColumnFilterable() {
    // Logic kiểm tra filterable sẽ được implement dựa trên cấu hình cột
    // Tạm thời return true để hiển thị icon filter
    return true;
  }

  /// Xây dựng icon sắp xếp (mũi tên lên/xuống)
  Widget _buildSortIcons(GenericTableState<T> tableState) {
    return SizedBox(
      width: 12,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mũi tên lên
          SvgPicture.asset(
            AppIconSvg.iconArrowUp,
            width: 6,
            height: 6,
            colorFilter: ColorFilter.mode(
              !tableState.sortState.ascending
                  ? textHeaderColor
                  : AppColor.textGrey,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 2),
          // Mũi tên xuống
          SvgPicture.asset(
            AppIconSvg.iconArrowDown,
            width: 6,
            height: 6,
            colorFilter: ColorFilter.mode(
              tableState.sortState.ascending
                  ? textHeaderColor
                  : AppColor.textGrey,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng icon lọc với indicator
  Widget _buildFilterIcon(dynamic currentFilter) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown:
              (details) =>
                  onShowFilterMenu(title, columnIndex, details.globalPosition),
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Icon filter
                SvgPicture.asset(
                  AppIconSvg.iconFunnel,
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    textHeaderColor,
                    BlendMode.srcIn,
                  ),
                ),
                // Indicator đỏ khi có filter active
                if (currentFilter != null)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}
