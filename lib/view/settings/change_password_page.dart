import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/change_password_controller.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangePasswordController c = Get.find<ChangePasswordController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4FEFF),
        elevation: 0,
        title: MyText(
          'تغيير كلمة السر',
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: c.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('كلمة السر الحالية'),
                      SizedBox(height: 8.h),
                      _roundedPasswordField(
                        controller: c.oldCtrl,
                        hint: 'ادخل كلمة السر الحالية',
                        hideRx: c.hideOld,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'يرجى إدخال كلمة السر الحالية'
                            : null,
                      ),
                      SizedBox(height: 16.h),

                      _label('كلمة السر الجديدة'),
                      SizedBox(height: 8.h),
                      _roundedPasswordField(
                        controller: c.newCtrl,
                        hint: 'ادخل كلمة السر الجديدة',
                        hideRx: c.hideNew,
                        validator: (v) => (v == null || v.trim().length < 6)
                            ? 'كلمة السر يجب أن تكون 6 أحرف على الأقل'
                            : null,
                      ),

                      SizedBox(height: 28.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFFFB74D),
                                ),
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
                              onPressed: c.save,
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
          },
        ),
      ),
    );
  }
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

Widget _roundedPasswordField({
  required TextEditingController controller,
  required String hint,
  required RxBool hideRx,
  String? Function(String?)? validator,
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
    child: Obx(
      () => TextFormField(
        controller: controller,
        obscureText: hideRx.value,
        textAlign: TextAlign.right,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
          suffixIcon: IconButton(
            onPressed: () => hideRx.value = !hideRx.value,
            icon: Icon(
              hideRx.value ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        style: TextStyle(fontSize: 16.sp),
      ),
    ),
  );
}
