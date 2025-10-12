import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';
import 'package:table_base/core/themes/app_icon_svg.dart';
import 'package:table_base/core/utils/format_date.dart';
import 'package:table_base/core/utils/input_formatters.dart';
import 'package:table_base/widgets/box_search.dart';
import 'package:table_base/widgets/calendar/models/calendar_model.dart';
import 'package:table_base/widgets/calendar/widgets/custom_calendar_picker.dart';
import 'package:table_base/widgets/custom_form_field.dart';
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';

/// Menu bộ lọc cho từng cột
/// - Hiển thị các loại bộ lọc: số, ngày, chọn danh sách
/// - Chỉ xử lý UI/nhập liệu, việc áp dụng lọc gọi sang Notifier
class FilterMenuWidget<T> extends ConsumerStatefulWidget {
  final int columnIndex;
  final String columnName;
  final FilterType filterType;
  final List<T> allData;
  final dynamic Function(T item, int columnIndex) valueGetter;
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  >
  tableProvider;
  final ColumnFilter? currentFilter;
  final double? maxWidth;
  final int pageSize;

  const FilterMenuWidget({
    super.key,
    required this.columnIndex,
    required this.columnName,
    required this.filterType,
    required this.allData,
    required this.valueGetter,
    required this.tableProvider,
    this.currentFilter,
    this.maxWidth = 380,
    this.pageSize = 100,
  });

  @override
  ConsumerState<FilterMenuWidget<T>> createState() =>
      _FilterMenuWidgetState<T>();
}

/// State nội bộ của menu filter: quản lý input, hover, paging danh sách chọn
class _FilterMenuWidgetState<T> extends ConsumerState<FilterMenuWidget<T>> {
  String _textValue = '';
  double? _minNumberValue;
  double? _maxNumberValue;
  double? _minNumber;
  double? _maxNumber;
  Set<dynamic> _selectedValues = {};
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _valueNumberMinController =
      TextEditingController();
  final TextEditingController _valueNumberMaxController =
      TextEditingController();
  late final FocusNode _minFocusNode;
  late final FocusNode _maxFocusNode;
  String? _hoveredSortKey;
  String? _hoveredItemKey;
  DateRange? _selectedDateRange;
  int _selectPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeFromCurrentFilter();
    _computeNumericRange();
    _minFocusNode = FocusNode();
    _maxFocusNode = FocusNode();
    _minFocusNode.addListener(() {
      if (!_minFocusNode.hasFocus) {
        _applyMinFromInput();
      }
    });
    _maxFocusNode.addListener(() {
      if (!_maxFocusNode.hasFocus) {
        _applyMaxFromInput();
      }
    });
  }

  void _initializeFromCurrentFilter() {
    if (widget.currentFilter != null) {
      _textValue = widget.currentFilter!.customText ?? '';
      _minNumberValue = widget.currentFilter!.minNumberValue;
      _maxNumberValue = widget.currentFilter!.maxNumberValue;
      _selectedValues = Set.from(widget.currentFilter!.selectedValues);
      _textController.text = _textValue;
      _selectedDateRange = DateRange(
        startDate: widget.currentFilter!.startDateValue,
        endDate: widget.currentFilter!.endDateValue,
      );
    }
  }

  void _computeNumericRange() {
    if (widget.filterType != FilterType.number) return;

    double? minVal;
    double? maxVal;
    for (final item in widget.allData) {
      final v = widget.valueGetter(item, widget.columnIndex);
      if (v is num) {
        final d = v.toDouble();
        if (minVal == null || d < minVal) minVal = d;
        if (maxVal == null || d > maxVal) maxVal = d;
      }
    }

    setState(() {
      _minNumber = minVal ?? 0;
      _maxNumber = maxVal ?? 0;
      // If no current values, initialize to full range
      _minNumberValue = _minNumberValue ?? _minNumber;
      _maxNumberValue = _maxNumberValue ?? _maxNumber;
      // Ensure ordering
      if (_minNumberValue != null &&
          _maxNumberValue != null &&
          _minNumberValue! > _maxNumberValue!) {
        final t = _minNumberValue;
        _minNumberValue = _maxNumberValue;
        _maxNumberValue = t;
      }
      // Initialize inputs with current values (Vietnamese currency style)
      if (_minNumberValue != null) {
        _valueNumberMinController.text = _formatVnd(_minNumberValue!);
      }
      if (_maxNumberValue != null) {
        _valueNumberMaxController.text = _formatVnd(_maxNumberValue!);
      }
    });
  }

  double _clampToRange(double value) {
    final double minV = _minNumber ?? 0;
    final double maxV = _maxNumber ?? 0;
    if (value < minV) return minV;
    if (value > maxV) return maxV;
    return value;
  }

  double? _parseCurrencyToDouble(String input) {
    if (input.isEmpty) return null;
    final cleaned = input.replaceAll(RegExp(r"[^0-9.-]"), '');
    return double.tryParse(cleaned);
  }

  String _formatVnd(double value) {
    // Simple VND formatting without intl: thousand separators + suffix
    final intVal = value.round();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final idxFromEnd = str.length - i;
      buffer.write(str[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    final formatted = buffer.toString();
    return '$formattedđ';
  }

  void _applyMinFromInput() {
    final parsed = _parseCurrencyToDouble(_valueNumberMinController.text);
    if (parsed == null) return;
    setState(() {
      final clamped = _clampToRange(parsed);
      double newMin = clamped;
      double newMax = _maxNumberValue ?? (_maxNumber ?? clamped);
      if (newMin > newMax) newMax = newMin;
      _minNumberValue = newMin;
      _maxNumberValue = newMax;
      _valueNumberMinController.text = _formatVnd(newMin);
      _valueNumberMaxController.text = _formatVnd(newMax);
    });
  }

  void _applyMaxFromInput() {
    final parsed = _parseCurrencyToDouble(_valueNumberMaxController.text);
    if (parsed == null) return;
    setState(() {
      final clamped = _clampToRange(parsed);
      double newMax = clamped;
      double newMin = _minNumberValue ?? (_minNumber ?? clamped);
      if (newMax < newMin) newMin = newMax;
      _minNumberValue = newMin;
      _maxNumberValue = newMax;
      _valueNumberMinController.text = _formatVnd(newMin);
      _valueNumberMaxController.text = _formatVnd(newMax);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _valueNumberMinController.dispose();
    _valueNumberMaxController.dispose();
    _minFocusNode.dispose();
    _maxFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.maxWidth,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 12, right: 12),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildSortOptions(),
              _buildFilterOptions(),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        alignment: Alignment.centerLeft,
        width: double.infinity,
        child: Text(
          widget.columnName,
          style: AppFont.titleMedium.copyWith(
            color: AppColor.textDark,
            fontWeight: AppFont.semiBold,
          ),
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sắp xếp',
            style: AppFont.titleSmall.copyWith(color: AppColor.textDark),
          ),
          const SizedBox(height: 6),
          _buildSortOption(
            _getAscendingSortLabel(),
            () => _applySort(true),
            _getAscendingSortIcon(),
            'asc',
          ),
          _buildSortOption(
            _getDescendingSortLabel(),
            () => _applySort(false),
            _getDescendingSortIcon(),
            'desc',
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    String title,
    VoidCallback onTap,
    String icon,
    String key,
  ) {
    return InkWell(
      onTap: onTap,
      onHover: (value) {
        setState(() {
          _hoveredSortKey = value ? key : null;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color:
              _hoveredSortKey == key
                  ? AppColor.greenDark.withValues(alpha: .1)
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(AppColor.textGrey, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppFont.bodyMedium.copyWith(color: AppColor.textDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bộ lọc',
            style: AppFont.titleMedium.copyWith(color: AppColor.textDark),
          ),
          const SizedBox(height: 6),
          if (widget.filterType == FilterType.number) ...[
            _buildNumberFilter(),
          ] else if (widget.filterType == FilterType.select) ...[
            _buildSelectFilter(),
          ] else if (widget.filterType == FilterType.date) ...[
            _buildDateFilter(),
          ],
        ],
      ),
    );
  }

  Widget _buildNumberFilter() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColor.greenLight,
              inactiveTrackColor: AppColor.greenDark.withValues(alpha: 0.1),
              trackHeight: 4,
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 6.0,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              thumbColor: AppColor.greenDark,
              overlayColor: AppColor.greenDark.withValues(alpha: 0.1),
              valueIndicatorColor: AppColor.greenDark.withValues(alpha: 0.2),
            ),
            child: Builder(
              builder: (context) {
                double minBound = _minNumber ?? 0;
                double maxBound = _maxNumber ?? 0;
                if (maxBound < minBound) {
                  final tmp = maxBound;
                  maxBound = minBound;
                  minBound = tmp;
                }
                if (maxBound == minBound) {
                  maxBound = minBound + 1;
                }

                final double startRaw = _minNumberValue ?? minBound;
                final double endRaw = _maxNumberValue ?? maxBound;
                double start = startRaw.clamp(minBound, maxBound);
                double end = endRaw.clamp(minBound, maxBound);
                if (start > end) {
                  final tmp = start;
                  start = end;
                  end = tmp;
                }

                return RangeSlider(
                  values: RangeValues(start, end),
                  min: minBound,
                  max: maxBound,
                  onChanged: (RangeValues values) {
                    double s = values.start.clamp(minBound, maxBound);
                    double e = values.end.clamp(minBound, maxBound);
                    if (s > e) {
                      final t = s;
                      s = e;
                      e = t;
                    }
                    setState(() {
                      _minNumberValue = s;
                      _maxNumberValue = e;
                      _valueNumberMinController.text = _formatVnd(s);
                      _valueNumberMaxController.text = _formatVnd(e);
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                _applyMinFromInput();
              }
            },
            child: CustomFormField(
              controller: _valueNumberMinController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              isRequired: true,
              inputFormatters: InputFormatters.currency,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Divider(color: AppColor.textHint, height: 1),
          ),
          const SizedBox(height: 6),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                _applyMaxFromInput();
              }
            },
            child: CustomFormField(
              controller: _valueNumberMaxController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              isRequired: true,
              inputFormatters: InputFormatters.currency,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColor.greenDark,
          ),
          child: Text(
            _selectedDateRange != null
                ? _selectedDateRange!.startDate != null &&
                        _selectedDateRange!.endDate != null
                    ? '${formatDate(_selectedDateRange!.startDate)} - ${formatDate(_selectedDateRange!.endDate)}'
                    : 'Chọn ngày'
                : 'Chọn ngày',
            style: AppFont.bodyMedium.copyWith(
              color: AppColor.white,
              fontWeight: AppFont.medium,
            ),
          ),
        ),
        const SizedBox(height: 6),
        CustomCalendarPicker(
          initialMode: DateSelectionMode.range,
          initialDateRange: _selectedDateRange,
          showModeSelector: false,
          maxHeight: 300,
          onRangeChanged: (dateRange) {
            if (dateRange != null) {
              setState(() {
                _selectedDateRange = dateRange;
              });
            }
          },
          todayColor: AppColor.greenLight.withValues(alpha: 0.2),
          textTodayColor: AppColor.textDark,
          borderRadius: BorderRadius.circular(12),
          backgroundGridColor: AppColor.greyLight,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          border: Border.all(color: AppColor.greenLight, width: 1.2),
          inRangeColor: AppColor.greenLight.withValues(alpha: 0.2),
          selectedColor: AppColor.greenLight,
          paddingHeader: EdgeInsets.zero,
          paddingGrid: EdgeInsets.zero,
          isShowSelectionStatus: false,
          isShowBottomActions: false,
          isBoxDecoration: false,
        ),
      ],
    );
  }

  Widget _buildSelectFilter() {
    final uniqueValues = <dynamic>{};

    // Lấy tất cả giá trị unique từ cột này
    for (final item in widget.allData) {
      final value = widget.valueGetter(item, widget.columnIndex);
      if (value != null) {
        uniqueValues.add(value);
      }
    }

    // Tạo danh sách hiển thị theo từ khóa tìm kiếm
    final String keyword = _textValue.trim().toLowerCase();
    final List<dynamic> visibleValues =
        uniqueValues
            .where(
              (v) =>
                  keyword.isEmpty
                      ? true
                      : v.toString().toLowerCase().contains(keyword),
            )
            .toList();

    // Pagination over visible values
    final int totalItems = visibleValues.length;
    final int effectivePageSize = widget.pageSize <= 0 ? 1 : widget.pageSize;
    final int totalPages =
        totalItems == 0
            ? 1
            : ((totalItems + effectivePageSize - 1) ~/ effectivePageSize);
    final int currentPage = _selectPage.clamp(0, totalPages - 1);
    final int startIndex = currentPage * effectivePageSize;
    final int endIndex =
        (startIndex + effectivePageSize) > totalItems
            ? totalItems
            : (startIndex + effectivePageSize);
    final List<dynamic> pagedValues =
        totalItems == 0
            ? const []
            : visibleValues.sublist(startIndex, endIndex);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: BoxSearch(
            controller: _textController,
            onSearch: (value) {
              setState(() {
                _textValue = value;
                _selectPage = 0; // reset page when search changes
              });
            },
            suffixIcon:
                _textValue.isNotEmpty
                    ? IconButton(
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                      ),
                      onPressed: () {
                        setState(() {
                          _textValue = '';
                          _textController.clear();
                          _selectPage = 0;
                        });
                      },
                      icon: Icon(Icons.clear),
                    )
                    : null,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Chọn giá trị:',
                  style: AppFont.bodyMedium.copyWith(color: AppColor.textDark),
                ),
              ),
              Checkbox(
                activeColor: AppColor.greenDark,
                checkColor: AppColor.white,
                side: BorderSide(color: AppColor.greenDark, width: 1.6),
                overlayColor: WidgetStatePropertyAll<Color>(
                  AppColor.greenDark.withValues(alpha: .1),
                ),
                value:
                    pagedValues.isNotEmpty &&
                    pagedValues.every((v) => _selectedValues.contains(v)),
                onChanged: (_) {
                  setState(() {
                    final bool selectAllVisible =
                        pagedValues.isNotEmpty &&
                        pagedValues.every((v) => _selectedValues.contains(v));
                    if (selectAllVisible) {
                      // Bỏ chọn tất cả mục đang hiển thị
                      for (final v in pagedValues) {
                        _selectedValues.remove(v);
                      }
                    } else {
                      // Chọn tất cả mục đang hiển thị
                      for (final v in pagedValues) {
                        _selectedValues.add(v);
                      }
                    }
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        if (visibleValues.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Không có kết quả',
                style: AppFont.bodyMedium.copyWith(color: AppColor.textDark),
              ),
            ),
          ),
        if (visibleValues.isNotEmpty)
          Container(
            constraints: const BoxConstraints(minHeight: 0, maxHeight: 240),
            child: ListView.builder(
              shrinkWrap: pagedValues.length < 6,
              itemCount: pagedValues.length,
              itemBuilder: (context, index) {
                final value = pagedValues[index];
                final isSelected = _selectedValues.contains(value);

                return InkWell(
                  onTap: () {},
                  onHover: (isHover) {
                    final String? key = isHover ? value.toString() : null;
                    if (_hoveredItemKey != key) {
                      setState(() {
                        _hoveredItemKey = key;
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 4, right: 12),
                    padding: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:
                          _hoveredItemKey == value.toString()
                              ? AppColor.greenDark.withValues(alpha: .1)
                              : Colors.transparent,
                    ),
                    child: CheckboxListTile(
                      activeColor: AppColor.greenDark,
                      checkColor: AppColor.white,
                      side: BorderSide(color: AppColor.greenDark, width: 1.6),
                      overlayColor: WidgetStatePropertyAll<Color>(
                        AppColor.greenDark.withValues(alpha: .1),
                      ),
                      title: Text(
                        value.toString(),
                        style: AppFont.bodyMedium.copyWith(
                          color: AppColor.textDark,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedValues.add(value);
                          } else {
                            _selectedValues.remove(value);
                          }
                        });
                      },
                      dense: true,
                    ),
                  ),
                );
              },
            ),
          ),
        if (visibleValues.isNotEmpty && totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                IconButton(
                  tooltip: 'Trang đầu',
                  icon: const Icon(Icons.first_page),
                  onPressed:
                      currentPage > 0
                          ? () {
                            setState(() {
                              _selectPage = 0;
                            });
                          }
                          : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      currentPage > 0
                          ? () {
                            setState(() {
                              _selectPage = currentPage - 1;
                            });
                          }
                          : null,
                  tooltip: 'Trang trước',
                ),
                Text(
                  '${currentPage + 1} / $totalPages',
                  style: AppFont.bodyMedium.copyWith(color: AppColor.textDark),
                ),
                IconButton(
                  tooltip: 'Trang sau',
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      (currentPage < totalPages - 1)
                          ? () {
                            setState(() {
                              _selectPage = currentPage + 1;
                            });
                          }
                          : null,
                ),
                IconButton(
                  tooltip: 'Trang cuối',
                  icon: const Icon(Icons.last_page),
                  onPressed:
                      (currentPage < totalPages - 1)
                          ? () {
                            setState(() {
                              _selectPage = totalPages - 1;
                            });
                          }
                          : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 28,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                ref
                    .read(widget.tableProvider.notifier)
                    .clearColumnFilter(widget.columnIndex);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Bỏ lọc',
                style: AppFont.buttonText.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: AppFont.regular,
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
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
              child: Center(
                child: Text(
                  'Hủy',
                  style: AppFont.buttonText.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: AppFont.regular,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _applyFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.greenLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Lọc',
                style: AppFont.buttonText.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: AppFont.regular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applySort(bool ascending) {
    final state = ref.read(widget.tableProvider);
    final notifier = ref.read(widget.tableProvider.notifier);

    final currentIndex = state.sortState.columnIndex;
    final currentAscending = state.sortState.ascending;

    if (currentIndex == widget.columnIndex) {
      if (currentAscending != ascending) {
        notifier.sort(widget.columnIndex);
      }
    } else {
      notifier.sort(widget.columnIndex); // mặc định lên ascending = true
      if (!ascending) {
        notifier.sort(widget.columnIndex); // toggle sang descending
      }
    }

    Navigator.of(context).pop();
  }

  String _getAscendingSortLabel() {
    switch (widget.filterType) {
      case FilterType.number:
        return 'Tăng dần (nhỏ → lớn)';
      case FilterType.date:
        return 'Cũ nhất → Mới nhất';
      case FilterType.select:
        return 'A → Z';
    }
  }

  String _getDescendingSortLabel() {
    switch (widget.filterType) {
      case FilterType.number:
        return 'Giảm dần (lớn → nhỏ)';
      case FilterType.date:
        return 'Mới nhất → Cũ nhất';
      case FilterType.select:
        return 'Z → A';
    }
  }

  String _getAscendingSortIcon() {
    switch (widget.filterType) {
      case FilterType.number:
        return AppIconSvg.iconArrowDown01;
      case FilterType.date:
        return AppIconSvg.iconCalendarArrowUp;
      case FilterType.select:
        return AppIconSvg.iconArrowDownZa;
    }
  }

  String _getDescendingSortIcon() {
    switch (widget.filterType) {
      case FilterType.number:
        return AppIconSvg.iconArrowUp01;
      case FilterType.date:
        return AppIconSvg.iconCalendarArrowDown;
      case FilterType.select:
        return AppIconSvg.iconArrowUpAz;
    }
  }

  void _applyFilter() {
    final filter = ColumnFilter(
      columnIndex: widget.columnIndex,
      filterType: widget.filterType,
      minNumberValue: _minNumberValue,
      maxNumberValue: _maxNumberValue,
      startDateValue: _selectedDateRange?.startDate,
      endDateValue: _selectedDateRange?.endDate,
      selectedValues: _selectedValues,
      customText: _textValue.isNotEmpty ? _textValue : null,
    );

    ref
        .read(widget.tableProvider.notifier)
        .applyColumnFilter(widget.columnIndex, filter);
    Navigator.of(context).pop();
  }
}