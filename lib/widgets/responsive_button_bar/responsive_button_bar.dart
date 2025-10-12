// Import các thư viện cần thiết
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/rendering.dart' as rendering;
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';

/// Widget tạo thanh nút responsive, tự động ẩn các nút không vừa màn hình vào menu popup
class ResponsiveButtonBar extends StatefulWidget {
  /// Danh sách các nút cần hiển thị
  final List<ResponsiveButtonData> buttons;

  /// Khoảng cách giữa các nút
  final double spacing;

  /// Căn chỉnh theo trục chính
  final MainAxisAlignment mainAxisAlignment;

  /// Căn chỉnh theo trục phụ
  final CrossAxisAlignment crossAxisAlignment;

  /// Padding xung quanh widget
  final EdgeInsets padding;

  /// Vị trí nút "Thêm" khi overflow (đầu hoặc cuối)
  final OverflowSide overflowSide;

  /// Offset cho popup menu
  final Offset popupOffset;

  /// Vị trí popup menu (trên hoặc dưới nút)
  final PopupMenuPosition popupPosition;

  /// Hình dạng của popup menu
  final ShapeBorder? popupShape;

  /// Độ nổi của popup menu
  final double? popupElevation;

  /// Nhãn cho nút "Thêm"
  final String moreLabel;

  /// Builder tùy chỉnh cho nút "Thêm"
  final WidgetBuilder? moreButtonBuilder;

  /// Builder tùy chỉnh cho các item trong menu popup
  final Widget Function(BuildContext, ResponsiveButtonData)? menuItemBuilder;

  /// Constructor với các tham số mặc định
  const ResponsiveButtonBar({
    super.key,
    required this.buttons,
    this.spacing = 12.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = EdgeInsets.zero,
    this.overflowSide = OverflowSide.end,
    this.popupOffset = Offset.zero,
    this.popupPosition = PopupMenuPosition.over,
    this.popupShape,
    this.popupElevation,
    this.moreLabel = 'Thêm',
    this.moreButtonBuilder,
    this.menuItemBuilder,
  });

  @override
  State<ResponsiveButtonBar> createState() => _ResponsiveButtonBarState();
}

/// State class quản lý trạng thái của ResponsiveButtonBar
class _ResponsiveButtonBarState extends State<ResponsiveButtonBar> {
  /// Danh sách các nút hiển thị trên màn hình
  List<ResponsiveButtonData> _visibleButtons = [];

  /// Danh sách các nút bị ẩn (nằm trong menu popup)
  List<ResponsiveButtonData> _hiddenButtons = [];

  /// Xác định overflow có ở đầu hay không
  bool _isOverflowAtStart = false;

  /// Chiều rộng đã đo được của nút "Thêm"
  double? _measuredMoreButtonWidth;

  /// Key để tham chiếu đến nút "Thêm" để tính toán vị trí popup
  final GlobalKey _moreButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Gọi setState sau khi frame đầu tiên được render để tính toán layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(ResponsiveButtonBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kiểm tra xem có cần refresh layout không dựa trên sự thay đổi của các props
    final bool needRefresh =
        oldWidget.buttons.length != widget.buttons.length ||
            !identical(oldWidget.buttons, widget.buttons) ||
            oldWidget.spacing != widget.spacing ||
            oldWidget.mainAxisAlignment != widget.mainAxisAlignment ||
            oldWidget.crossAxisAlignment != widget.crossAxisAlignment ||
            oldWidget.padding != widget.padding ||
            oldWidget.overflowSide != widget.overflowSide ||
            oldWidget.popupOffset != widget.popupOffset ||
            oldWidget.popupPosition != widget.popupPosition ||
            oldWidget.popupShape != widget.popupShape ||
            oldWidget.popupElevation != widget.popupElevation ||
            oldWidget.moreLabel != widget.moreLabel ||
            oldWidget.moreButtonBuilder != widget.moreButtonBuilder ||
            oldWidget.menuItemBuilder != widget.menuItemBuilder;
    if (needRefresh) {
      setState(() {});
    }
  }

  /// Tính toán layout và xác định nút nào hiển thị, nút nào ẩn
  void _calculateLayout(double availableWidth) {
    if (!mounted) return;
    // Thêm margin an toàn để tránh overflow
    const double safetyMargin = 12.0;
    final double effectiveWidth =
        (availableWidth - safetyMargin).clamp(0, double.infinity);

    // Tính toán chiều rộng của tất cả nút và spacing
    final buttonWidths = <double>[];
    double totalWidth = 0;

    for (int i = 0; i < widget.buttons.length; i++) {
      final double w = widget.buttons[i].width;
      buttonWidths.add(w);
      totalWidth += w;
      // Thêm spacing giữa các nút (trừ nút cuối)
      if (i < widget.buttons.length - 1) {
        totalWidth += widget.spacing;
      }
    }

    // Nếu tổng chiều rộng vượt quá không gian khả dụng, cần xử lý overflow
    if (totalWidth > effectiveWidth) {
      // Sử dụng chiều rộng đã đo được của nút "Thêm" hoặc giá trị mặc định
      final moreButtonWidth = _measuredMoreButtonWidth ?? 100.0;

      int visibleCount = 0;
      double currentWidth = 0;
      _isOverflowAtStart = widget.overflowSide == OverflowSide.start;

      // Xử lý overflow ở đầu (hiển thị nút cuối, ẩn nút đầu)
      if (_isOverflowAtStart) {
        double widthAccumulated = moreButtonWidth;
        // Duyệt từ cuối lên đầu để tìm số nút có thể hiển thị
        for (int i = buttonWidths.length - 1; i >= 0; i--) {
          double testWidth = widthAccumulated + buttonWidths[i];
          if (i != 0) testWidth += widget.spacing;
          if (testWidth <= effectiveWidth) {
            widthAccumulated = testWidth;
            visibleCount++;
          } else {
            break;
          }
        }
        // Lấy nút cuối để hiển thị
        _visibleButtons =
            widget.buttons.skip(widget.buttons.length - visibleCount).toList();
        // Lấy nút đầu để ẩn
        _hiddenButtons =
            widget.buttons.take(widget.buttons.length - visibleCount).toList();
      } else {
        // Xử lý overflow ở cuối (hiển thị nút đầu, ẩn nút cuối)
        // Duyệt từ đầu đến cuối để tìm số nút có thể hiển thị
        for (int i = 0; i < buttonWidths.length; i++) {
          final double nextButtonWidth = buttonWidths[i];
          final double spacingBeforeThis =
              (visibleCount == 0) ? 0 : widget.spacing;
          final double spacingBeforeMore =
              (visibleCount == 0) ? 0 : widget.spacing;
          // Tính tổng chiều rộng bao gồm nút hiện tại + nút "Thêm"
          final double candidateTotal = currentWidth +
              spacingBeforeThis +
              nextButtonWidth +
              spacingBeforeMore +
              moreButtonWidth;
          if (candidateTotal <= effectiveWidth) {
            currentWidth += spacingBeforeThis + nextButtonWidth;
            visibleCount++;
          } else {
            break;
          }
        }
        // Lấy nút đầu để hiển thị
        _visibleButtons = widget.buttons.take(visibleCount).toList();
        // Lấy nút cuối để ẩn
        _hiddenButtons = widget.buttons.skip(visibleCount).toList();
      }

      // Trường hợp đặc biệt: nếu không có nút nào vừa, hiển thị ít nhất 1 nút
      if (visibleCount == 0 && widget.buttons.isNotEmpty) {
        if (_isOverflowAtStart) {
          _visibleButtons =
              widget.buttons.skip(widget.buttons.length - 1).toList();
          _hiddenButtons =
              widget.buttons.take(widget.buttons.length - 1).toList();
        } else {
          _visibleButtons = widget.buttons.take(1).toList();
          _hiddenButtons = widget.buttons.skip(1).toList();
        }
      }
    } else {
      // Nếu tất cả nút đều vừa, hiển thị hết
      _visibleButtons = List.from(widget.buttons);
      _hiddenButtons = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính chiều rộng khả dụng, ưu tiên constraints từ LayoutBuilder
        final availableWidth = (constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width) -
            widget.padding.horizontal;

        // Đo kích thước thực của nút "Thêm" để tính toán chính xác layout
        final moreProbe = _MeasureSize(
          onChange: (size) {
            if (size != null) {
              // Cập nhật chiều rộng nút "Thêm" khi có thay đổi
              if (_measuredMoreButtonWidth != size.width) {
                setState(() {
                  _measuredMoreButtonWidth = size.width;
                });
              }
            }
          },
          child: _buildMoreButtonPreview(),
        );

        // Tính toán layout dựa trên chiều rộng khả dụng
        _calculateLayout(availableWidth);

        return Stack(
          children: [
            // Widget ẩn để đo kích thước nút "Thêm"
            Offstage(offstage: true, child: moreProbe),
            // Widget chính hiển thị các nút
            Padding(
              padding: widget.padding,
              child: Row(
                mainAxisAlignment: widget.mainAxisAlignment,
                crossAxisAlignment: widget.crossAxisAlignment,
                children: [
                  // Hiển thị nút "Thêm" ở đầu nếu overflow ở đầu
                  if (_hiddenButtons.isNotEmpty && _isOverflowAtStart) ...[
                    Padding(
                      padding: EdgeInsets.only(right: widget.spacing),
                      child: _buildMoreButton(),
                    ),
                  ],

                  // Hiển thị các nút visible
                  ..._visibleButtons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final button = entry.value;
                    final isLastVisible = index == _visibleButtons.length - 1;
                    final hasMoreButton =
                        _hiddenButtons.isNotEmpty && !_isOverflowAtStart;

                    return Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(
                          // Không thêm spacing bên phải nút cuối nếu không có nút "Thêm"
                          right: (isLastVisible && !hasMoreButton)
                              ? 0
                              : widget.spacing,
                        ),
                        child: _buildButton(button),
                      ),
                    );
                  }),

                  // Hiển thị nút "Thêm" ở cuối nếu overflow ở cuối
                  if (_hiddenButtons.isNotEmpty && !_isOverflowAtStart) ...[
                    _buildMoreButton(),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Xây dựng widget cho một nút
  Widget _buildButton(ResponsiveButtonData button) {
    return button.builder(context);
  }

  /// Xây dựng nút "Thêm" mặc định với icon và text
  Widget _buildDefaultMoreButtonIcon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.more_horiz,
            color: AppColor.textDark,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            widget.moreLabel,
            style: TextStyle(
              color: AppColor.textDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng preview của nút "Thêm" để đo kích thước
  Widget _buildMoreButtonPreview() {
    if (widget.moreButtonBuilder != null) {
      return Builder(builder: (context) => widget.moreButtonBuilder!(context));
    }
    return _buildDefaultMoreButtonIcon();
  }

  /// Xây dựng nút "Thêm" với khả năng hiển thị popup menu
  Widget _buildMoreButton() {
    final Widget buttonChild = widget.moreButtonBuilder != null
        ? Builder(builder: (context) => widget.moreButtonBuilder!(context))
        : _buildDefaultMoreButtonIcon();

    return Tooltip(
      message: widget.moreLabel,
      child: Semantics(
        button: true,
        label: widget.moreLabel,
        child: InkWell(
          key: _moreButtonKey,
          onTap: () async {
            // Lấy thông tin vị trí và kích thước của nút "Thêm"
            final RenderBox? buttonBox =
                _moreButtonKey.currentContext?.findRenderObject() as RenderBox?;
            final overlay = Overlay.of(context, rootOverlay: true);
            if (buttonBox == null) return;

            final RenderBox overlayBox =
                overlay.context.findRenderObject() as RenderBox;
            final Offset buttonPosition =
                buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);
            final Size buttonSize = buttonBox.size;

            // Tính toán vị trí popup menu dựa trên vị trí nút và offset
            final Offset offset = widget.popupOffset;
            final RelativeRect position = RelativeRect.fromLTRB(
              buttonPosition.dx + offset.dx,
              buttonPosition.dy +
                  (widget.popupPosition == PopupMenuPosition.under
                      ? buttonSize.height
                      : 0) +
                  offset.dy,
              overlayBox.size.width -
                  (buttonPosition.dx + buttonSize.width) -
                  offset.dx,
              overlayBox.size.height -
                  (buttonPosition.dy + buttonSize.height) -
                  offset.dy,
            );

            // Hiển thị popup menu với các nút bị ẩn
            final selected = await showMenu<ResponsiveButtonData>(
              context: overlay.context,
              position: position,
              shape: widget.popupShape,
              elevation: widget.popupElevation,
              color: Colors.white,
              menuPadding: EdgeInsets.all(0),
              items: _hiddenButtons.map((button) {
                return PopupMenuItem<ResponsiveButtonData>(
                  value: button,
                  child: widget.menuItemBuilder != null
                      ? widget.menuItemBuilder!(context, button)
                      : Row(
                          children: [
                            // Hiển thị icon nếu có
                            if (button.iconPath != null) ...[
                              SvgPicture.asset(
                                button.iconPath!,
                                width: 16,
                                height: 16,
                                colorFilter: button.iconColor != null
                                    ? ColorFilter.mode(
                                        button.iconColor!, BlendMode.srcIn)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(button.text),
                          ],
                        ),
                );
              }).toList(),
            );

            // Gọi callback khi người dùng chọn một item trong menu
            if (selected != null) {
              selected.onPressed?.call();
            }
          },
          child: buttonChild,
        ),
      ),
    );
  }
}

/// Enum định nghĩa vị trí overflow (đầu hoặc cuối)
enum OverflowSide { start, end }

/// Widget đo kích thước con và callback về size thực tế
/// Sử dụng để đo kích thước nút "Thêm" mà không hiển thị
class _MeasureSize extends SingleChildRenderObjectWidget {
  final void Function(Size?) onChange;

  const _MeasureSize({required this.onChange, required super.child});

  @override
  rendering.RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderMeasureSize renderObject) {
    renderObject.onChange = onChange;
  }
}

/// RenderObject thực hiện việc đo kích thước và callback khi có thay đổi
class _RenderMeasureSize extends rendering.RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  void Function(Size?) onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    Size newSize = child?.size ?? Size.zero;
    // Chỉ callback khi kích thước thực sự thay đổi
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    // Gọi callback sau khi frame hiện tại hoàn thành
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

/// Class chứa dữ liệu cho một nút trong ResponsiveButtonBar
class ResponsiveButtonData {
  /// Text hiển thị trên nút
  final String text;

  /// Đường dẫn đến file icon SVG
  final String? iconPath;

  /// Màu nền của nút
  final Color? backgroundColor;

  /// Màu của icon
  final Color? iconColor;

  /// Màu của text
  final Color? textColor;

  /// Callback khi nhấn nút
  final VoidCallback? onPressed;

  /// Builder tùy chỉnh để tạo widget cho nút
  final Widget Function(BuildContext) builder;

  /// Chiều rộng cố định của nút
  final double width;

  /// Chiều cao của nút
  final double? height;

  /// Kích thước của icon
  final double? iconSize;

  /// Padding bên trong nút
  final EdgeInsetsGeometry? buttonPadding;

  /// Decoration tùy chỉnh cho nút
  final Decoration? decorationButton;

  /// Style cho text
  final TextStyle? textStyle;

  /// Constructor chính cho ResponsiveButtonData
  ResponsiveButtonData({
    required this.builder,
    required this.text,
    required this.width,
    this.iconPath,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.onPressed,
    this.iconSize,
    this.buttonPadding,
    this.decorationButton,
    this.textStyle,
    this.height,
  });

  /// Factory constructor tạo nút với icon và text
  factory ResponsiveButtonData.fromButtonIcon({
    required String text,
    required String iconPath,
    required Color backgroundColor,
    required Color iconColor,
    Color textColor = Colors.white,
    double iconSize = 16,
    required double width,
    double? height,
    EdgeInsetsGeometry? buttonPadding,
    Decoration? decorationButton,
    VoidCallback? onPressed,
    TextStyle? textStyle,
  }) {
    return ResponsiveButtonData(
      text: text,
      iconPath: iconPath,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      textColor: textColor,
      onPressed: onPressed,
      iconSize: iconSize,
      buttonPadding: buttonPadding,
      decorationButton: decorationButton,
      textStyle: textStyle,
      width: width,
      height: height,
      // Builder tạo nút với icon và text
      builder: (context) => GestureDetector(
        onTap: onPressed,
        child: Container(
          width: width,
          height: height,
          padding: buttonPadding ??
              const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: decorationButton ??
              BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hiển thị icon SVG
                SvgPicture.asset(
                  iconPath,
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                const SizedBox(width: 4),
                // Hiển thị text với Flexible để tránh overflow
                Text(
                  text,
                  style:
                      textStyle ?? AppFont.buttonText.copyWith(color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
