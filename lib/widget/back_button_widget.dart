import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? size;

  const BackButtonWidget({
    super.key,
    this.onTap,
    this.backgroundColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.back(),
      child: Container(
        width: size?.w ?? 48.w,
        height: size?.w ?? 48.w,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Image.asset(
            'assets/icons/home/back.png',
            width: 20.w,
            height: 20.w,
            color: Colors.white,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if image not found
              return const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              );
            },
          ),
        ),
      ),
    );
  }
}
