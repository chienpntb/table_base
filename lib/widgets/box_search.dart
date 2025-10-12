import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';
import 'package:table_base/core/themes/app_icon_svg.dart';

class BoxSearch extends StatelessWidget {
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final double? width;
  final Function(String) onSearch;
  const BoxSearch({
    super.key,
    this.hintText = 'Tìm kiếm...',
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    required this.onSearch,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
      ),
      width: width ?? 200,
      height: 34,
      child: TextFormField(
        style: AppFont.inputLabel.copyWith(color: AppColor.textDark),
        cursorWidth: 1,
        cursorHeight: 12,
        cursorColor: AppColor.textDark,
        textInputAction: TextInputAction.done,
        onTap: () {},
        onChanged: (value) {
          onSearch(value);
        },
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onSaved: (value) {},
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppFont.inputLabel.copyWith(
            color: AppColor.textHint,
          ),
          errorStyle: AppFont.inputLabel
              .copyWith(color: Colors.red)
              .copyWith(fontSize: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.black12,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.black12,
              width: 1.2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.black12,
              width: 1.2,
            ),
          ),
          fillColor: Colors.white,
          focusColor: Colors.white,
          hoverColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          counterText: '',
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon ??
              Container(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: SvgPicture.asset(
                  AppIconSvg.iconSearch,
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    AppColor.textHint,
                    BlendMode.srcIn,
                  ),
                ),
              ),
        ),
        validator: (value) {
          return null;
        },
      ),
    );
  }
}
