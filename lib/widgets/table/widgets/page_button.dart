import 'package:flutter/material.dart';
import 'package:table_base/core/themes/app_color.dart';

class PageButton extends StatefulWidget {
  const PageButton({
    super.key,
    required this.pageIndex,
    required this.currentPage,
    required this.notifier,
  });

  final int pageIndex;
  final int currentPage;
  final dynamic notifier;

  @override
  State<PageButton> createState() => _PageButtonState();
}

class _PageButtonState extends State<PageButton> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: InkWell(
        onTap: () {
          if (widget.pageIndex != widget.currentPage) {
            widget.notifier.goToPage(widget.pageIndex);
          }
        },
        onHover: (value) {
          setState(() {
            widget.pageIndex == widget.currentPage
                ? _isHovering = false
                : _isHovering = value;
          });
        },
        child: Container(
          height: 32,
          padding: EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                _isHovering
                    ? AppColor.greenLight
                    : (widget.pageIndex == widget.currentPage
                        ? AppColor.greenLight
                        : Colors.white),
            border: Border.all(
              color:
                  _isHovering
                      ? AppColor.greenLight
                      : (widget.pageIndex == widget.currentPage
                          ? AppColor.greenLight
                          : AppColor.textGrey),
            ),
            boxShadow:
                _isHovering
                    ? [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: .2),
                        blurRadius: 4,
                        offset: const Offset(0, 6),
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child: Text(
              '${widget.pageIndex + 1}',
              style: TextStyle(
                color:
                    _isHovering
                        ? Colors.white
                        : widget.pageIndex == widget.currentPage
                        ? Colors.white
                        : AppColor.textDark,
                fontWeight:
                    _isHovering
                        ? FontWeight.bold
                        : widget.pageIndex == widget.currentPage
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
