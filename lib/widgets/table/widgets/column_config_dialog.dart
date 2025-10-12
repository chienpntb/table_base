import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';
import 'package:table_base/core/themes/app_icon_svg.dart';
import 'package:table_base/widgets/box_search.dart';
import 'package:table_base/widgets/table/models/table_model.dart';

// Dialog cấu hình cột tái sử dụng cho nhiều màn hình bảng.
// Quy ước sử dụng thuộc tính của TableColumnData:
// - isConfigured == true: cột tham gia cấu hình (có thể ẩn/hiện, sắp xếp nếu đồng thời isFixed == true)
// - isConfigured == false: cột không xuất hiện trong dialog và luôn hiển thị
// - isFixed == true: cột cho phép chỉnh trong dialog (ẩn/hiện, kéo sắp xếp)
// - isFixed == false: cột bị khóa trong dialog (không kéo, không ẩn)

class ColumnConfigResult {
  final List<String> hiddenKeys;
  final List<String> visibleConfiguredOrderKeys;

  ColumnConfigResult({
    required this.hiddenKeys,
    required this.visibleConfiguredOrderKeys,
  });
}

// Kết quả áp dụng cấu hình: dùng khi muốn nhận lại danh sách cột đã cập nhật để setState trực tiếp
class ColumnConfigApplyResult {
  final List<String> hiddenKeys;
  final List<TableColumnData> updatedColumns;

  ColumnConfigApplyResult({
    required this.hiddenKeys,
    required this.updatedColumns,
  });
}

// Hàm nội bộ mở dialog và trả về kết quả cấu hình (không áp dụng vào danh sách cột)
Future<ColumnConfigResult?> _showColumnConfigDialog({
  required BuildContext context,
  required List<TableColumnData> allColumns,
  required List<String> initialHiddenKeys,
  List<String>? initialVisibleOrderKeys,
  double? width,
  double? height,
  String title = 'Cấu hình cột',
}) {
  // Default hidden keys nên là các cột có isVisible=false, không phải cột không có trong definitions
  final defaultHiddenKeys =
      allColumns
          .where((c) => c.isConfigured && !c.isVisible)
          .map((c) => c.key)
          .toList();

  return showDialog<ColumnConfigResult>(
    context: context,
    builder:
        (context) => _ColumnConfigDialog(
          allColumns: allColumns,
          initialHiddenKeys: initialHiddenKeys,
          initialVisibleOrderKeys: initialVisibleOrderKeys,
          defaultHiddenKeys: defaultHiddenKeys,
          width: width ?? MediaQuery.of(context).size.width * 0.6,
          height: height ?? MediaQuery.of(context).size.height * 0.8,
          title: title,
        ),
  );
}

// Hàm tiện ích bên ngoài: mở dialog và trả về kết quả đã được áp dụng vào danh sách cột hiện tại
Future<ColumnConfigApplyResult?> showColumnConfigAndApply({
  required BuildContext context,
  required List<TableColumnData> allColumns,
  required List<TableColumnData> currentColumns,
  required List<String> initialHiddenKeys,
  double? width,
  double? height,
  String title = 'Cấu hình cột',
}) async {
  // Tính toán hiddenKeys dựa trên currentColumns thực tế để dialog hiển thị đúng trạng thái
  final currentVisibleKeys = currentColumns.map((c) => c.key).toList();
  final actualHiddenKeys = allColumns
      .where((c) => c.isConfigured && !currentVisibleKeys.contains(c.key))
      .map((c) => c.key)
      .toList(growable: false);
  final seedHiddenKeys =
      actualHiddenKeys.isNotEmpty ? actualHiddenKeys : initialHiddenKeys;

  final result = await _showColumnConfigDialog(
    context: context,
    allColumns: allColumns,
    initialHiddenKeys: seedHiddenKeys,
    initialVisibleOrderKeys: currentColumns.map((e) => e.key).toList(),
    width: width,
    height: height,
    title: title,
  );
  if (result == null) return null;

  // Dùng toàn bộ cột cấu hình được (allColumns) để có thể khôi phục cả các cột
  // đã bị ẩn và không còn nằm trong currentColumns.
  final configuredMap = {
    for (final c in allColumns.where((c) => c.isConfigured)) c.key: c,
  };
  final reorderedConfigured = <TableColumnData>[];
  for (final key in result.visibleConfiguredOrderKeys) {
    final col = configuredMap[key];
    if (col != null) reorderedConfigured.add(col);
  }
  // Thêm các cột cấu hình còn lại (không nằm trong thứ tự hiển thị mới)
  for (final col in allColumns.where((c) => c.isConfigured)) {
    if (!result.visibleConfiguredOrderKeys.contains(col.key)) {
      reorderedConfigured.add(col);
    }
  }
  // Cột không cấu hình giữ nguyên theo currentColumns
  final nonConfig = currentColumns.where((c) => !c.isConfigured).toList();
  // Loại bỏ các cột đã bị ẩn (hiddenKeys) khỏi danh sách cấu hình
  final filteredConfigured = reorderedConfigured
      .where((c) => !result.hiddenKeys.contains(c.key))
      .toList(growable: false);
  final updatedColumns = [...nonConfig, ...filteredConfigured];

  return ColumnConfigApplyResult(
    hiddenKeys: result.hiddenKeys,
    updatedColumns: updatedColumns,
  );
}

class _ColumnConfigDialog extends StatefulWidget {
  final List<TableColumnData> allColumns;
  final List<String> initialHiddenKeys;
  final List<String>? initialVisibleOrderKeys;
  final List<String>? defaultHiddenKeys;
  final double width;
  final double height;
  final String title;

  const _ColumnConfigDialog({
    required this.allColumns,
    required this.initialHiddenKeys,
    required this.initialVisibleOrderKeys,
    this.defaultHiddenKeys,
    required this.width,
    required this.height,
    required this.title,
  });

  @override
  State<_ColumnConfigDialog> createState() => _ColumnConfigDialogState();
}

class _ColumnConfigDialogState extends State<_ColumnConfigDialog> {
  late List<TableColumnData> visible;
  late List<TableColumnData> hidden;
  String searchQuery = '';
  List<TableColumnData> get configurableAll =>
      widget.allColumns.where((c) => c.isConfigured).toList(growable: false);
  List<TableColumnData> get filteredConfigurable => configurableAll
      .where((c) => c.name.toLowerCase().contains(searchQuery))
      .toList(growable: false);
  List<TableColumnData> get visibleConfigurable =>
      visible.where((c) => c.isConfigured).toList(growable: false);

  void _setVisibility(TableColumnData col, bool show) {
    final hiddenIndex = hidden.indexWhere((e) => e.key == col.key);
    final visibleIndex = visible.indexWhere((e) => e.key == col.key);
    if (show) {
      if (visibleIndex == -1) {
        if (hiddenIndex != -1) {
          final moved = hidden.removeAt(hiddenIndex);
          visible.add(moved);
        } else {
          visible.add(col);
        }
      }
    } else {
      if (hiddenIndex == -1) {
        if (visibleIndex != -1) {
          final moved = visible.removeAt(visibleIndex);
          hidden.add(moved);
        } else {
          hidden.add(col);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    visible = widget.allColumns
        .where((c) => !widget.initialHiddenKeys.contains(c.key))
        .toList(growable: true);
    hidden = widget.allColumns
        .where((c) => widget.initialHiddenKeys.contains(c.key))
        .toList(growable: true);
    // Force non-configurable columns to be visible
    for (final col in widget.allColumns.where((c) => !c.isConfigured)) {
      hidden.removeWhere((h) => h.key == col.key);
      if (!visible.any((v) => v.key == col.key)) visible.add(col);
    }
    // Reorder visible according to provided initial order keys (if any)
    final keysOrder = widget.initialVisibleOrderKeys;
    if (keysOrder != null && keysOrder.isNotEmpty) {
      final orderIndex = {
        for (int i = 0; i < keysOrder.length; i++) keysOrder[i]: i,
      };
      visible.sort((a, b) {
        final ia = orderIndex[a.key] ?? 1 << 30;
        final ib = orderIndex[b.key] ?? 1 << 30;
        return ia.compareTo(ib);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      actionsPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          width: widget.width,
          height: widget.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 8,
                  top: 6,
                  bottom: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: AppFont.titleMedium.copyWith(
                        color: AppColor.textDark,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              ),
              Divider(
                color: AppColor.textGrey.withValues(alpha: .2),
                height: 0.3,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 16, top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: BoxSearch(
                                width: double.infinity,
                                onSearch: (value) {
                                  setState(() {
                                    searchQuery = value.trim().toLowerCase();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Builder(
                                builder: (context) {
                                  // Calculate master checkbox state for editable (isFixed) items within current filter
                                  final editableInFiltered =
                                      filteredConfigurable
                                          .where((c) => c.isFixed)
                                          .toList(growable: false);
                                  final editableCount =
                                      editableInFiltered.length;
                                  final editableVisibleCount =
                                      editableInFiltered
                                          .where(
                                            (c) => visible.any(
                                              (v) => v.key == c.key,
                                            ),
                                          )
                                          .length;
                                  final bool allVisible =
                                      editableCount > 0 &&
                                      editableVisibleCount == editableCount;
                                  final bool noneVisible =
                                      editableCount == 0 ||
                                      editableVisibleCount == 0;
                                  final bool? masterValue =
                                      editableCount == 0
                                          ? false
                                          : (allVisible
                                              ? true
                                              : (noneVisible ? false : null));

                                  return Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.9,
                                        child: Checkbox(
                                          tristate: true,
                                          activeColor: AppColor.greenLight,
                                          checkColor: Colors.white,
                                          splashRadius: 0,
                                          side: const BorderSide(
                                            color: AppColor.textGrey,
                                            width: 1.2,
                                          ),
                                          value: masterValue,
                                          onChanged:
                                              editableCount == 0
                                                  ? null
                                                  : (value) {
                                                    setState(() {
                                                      final bool shouldShow =
                                                          value == true;
                                                      for (final col
                                                          in editableInFiltered) {
                                                        _setVisibility(
                                                          col,
                                                          shouldShow,
                                                        );
                                                      }
                                                    });
                                                  },
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Chọn tất cả',
                                        style: AppFont.bodyMedium.copyWith(
                                          color: AppColor.textDark,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(right: 16),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 8,
                                      ),
                                  itemCount: filteredConfigurable.length,
                                  itemBuilder: (context, index) {
                                    final col = filteredConfigurable[index];
                                    final isVisible = visible.any(
                                      (e) => e.key == col.key,
                                    );
                                    final bool isEditable = col.isFixed;
                                    return Row(
                                      children: [
                                        Transform.scale(
                                          scale: 0.9,
                                          child: Checkbox(
                                            activeColor: AppColor.greenLight,
                                            checkColor: Colors.white,
                                            splashRadius: 0,
                                            side: const BorderSide(
                                              color: AppColor.textGrey,
                                              width: 1.2,
                                            ),
                                            value:
                                                !isEditable ? true : isVisible,
                                            onChanged:
                                                !isEditable
                                                    ? null
                                                    : (value) {
                                                      setState(() {
                                                        _setVisibility(
                                                          col,
                                                          value == true,
                                                        );
                                                      });
                                                    },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          col.name,
                                          style: AppFont.bodyMedium.copyWith(
                                            color: AppColor.textDark,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: AppColor.backgroundMain,
                        padding: const EdgeInsets.only(left: 16, top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cột đang hiển thị',
                              style: AppFont.titleMedium.copyWith(
                                color: AppColor.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ReorderableListView.builder(
                                buildDefaultDragHandles: false,
                                itemCount: visibleConfigurable.length,
                                proxyDecorator:
                                    (child, index, animation) =>
                                        AnimatedBuilder(
                                          animation: animation,
                                          builder: (context, child) {
                                            final scale =
                                                1.0 + (animation.value * 0.05);
                                            return Transform.scale(
                                              scale: scale,
                                              child: Opacity(
                                                opacity: 0.95,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: child,
                                        ),
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    final configIndices = <int>[];
                                    for (int i = 0; i < visible.length; i++) {
                                      if (visible[i].isConfigured) {
                                        configIndices.add(i);
                                      }
                                    }
                                    if (newIndex > oldIndex) newIndex -= 1;
                                    final int from = configIndices[oldIndex];
                                    final int to = configIndices[newIndex];
                                    final moved = visible.removeAt(from);
                                    final insertIndex = to > from ? to - 0 : to;
                                    visible.insert(insertIndex, moved);
                                  });
                                },
                                mouseCursor: SystemMouseCursors.click,
                                itemBuilder: (context, index) {
                                  final col = visibleConfigurable[index];
                                  final bool isEditable = col.isFixed;
                                  return Container(
                                    key: ValueKey(col.key),
                                    child: ReorderableDragStartListener(
                                      index: index,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: .1,
                                              ),
                                              blurRadius: 1,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        margin: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 6,
                                          right: 16,
                                        ),
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              AppIconSvg.iconGripVertical,
                                              width: 16,
                                              height: 16,
                                            ),
                                            Text(
                                              col.name,
                                              style: AppFont.bodyMedium
                                                  .copyWith(
                                                    color: AppColor.textDark,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: SvgPicture.asset(
                                                AppIconSvg.iconCircleX,
                                                width: 16,
                                                height: 16,
                                                colorFilter: ColorFilter.mode(
                                                  isEditable
                                                      ? AppColor.textDark
                                                      : AppColor.textHint,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              tooltip:
                                                  !isEditable
                                                      ? 'Cột cố định'
                                                      : 'Ẩn cột này',
                                              onPressed:
                                                  !isEditable
                                                      ? null
                                                      : () {
                                                        setState(() {
                                                          _setVisibility(
                                                            col,
                                                            false,
                                                          );
                                                        });
                                                      },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: AppColor.textGrey.withValues(alpha: .2),
                height: 0.3,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        side: BorderSide(
                          color: AppColor.textGrey.withValues(alpha: .2),
                          width: 1,
                        ),
                        shadowColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                      ),
                      onPressed: () {
                        setState(() {
                          // Đặt lại tìm kiếm để hiển thị đầy đủ danh sách
                          searchQuery = '';

                          // Ưu tiên khôi phục THEO MẶC ĐỊNH GỐC nếu có; nếu không, rơi về initial của phiên
                          final defaultsHidden = widget.defaultHiddenKeys;

                          hidden = widget.allColumns
                              .where(
                                (c) => (defaultsHidden ?? const <String>[])
                                    .contains(c.key),
                              )
                              .toList(growable: true);

                          visible = widget.allColumns
                              .where(
                                (c) =>
                                    !(defaultsHidden ?? const <String>[])
                                        .contains(c.key),
                              )
                              .toList(growable: true);

                          for (final col in widget.allColumns.where(
                            (c) => !c.isConfigured,
                          )) {
                            hidden.removeWhere((h) => h.key == col.key);
                            if (!visible.any((v) => v.key == col.key)) {
                              visible.add(col);
                            }
                          }
                        });
                      },
                      child: Text(
                        'Khôi phục mặc định',
                        style: AppFont.buttonText.copyWith(
                          color: AppColor.textDark,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.greenDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Huỷ',
                        style: AppFont.buttonText.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.greenLight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        final hiddenKeys =
                            hidden
                                .where((e) => e.isConfigured && e.isFixed)
                                .map((e) => e.key)
                                .toList();
                        final visibleConfiguredOrderKeys =
                            visible
                                .where((e) => e.isConfigured)
                                .map((e) => e.key)
                                .toList();
                        Navigator.of(context).pop(
                          ColumnConfigResult(
                            hiddenKeys: hiddenKeys,
                            visibleConfiguredOrderKeys:
                                visibleConfiguredOrderKeys,
                          ),
                        );
                      },
                      child: Text(
                        'Áp dụng',
                        style: AppFont.buttonText.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
