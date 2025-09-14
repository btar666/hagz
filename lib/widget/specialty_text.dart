import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

class SpecialtyText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SpecialtyText(
    this.text, {
    Key? key,
    this.color,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Expo Arabic',
        fontWeight: FontWeight.w600, // SemiBold
        fontSize: fontSize ?? 12.45.sp,
        height: 1.0, // line-height: 100%
        letterSpacing: 0, // letter-spacing: 0%
        color: color ?? AppColors.textSecondary,
      ),
      textAlign: textAlign ?? TextAlign.center,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
