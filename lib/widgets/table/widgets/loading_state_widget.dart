import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';

/// Widget hiển thị trạng thái đang tải dữ liệu
class LoadingStateWidget extends StatelessWidget {
  /// Thông báo hiển thị khi đang tải
  final String loadingMessage;

  /// Kích thước icon loading
  final double loadingSize;

  /// Màu icon loading
  final Color loadingColor;

  const LoadingStateWidget({
    super.key,
    this.loadingMessage = 'Đang tải dữ liệu vui lòng đợi ...',
    this.loadingSize = 42,
    this.loadingColor = AppColor.greenLight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 18),
          LoadingAnimationWidget.fourRotatingDots(
            size: loadingSize,
            color: loadingColor,
          ),
          const SizedBox(height: 12),
          Text(
            loadingMessage,
            style: AppFont.titleMedium.copyWith(
              color: AppColor.textDark,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
