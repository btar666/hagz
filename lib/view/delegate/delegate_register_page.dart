import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';
import '../../controller/locale_controller.dart';
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
                GetBuilder<LocaleController>(
                  builder: (localeController) {
                    return MyText(
                      'register_as_delegate'.tr,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    );
                  },
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
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'full_name'.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _roundedField(
              controller: c.nameCtrl,
              hint: 'enter_your_full_name'.tr,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'field_required'.tr : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhoneField(DelegateRegisterController c) {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'phone_number'.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _roundedField(
              controller: c.phoneCtrl,
              hint: 'phone_number_hint'.tr,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'field_required'.tr : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField(DelegateRegisterController c) {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'password'.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _roundedField(
              controller: c.passwordCtrl,
              hint: 'enter_password'.tr,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'field_required'.tr : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompanyField(DelegateRegisterController c) {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'company_name'.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _roundedField(
              controller: c.companyCtrl,
              hint: 'enter_company_name'.tr,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'field_required'.tr : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddressField(DelegateRegisterController c) {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'address'.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _roundedField(
              controller: c.addressCtrl,
              hint: 'enter_address'.tr,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'field_required'.tr : null,
            ),
          ],
        );
      },
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
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'certificate'.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            _roundedField(
              controller: c.certificateCtrl,
              hint: 'enter_education'.tr,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'field_required'.tr : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildIdCardSection(DelegateRegisterController c) {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: MyText(
                'upload_id_card'.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildIdUploadTile(c, 'upload_id_back'.tr, false),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildIdUploadTile(c, 'upload_id_front'.tr, true),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton(DelegateRegisterController c) {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
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
              'submit_cv'.tr,
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgeDropdown(DelegateRegisterController c) {
    final List<String> ages = [for (int i = 18; i <= 100; i++) i.toString()];
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MyText(
              'age'.tr,
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
                  key: ValueKey(
                    'age_dropdown_${localeController.selectedLanguage.value}',
                  ),
                  value: c.selectedAge.value,
                  isExpanded: true,
                  menuMaxHeight: 400.h,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'select_age'.tr,
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
                      borderSide: BorderSide(
                        color: AppColors.textLight,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
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
                      borderSide: BorderSide(
                        color: AppColors.textLight,
                        width: 1,
                      ),
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
                                ? Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  )
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
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'field_required'.tr
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCityDropdown(DelegateRegisterController c) {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MyText(
              'province'.tr,
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
                  key: ValueKey(
                    'city_dropdown_${localeController.selectedLanguage.value}',
                  ),
                  value: c.selectedCity.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppColors.textLight,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
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
                      borderSide: BorderSide(
                        color: AppColors.textLight,
                        width: 1,
                      ),
                    ),
                  ),
                  hint: MyText(
                    'select_province'.tr,
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
      },
    );
  }

  Widget _buildGenderSelector(DelegateRegisterController c) {
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MyText(
              'gender'.tr,
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
                        'male'.tr,
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
                        'female'.tr,
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
      },
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
              GetBuilder<LocaleController>(
                builder: (localeController) {
                  return MyText(
                    isUploaded ? 'uploaded'.tr : label,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isUploaded
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  );
                },
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
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return TextFormField(
          key: ValueKey(
            'rounded_field_${localeController.selectedLanguage.value}_$hint',
          ),
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
          style: TextStyle(
            fontFamily: 'Expo Arabic',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        );
      },
    );
  }
}
