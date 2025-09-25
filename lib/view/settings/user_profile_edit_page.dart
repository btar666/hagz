import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';

class UserProfileEditPage extends StatefulWidget {
  const UserProfileEditPage({super.key});

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  final _nameCtrl = TextEditingController(text: 'آرين');
  final _phoneCtrl = TextEditingController(text: '0000 0000 0000');
  int _genderIndex = 1; // 0 ذكر - 1 انثى
  String _city = 'دهوك';
  String _age = '22';

  final List<String> _cities = const ['دهوك', 'أربيل', 'السليمانية', 'بغداد'];
  final List<String> _ages = [for (int i = 10; i <= 80; i++) i.toString()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        title: MyText(
          'تعديل الملف الشخصي',
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name label
              _label('اسم المستخدم'),
              SizedBox(height: 8.h),
              _roundedField(controller: _nameCtrl, hint: 'اكتب اسمك'),
              SizedBox(height: 16.h),

              // Gender label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_label('الجنس ( اضغط للاختيار )'), const SizedBox()],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(child: _genderButton('ذكر', 0)),
                  SizedBox(width: 16.w),
                  Expanded(child: _genderButton('انثى', 1)),
                ],
              ),
              SizedBox(height: 16.h),

              _label('رقم الهاتف'),
              SizedBox(height: 8.h),
              _roundedField(
                controller: _phoneCtrl,
                hint: '0000 0000 0000',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(child: _label('المدينة')),
                  Expanded(child: _label('العمر')),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      value: _city,
                      items: _cities,
                      onChanged: (v) => setState(() => _city = v ?? _city),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _dropdown(
                      value: _age,
                      items: _ages,
                      onChanged: (v) => setState(() => _age = v ?? _age),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFB74D)),
                        foregroundColor: const Color(0xFFFFB74D),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                      ),
                      child: MyText(
                        'الغاء',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFB74D),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: send update to backend
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB74D),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        elevation: 0,
                      ),
                      child: MyText(
                        'حفظ',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return MyText(
      text,
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      textAlign: TextAlign.right,
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  Widget _genderButton(String label, int index) {
    final bool isSelected = _genderIndex == index;
    return InkWell(
      onTap: () => setState(() => _genderIndex = index),
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        height: 64.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: MyText(
          label,
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
