import 'package:flutter/material.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';

class BaseFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final List<Widget> formFields;
  final List<Widget>? additionalWidgets;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String saveButtonText;
  final String cancelButtonText;
  final EdgeInsets? padding;
  final double? spacing;
  final double? columnSpacing;
  final int columns;

  const BaseFormWidget({
    super.key,
    required this.formKey,
    required this.title,
    required this.formFields,
    this.additionalWidgets,
    this.onSave,
    this.onCancel,
    this.saveButtonText = 'Lưu',
    this.cancelButtonText = 'Hủy',
    this.padding = const EdgeInsets.all(24),
    this.spacing = 12.0,
    this.columnSpacing = 24.0,
    this.columns = 2,
  }) : assert(columns >= 1 && columns <= 4, 'Số cột phải từ 1 đến 4');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: AppFont.appBarTitle,
            ),
            SizedBox(height: spacing),
            
            // Form fields in columns
            _buildMultiColumnLayout(),
            
            // Additional widgets (như UserSelectionRadio)
            if (additionalWidgets != null) ...[
              SizedBox(height: spacing),
              ...additionalWidgets!,
            ],
            
            SizedBox(height: spacing),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiColumnLayout() {
    // Nếu chỉ có 1 cột, hiển thị dạng dọc
    if (columns == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildColumnWithSpacing(formFields),
      );
    }

    // Chia danh sách form fields thành các cột đều
    final List<List<Widget>> columnFields = _divideIntoColumns(formFields, columns);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(columns, (index) {
        final isLastColumn = index == columns - 1;
        final isFirstColumn = index == 0;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: isFirstColumn ? 0 : columnSpacing! / 2,
              right: isLastColumn ? 0 : columnSpacing! / 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildColumnWithSpacing(columnFields[index]),
            ),
          ),
        );
      }),
    );
  }

  /// Chia danh sách widgets thành số cột chỉ định
  List<List<Widget>> _divideIntoColumns(List<Widget> widgets, int columnCount) {
    final List<List<Widget>> result = List.generate(columnCount, (_) => <Widget>[]);
    
    for (int i = 0; i < widgets.length; i++) {
      final columnIndex = i % columnCount;
      result[columnIndex].add(widgets[i]);
    }
    
    return result;
  }

  List<Widget> _buildColumnWithSpacing(List<Widget> widgets) {
    List<Widget> result = [];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      // Thêm spacing giữa các widget, trừ widget cuối cùng
      if (i < widgets.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onSave != null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.greenLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: onSave,
            child: Text(
              saveButtonText,
              style: AppFont.buttonText.copyWith(color: Colors.white),
            ),
          ),
        
        if (onSave != null && onCancel != null) SizedBox(width: 12),
        
        if (onCancel != null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.greenDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: onCancel,
            child: Text(
              cancelButtonText,
              style: AppFont.buttonText.copyWith(color: Colors.white),
            ),
          ),
      ],
    );
  }
}