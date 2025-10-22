import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../service_layer/services/specialization_cache_service.dart';
import '../widget/my_text.dart';
import '../utils/app_colors.dart';

/// Widget بسيط لعرض اسم الاختصاص
class SpecializationText extends StatelessWidget {
  final String? specializationId;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final String defaultText;

  const SpecializationText({
    Key? key,
    required this.specializationId,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.defaultText = 'غير محدد',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: SpecializationCacheService().getSpecializationName(
        specializationId,
        defaultName: defaultText,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.textSecondary,
              ),
            ),
          );
        }

        final text = snapshot.data ?? defaultText;
        
        return MyText(
          text,
          fontSize: fontSize ?? 16.sp,
          fontWeight: fontWeight ?? FontWeight.w400,
          color: color ?? AppColors.textPrimary,
          textAlign: textAlign ?? TextAlign.start,
        );
      },
    );
  }
}

/// Widget للاستخدام مع StreamBuilder أو ValueListenableBuilder
class SpecializationTextSync extends StatelessWidget {
  final String? specializationId;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final String defaultText;

  const SpecializationTextSync({
    Key? key,
    required this.specializationId,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.defaultText = 'غير محدد',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (specializationId == null || specializationId!.isEmpty) {
      return _buildText(defaultText);
    }

    final cache = SpecializationCacheService();
    
    // إذا كان موجود في الـ cache، اعرضه مباشرة
    if (cache.isSpecializationCached(specializationId!)) {
      final cachedSpecializations = cache.getCachedSpecializations();
      final specialization = cachedSpecializations.firstWhere(
        (spec) => spec.id == specializationId,
        orElse: () => cachedSpecializations.first, // fallback
      );
      return _buildText(specialization.name);
    }

    // وإلا اعرض النص الافتراضي وحمّل في الخلفية
    cache.getSpecializationById(specializationId!);
    return _buildText(defaultText);
  }

  Widget _buildText(String text) {
    return MyText(
      text,
      fontSize: fontSize ?? 16.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? AppColors.textPrimary,
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}