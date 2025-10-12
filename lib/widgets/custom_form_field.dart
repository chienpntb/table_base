import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';

class CustomFormField extends StatefulWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final bool isRequired;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign? textAlign;
  final Color? textColorHint;

  const CustomFormField({
    super.key,
    this.label,
    this.hintText = '',
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.isRequired = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
    this.textInputAction,
    this.inputFormatters,
    this.textAlign,
    this.textColorHint,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late FocusNode _focusNode;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.isPassword;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: AppFont.labelLarge.copyWith(
                color: AppColor.textDark,
              ),
              children: [
                if (widget.isRequired) ...[
                  TextSpan(
                    text: " *",
                    style: AppFont.labelLarge.copyWith(color: Colors.red),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            color: AppColor.white,
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              style: AppFont.inputLabel.copyWith(
                color: widget.enabled ? AppColor.textDark : AppColor.textGrey,
              ),
              cursorWidth: 1,
              cursorHeight: 16,
              cursorColor: AppColor.textDark,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction ?? TextInputAction.next,
              obscureText: _obscureText,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onSaved: widget.onSaved,
              textAlign: widget.textAlign ?? TextAlign.start,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppFont.inputLabel.copyWith(
                  color: widget.textColorHint ?? AppColor.textHint,
                ),
                errorStyle: AppFont.inputLabel
                    .copyWith(color: Colors.red)
                    .copyWith(fontSize: 12),
                enabledBorder: borderForm(enabled: widget.enabled),
                focusedBorder: borderForm(enabled: widget.enabled),
                errorBorder: borderForm(color: Colors.red, width: 1.5),
                focusedErrorBorder: borderForm(color: Colors.red, width: 1.5),
                border: borderForm(enabled: widget.enabled),
                fillColor: widget.enabled ? Colors.white : Colors.grey[50],
                focusColor: widget.enabled ? Colors.white : Colors.grey[50],
                hoverColor: widget.enabled ? Colors.white : Colors.grey[50],
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                counterText: '',
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : widget.suffixIcon,
                prefixIcon: widget.prefixIcon,
              ),
              validator: (value) {
                final result = widget.validator?.call(value);
                return result;
              },
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder borderForm(
      {bool enabled = true, Color? color, double width = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
          color: enabled ? color ?? Colors.black12 : Colors.grey[200]!,
          width: width),
    );
  }
}
