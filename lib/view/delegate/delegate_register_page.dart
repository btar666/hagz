import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'delegate_success_page.dart';

class DelegateRegisterPage extends StatefulWidget {
  const DelegateRegisterPage({super.key});

  @override
  State<DelegateRegisterPage> createState() => _DelegateRegisterPageState();
}

class _DelegateRegisterPageState extends State<DelegateRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  String? _degree;
  final List<String> _attachments = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => Get.back(),
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
                ),
                SizedBox(height: 24.h),
                Container(
                  width: 160.w,
                  height: 160.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 16.h),
                MyText(
                  'تسجيل كمندوب جديد',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: MyText(
                    'اسمك الثلاثي',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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

                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: MyText(
                    'رقم الهاتف',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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

                SizedBox(height: 16.h),
                _twoDropdownsRow(),

                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: MyText(
                    'الشهادة',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                _roundedField(
                  controller: TextEditingController(text: _degree ?? ''),
                  hint: 'اكتب تحصيلك العلمي',
                  validator: (_) => null,
                  onChanged: (v) => _degree = v,
                ),

                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: MyText(
                    'ارفق البطاقة الموحدة أو جنسيتك',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                _uploadRow(),

                SizedBox(height: 16.h),
                ..._attachments
                    .asMap()
                    .entries
                    .map((e) => _attachmentTile(e.key, e.value))
                    .toList(),

                SizedBox(height: 24.h),
                SizedBox(
                  height: 64.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Get.offAll(() => const DelegateSuccessPage());
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
                      'ارسال السيرة الذاتية',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _twoDropdownsRow() {
    return Row(children: [Expanded(child: _ageDropdownField((v) {}))]);
  }

  Widget _roundedField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    required String hint,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 16.sp,
          fontFamily: 'Expo Arabic',
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
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
      style: TextStyle(fontSize: 16.sp, fontFamily: 'Expo Arabic'),
    );
  }

  Widget _dropdownField(String label, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MyText(
          label,
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
            items: const [
              DropdownMenuItem(value: 'اختر', child: Text('اختر')),
              DropdownMenuItem(value: '1', child: Text('1')),
              DropdownMenuItem(value: '2', child: Text('2')),
            ],
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

  Widget _ageDropdownField(ValueChanged<String?> onChanged) {
    final List<String> ages = List.generate(83, (i) => (18 + i).toString());
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
            items: [
              const DropdownMenuItem(value: 'اختر', child: Text('اختر')),
              ...ages.map((a) => DropdownMenuItem(value: a, child: Text(a))),
            ],
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

  Widget _uploadRow() {
    return Row(
      children: [
        Expanded(child: _uploadTile('أرفق الوجه الخلفي للبطاقة')),
        SizedBox(width: 12.w),
        Expanded(child: _uploadTile('أرفق الوجه الأمامي للبطاقة')),
      ],
    );
  }

  Widget _uploadTile(String label) {
    return InkWell(
      onTap: () async {
        // In this version, just add a placeholder filename.
        setState(() => _attachments.add('128.JPGG'));
      },
      child: Container(
        height: 110.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.textLight,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, color: AppColors.secondary, size: 36.sp),
            SizedBox(height: 10.h),
            MyText(
              label,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentTile(int index, String name) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => setState(() => _attachments.removeAt(index)),
            child: const Icon(Icons.close, color: Colors.redAccent),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: MyText(
              name,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Icon(Icons.image, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
