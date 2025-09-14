import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

class MyText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final double? letterSpacing;
  final String? fontFamily;

  const MyText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.letterSpacing,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: fontFamily ?? 'Expo Arabic', // Default font
        fontWeight: fontWeight ?? FontWeight.w700, // Bold
        fontSize: fontSize ?? 12.45.sp, // Default size
        color: color ?? AppColors.textPrimary, // Default color
        height: height ?? 1.0, // line-height: 100%
        letterSpacing: letterSpacing ?? 0.0, // letter-spacing: 0%
      ),
      textAlign: textAlign ?? TextAlign.center, // Default text align
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
