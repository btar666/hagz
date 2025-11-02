import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';
import '../../controller/delegate_register_controller.dart';

class DelegateRegisterPage extends StatelessWidget {
  const DelegateRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DelegateRegisterController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.h),
                const Align(
                  alignment: Alignment.centerRight,
                  child: BackButtonWidget(),
                ),
                SizedBox(height: 24.h),
                _buildProfileImage(controller),
                SizedBox(height: 24.h),
                MyText(
                  'تسجيل كمندوب جديد',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),

                _buildNameField(controller),
                SizedBox(height: 16.h),
                _buildPhoneField(controller),
                SizedBox(height: 16.h),
                _buildPasswordField(controller),
                SizedBox(height: 16.h),
                _buildCompanyField(controller),
                SizedBox(height: 16.h),
                _buildAddressField(controller),
                SizedBox(height: 16.h),
                _buildAgeCityRow(controller),
                SizedBox(height: 16.h),
                _buildGenderSelector(controller),
                SizedBox(height: 20.h),
                _buildCertificateField(controller),
                SizedBox(height: 20.h),
                _buildIdCardSection(controller),
                SizedBox(height: 24.h),
                _buildSubmitButton(controller),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(DelegateRegisterController c) {
    return Obx(
      () => GestureDetector(
        onTap: c.uploadingImage.value
            ? null
            : () => c.pickAndUploadImage('profile'),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 220.w,
              height: 220.w,
              decoration: const BoxDecoration(
                color: Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: c.profileImageUrl.value == null
                  ? const Icon(Icons.person, size: 80, color: Colors.white)
                  : Image.network(
                      c.profileImageUrl.value!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
            ),
            Positioned(
              bottom: 12.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  c.uploadingImage.value
                      ? Icons.hourglass_top
                      : Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(DelegateRegisterController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
          controller: c.nameCtrl,
          hint: 'اكتب اسمك',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب !' : null,
        ),
      ],
    );
  }

  Widget _buildPhoneField(DelegateRegisterController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
          controller: c.phoneCtrl,
          hint: '0000 000 0000',
          keyboardType: TextInputType.phone,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب !' : null,
        ),
      ],
    );
  }

  Widget _buildPasswordField(DelegateRegisterController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: MyText(
            'كلمة المرور',
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        _roundedField(
          controller: c.passwordCtrl,
          hint: 'أدخل كلمة المرور',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب !' : null,
        ),
      ],
    );
  }

  Widget _buildCompanyField(DelegateRegisterController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: MyText(
            'اسم الشركة',
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        _roundedField(
          controller: c.companyCtrl,
          hint: 'اكتب اسم الشركة',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب !' : null,
        ),
      ],
    );
  }

  Widget _buildAddressField(DelegateRegisterController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: MyText(
            'العنوان',
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        _roundedField(
          controller: c.addressCtrl,
          hint: 'اكتب عنوانك',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب !' : null,
        ),
      ],
    );
  }

  Widget _buildAgeCityRow(DelegateRegisterController c) {
    return Row(
      children: [
        Expanded(child: _buildAgeDropdown(c)),
        SizedBox(width: 16.w),
        Expanded(child: _buildCityDropdown(c)),
      ],
    );
  }

  Widget _buildCertificateField(DelegateRegisterController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
          controller: c.certificateCtrl,
          hint: 'اكتب تحصيلك العلمي',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب !' : null,
        ),
      ],
    );
  }

  Widget _buildIdCardSection(DelegateRegisterController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
        Row(
          children: [
            Expanded(
              child: _buildIdUploadTile(c, 'أرفق الوجه الخلفي للبطاقة', false),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildIdUploadTile(c, 'أرفق الوجه الأمامي للبطاقة', true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(DelegateRegisterController c) {
    return SizedBox(
      height: 64.h,
      child: ElevatedButton(
        onPressed: c.registerDelegate,
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
    );
  }

  Widget _buildAgeDropdown(DelegateRegisterController c) {
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: c.selectedAge.value,
              isExpanded: true,
              menuMaxHeight: 400.h,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'اختر العمر',
                hintStyle: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18.sp,
                  fontFamily: 'Expo Arabic',
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.textLight, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 1),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.textLight, width: 1),
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 24.r,
              ),
              style: TextStyle(
                fontFamily: 'Expo Arabic',
                fontSize: 18.sp,
                color: AppColors.textPrimary,
              ),
              selectedItemBuilder: (BuildContext context) {
                return ages.map((String age) {
                  return Align(
                    alignment: Alignment.center,
                    child: MyText(
                      age,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  );
                }).toList();
              },
              items: ages.map((String age) {
                final isSelected = c.selectedAge.value == age;
                return DropdownMenuItem<String>(
                  value: age,
                  child: SizedBox(
                    height: 52.h,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 1.5)
                            : Border.all(
                                color: AppColors.textLight.withOpacity(0.2),
                                width: 1,
                              ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: MyText(
                              age,
                              fontSize: 18.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16.r,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) => c.selectedAge.value = v,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'هذا الحقل مطلوب !' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown(DelegateRegisterController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MyText(
          'المحافظة',
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: c.selectedCity.value,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.textLight, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 1),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.textLight, width: 1),
                ),
              ),
              hint: MyText(
                'اختر المحافظة',
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              items: c.allowedCities
                  .map(
                    (city) => DropdownMenuItem<String>(
                      value: city,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: MyText(
                          city,
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                c.selectedCity.value = v;
                c.cityCtrl.text = v ?? '';
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(DelegateRegisterController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MyText(
          'الجنس',
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 8.h),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile<int>(
                  value: 0,
                  groupValue: c.genderIndex.value,
                  onChanged: (val) => c.genderIndex.value = val,
                  title: MyText(
                    'ذكر',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<int>(
                  value: 1,
                  groupValue: c.genderIndex.value,
                  onChanged: (val) => c.genderIndex.value = val,
                  title: MyText(
                    'أنثى',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdUploadTile(
    DelegateRegisterController c,
    String label,
    bool isFront,
  ) {
    return Obx(() {
      final isUploaded = isFront
          ? c.idFrontImageUrl.value != null
          : c.idBackImageUrl.value != null;

      return InkWell(
        onTap: () async {
          await c.pickAndUploadImage(isFront ? 'idFront' : 'idBack');
        },
        child: Container(
          height: 110.h,
          decoration: BoxDecoration(
            color: isUploaded
                ? AppColors.primary.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isUploaded ? AppColors.primary : AppColors.textLight,
              style: BorderStyle.solid,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUploaded ? Icons.check_circle : Icons.image,
                color: isUploaded ? AppColors.primary : AppColors.secondary,
                size: 36.sp,
              ),
              SizedBox(height: 10.h),
              MyText(
                isUploaded ? 'تم الرفع' : label,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isUploaded ? AppColors.primary : AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.textLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.textLight, width: 1),
        ),
      ),
      style: TextStyle(
        fontFamily: 'Expo Arabic',
        fontWeight: FontWeight.w700,
        fontSize: 16.sp,
      ),
    );
  }
}
