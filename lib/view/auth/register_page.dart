import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'login_page.dart';
import '../main_page.dart';
import '../../controller/auth_controller.dart';
import '../../controller/session_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _specializationCtrl = TextEditingController();
  int? _genderIndex; // 0 male, 1 female
  String? _age; // kept for future submission

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _cityCtrl.dispose();
    _specializationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 48.h,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: 220.w,
                  height: 220.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 24.h),
                MyText(
                  'انشاء الحساب',
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                ),
                SizedBox(height: 24.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: MyText(
                    'اسم المستخدم',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 8.h),
                _roundedField(
                  controller: _nameCtrl,
                  hint: 'اكتب اسمك',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'هذا الحقل مطلوب !'
                      : null,
                ),
                SizedBox(height: 12.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: MyText(
                    'الجنس ( اضغط لاختيار )',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(child: _genderButton('ذكر', index: 0)),
                    SizedBox(width: 16.w),
                    Expanded(child: _genderButton('انثى', index: 1)),
                  ],
                ),
                SizedBox(height: 16.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: MyText(
                    'رقم الهاتف',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 8.h),
                _roundedField(
                  controller: _phoneCtrl,
                  hint: '0000 000 0000',
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'هذا الحقل مطلوب !'
                      : null,
                ),

                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: MyText(
                    'كلمة المرور',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 8.h),
                _roundedField(
                  controller: _passwordCtrl,
                  hint: '••••••••',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'هذا الحقل مطلوب !'
                      : null,
                ),

                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _ageDropdown(
                        onChanged: (value) => setState(() => _age = value),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MyText(
                            'المدينة',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 8.h),
                          _roundedField(
                            controller: _cityCtrl,
                            hint: 'مثل: القاهرة',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'هذا الحقل مطلوب !'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                Builder(
                  builder: (context) {
                    final session = Get.find<SessionController>();
                    if (session.role.value != 'doctor') {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MyText(
                          'التخصص',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 8.h),
                        _roundedField(
                          controller: _specializationCtrl,
                          hint: 'مثل: طب الأطفال',
                          validator: (v) {
                            final session = Get.find<SessionController>();
                            if (session.role.value == 'doctor' &&
                                (v == null || v.trim().isEmpty)) {
                              return 'هذا الحقل مطلوب للطبيب!';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 24.h),
                SizedBox(
                  height: 64.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final session = Get.find<SessionController>();
                        if (session.role.value == 'user' ||
                            session.role.value == 'doctor' ||
                            session.role.value == 'secretary') {
                          final auth = Get.put(AuthController());
                          auth.nameCtrl.text = _nameCtrl.text.trim();
                          auth.regPhoneCtrl.text = _phoneCtrl.text.trim();
                          auth.regPasswordCtrl.text = _passwordCtrl.text.trim();
                          auth.cityCtrl.text = _cityCtrl.text.trim();
                          auth.gender.value = _genderIndex == 0
                              ? 'ذكر'
                              : 'انثى';
                          auth.age.value = int.tryParse(_age ?? '18') ?? 18;
                          if (session.role.value == 'doctor') {
                            auth.specializationCtrl.text = _specializationCtrl
                                .text
                                .trim();
                          }
                          auth.registerUser();
                        } else {
                          Get.offAll(() => const MainPage());
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      elevation: 0,
                    ),
                    child: MyText(
                      'انشاء الحساب',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
                Center(
                  child: GestureDetector(
                    onTap: () => Get.to(
                      () => const LoginPage(),
                      binding: BindingsBuilder(() {
                        // LoginPage لا يحتاج binding خاص
                      }),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Expo Arabic',
                          fontSize: 16.sp,
                        ),
                        children: [
                          TextSpan(
                            text: 'لديك حساب؟ ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: 'سجل الدخول',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    required String hint,
    FormFieldValidator<String>? validator,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 18.sp,
          fontFamily: 'Expo Arabic',
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 18.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      style: TextStyle(fontSize: 18.sp, fontFamily: 'Expo Arabic'),
    );
  }

  Widget _genderButton(String label, {required int index}) {
    final bool isSelected = _genderIndex == index;
    return InkWell(
      onTap: () => setState(() => _genderIndex = index),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        height: 56.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : AppColors.primaryLight.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: MyText(
          label,
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // Removed unused generic dropdown; age and city have dedicated widgets

  Widget _ageDropdown({required ValueChanged<String?> onChanged}) {
    final List<String> ages = [for (int i = 18; i <= 100; i++) i.toString()];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MyText(
          'العمر',
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10.r,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: null,
            items: ages
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(border: InputBorder.none),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            style: TextStyle(
              fontFamily: 'Expo Arabic',
              fontSize: 16.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
