import 'package:flutter/material.dart';
import 'package:table_base/core/themes/app_color.dart';

/// Widget hiển thị nút collapse/expand với animation
class CollapseExpandButton extends StatefulWidget {
  /// Trạng thái hiện tại: true = collapsed, false = expanded
  final bool isCollapsed;
  
  /// Callback khi người dùng nhấn vào nút
  final VoidCallback onTap;
  
  /// Kích thước của icon
  final double iconSize;
  
  /// Màu của icon
  final Color? iconColor;
  
  /// Có hiển thị animation không
  final bool enableAnimation;
  
  /// Thời gian animation (milliseconds)
  final int animationDuration;

  const CollapseExpandButton({
    super.key,
    required this.isCollapsed,
    required this.onTap,
    this.iconSize = 16.0,
    this.iconColor,
    this.enableAnimation = true,
    this.animationDuration = 200,
  });

  @override
  State<CollapseExpandButton> createState() => _CollapseExpandButtonState();
}

class _CollapseExpandButtonState extends State<CollapseExpandButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // 180 độ = 0.5 * 2π
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Khởi tạo trạng thái animation dựa trên isCollapsed
    if (!widget.isCollapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CollapseExpandButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Cập nhật animation khi trạng thái thay đổi
    if (oldWidget.isCollapsed != widget.isCollapsed) {
      if (widget.enableAnimation) {
        if (widget.isCollapsed) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      } else {
        // Không có animation, cập nhật ngay lập tức
        _animationController.value = widget.isCollapsed ? 0.0 : 1.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Colors.transparent,
        ),
        child: widget.enableAnimation
            ? AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: widget.iconSize,
                      color: widget.iconColor ?? AppColor.textGrey,
                    ),
                  );
                },
              )
            : Icon(
                widget.isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_down,
                size: widget.iconSize,
                color: widget.iconColor ?? AppColor.textGrey,
              ),
      ),
    );
  }
}

/// Widget hiển thị nội dung có thể collapse/expand với animation
class CollapsibleContent extends StatefulWidget {
  /// Nội dung bên trong
  final Widget child;
  
  /// Có collapsed không
  final bool collapsed;
  
  /// Thời gian animation (milliseconds)
  final int animationDuration;
  
  /// Curve animation
  final Curve curve;
  
  /// Có hiển thị animation không
  final bool enableAnimation;

  const CollapsibleContent({
    super.key,
    required this.child,
    required this.collapsed,
    this.animationDuration = 300,
    this.curve = Curves.easeInOut,
    this.enableAnimation = true,
  });

  @override
  State<CollapsibleContent> createState() => _CollapsibleContentState();
}

class _CollapsibleContentState extends State<CollapsibleContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );
    
    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));

    // Khởi tạo trạng thái animation
    if (!widget.collapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CollapsibleContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Cập nhật animation khi trạng thái thay đổi
    if (oldWidget.collapsed != widget.collapsed) {
      if (widget.enableAnimation) {
        if (widget.collapsed) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      } else {
        // Không có animation, cập nhật ngay lập tức
        _animationController.value = widget.collapsed ? 0.0 : 1.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableAnimation) {
      return widget.collapsed ? const SizedBox.shrink() : widget.child;
    }

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _heightAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Widget hiển thị hàng với khả năng collapse/expand
class CollapsibleTableRow extends StatelessWidget {
  /// Nội dung hàng cha
  final Widget parentRow;
  
  /// Nội dung các hàng con
  final List<Widget> childRows;
  
  /// Có collapsed không
  final bool collapsed;
  
  /// Callback khi toggle collapse
  final VoidCallback onToggleCollapse;
  
  /// Màu nền cho hàng con
  final Color? childRowBackgroundColor;
  
  /// Padding cho hàng con
  final EdgeInsets childRowPadding;
  
  /// Có hiển thị animation không
  final bool enableAnimation;

  const CollapsibleTableRow({
    super.key,
    required this.parentRow,
    required this.childRows,
    required this.collapsed,
    required this.onToggleCollapse,
    this.childRowBackgroundColor,
    this.childRowPadding = const EdgeInsets.only(left: 24.0),
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hàng cha
        parentRow,
        // Các hàng con với animation
        CollapsibleContent(
          collapsed: collapsed,
          enableAnimation: enableAnimation,
          child: Container(
            color: childRowBackgroundColor ?? Colors.grey.shade50,
            child: Column(
              children: childRows.map((childRow) {
                return Padding(
                  padding: childRowPadding,
                  child: childRow,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
