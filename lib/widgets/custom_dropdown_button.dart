import 'package:flutter/material.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';
import 'package:table_base/core/utils/log.dart';

class CustomDropdownController {
  _CustomDropdownButtonState? _state;

  void _attach(_CustomDropdownButtonState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// Mở dropdown
  void open() {
    _state?._openDropdown();
  }

  /// Đóng dropdown
  void close() {
    _state?._closeDropdown();
  }

  /// Toggle dropdown (mở nếu đang đóng, đóng nếu đang mở)
  void toggle() {
    _state?._toggleDropdown();
  }

  /// Kiểm tra trạng thái dropdown có đang mở hay không
  bool get isOpen => _state?._isDropdownOpen ?? false;
}

class CustomDropdownButton extends StatefulWidget {
  final String? label;
  final Widget widget;
  final double? maxWidth;
  final double? maxHeight;
  final double? heightButton;
  final bool? isPositionCenter;
  final bool? isPositionLeft;
  final bool? isPositionRight;
  final CustomDropdownController? controller;
  final VoidCallback? onDropdownOpened;
  final Widget? icon;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final Widget? childButton;

  const CustomDropdownButton({
    super.key,
    this.label,
    required this.widget,
    this.controller,
    this.maxWidth,
    this.maxHeight,
    this.heightButton,
    this.isPositionCenter = false,
    this.isPositionLeft = false,
    this.isPositionRight = false,
    this.onDropdownOpened,
    this.icon,
    this.decoration,
    this.textStyle,
    this.padding,
    this.childButton,
  });

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _buttonKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Attach controller nếu có
    widget.controller?._attach(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    _isDropdownOpen = true;

    // Kiểm tra xem controller đã bị dispose chưa
    try {
      _controller.forward(from: 0);
    } catch (e) {
      // Controller đã bị dispose, bỏ qua
      Log.error('CustomDropdownButton', 'Controller đã bị dispose: $e');
    }

    // Gọi callback sau khi dropdown đã mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDropdownOpened?.call();
    });
  }

  void _closeDropdown() async {
    // Kiểm tra xem controller đã bị dispose chưa
    try {
      await _controller.reverse();
    } catch (e) {
      // Controller đã bị dispose, bỏ qua
      Log.error('CustomDropdownButton', 'Controller đã bị dispose: $e');
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - (offset.dy + size.height);
    final spaceAbove = offset.dy;
    const dropdownHeight = 200.0;

    final bool openDown =
        spaceBelow >= dropdownHeight || spaceBelow > spaceAbove;

    final double dropdownWidth = widget.maxWidth ?? size.width;
    final double offsetX = (widget.isPositionCenter ?? false)
        ? (size.width - dropdownWidth) / 2
        : (widget.isPositionLeft ?? false)
            ? 0
            : (widget.isPositionRight ?? false)
                ? size.width - dropdownWidth
                : 0;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(),
            ),
          ),
          Positioned(
            width: widget.maxWidth ?? size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: openDown
                  ? Offset(offsetX, size.height + 5)
                  : Offset(offsetX, -(widget.maxHeight ?? dropdownHeight) - 5),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: AppColor.white,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: widget.maxHeight ?? dropdownHeight,
                    maxWidth: widget.maxWidth ?? size.width,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: widget.widget,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Detach controller
    widget.controller?._detach();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        key: _buttonKey,
        onTap: _toggleDropdown,
        child: widget.childButton ??
            Container(
              height: widget.heightButton ?? 32,
              decoration: widget.decoration ??
                  BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: double.infinity,
                    child: Center(
                      child: Text(
                        widget.label ?? '',
                        style: widget.textStyle ??
                            AppFont.titleMedium.copyWith(
                              color: AppColor.textDark,
                              fontSize: 18,
                            ),
                      ),
                    ),
                  ),
                  if (widget.icon != null) ...[
                    widget.icon!,
                  ],
                ],
              ),
            ),
      ),
    );
  }
}
