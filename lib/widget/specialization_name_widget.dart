import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../service_layer/services/specialization_service.dart';
import '../model/specialization_model.dart';
import '../widget/my_text.dart';
import '../utils/app_colors.dart';

class SpecializationNameWidget extends StatefulWidget {
  final String? specializationId;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final String defaultText;
  final TextStyle? style;

  const SpecializationNameWidget({
    Key? key,
    required this.specializationId,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.defaultText = 'غير محدد',
    this.style,
  }) : super(key: key);

  @override
  State<SpecializationNameWidget> createState() => _SpecializationNameWidgetState();
}

class _SpecializationNameWidgetState extends State<SpecializationNameWidget> {
  final SpecializationService _specializationService = SpecializationService();
  SpecializationModel? _specialization;
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchSpecialization();
  }

  @override
  void didUpdateWidget(SpecializationNameWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.specializationId != widget.specializationId) {
      _fetchSpecialization();
    }
  }

  Future<void> _fetchSpecialization() async {
    if (widget.specializationId == null || widget.specializationId!.isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final specialization = await _specializationService.getSpecializationById(widget.specializationId!);
      if (mounted) {
        setState(() {
          _specialization = specialization;
          _loading = false;
          _error = specialization == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.specializationId == null || widget.specializationId!.isEmpty) {
      return _buildText(widget.defaultText);
    }

    if (_loading) {
      return SizedBox(
        width: 16.w,
        height: 16.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.color ?? AppColors.textSecondary,
          ),
        ),
      );
    }

    if (_error || _specialization == null) {
      return _buildText('خطأ في التحميل');
    }

    return _buildText(_specialization!.name);
  }

  Widget _buildText(String text) {
    if (widget.style != null) {
      return Text(text, style: widget.style, textAlign: widget.textAlign);
    }

    return MyText(
      text,
      fontSize: widget.fontSize ?? 16.sp,
      fontWeight: widget.fontWeight ?? FontWeight.w400,
      color: widget.color ?? AppColors.textPrimary,
      textAlign: widget.textAlign ?? TextAlign.start,
    );
  }
}