import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/secretary_accounts_controller.dart';
import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../service_layer/services/upload_service.dart';
import '../../widget/back_button_widget.dart';

class SecretaryAccountsPage extends StatelessWidget {
  const SecretaryAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SecretaryAccountsController());
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    SizedBox(width: 48.w),
                    Expanded(
                      child: Center(
                        child: MyText(
                          'ادارة حسابات السكرتارية',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const BackButtonWidget(),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16.h),
                          MyText(
                            controller.errorMessage.value,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => controller.fetchSecretaries(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: MyText(
                              'إعادة المحاولة',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.secretaries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 64.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16.h),
                          MyText(
                            'لا يوجد سكرتارية',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          MyText(
                            'اضغط على الزر أدناه لإضافة سكرتير جديد',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                    itemCount: controller.secretaries.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.only(right: 16.w, left: 16.w),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    itemBuilder: (_, index) {
                      final item = controller.secretaries[index];
                      return _buildSecretaryCard(
                        context,
                        controller,
                        item,
                        index,
                      );
                    },
                  );
                }),
              ),
              // Add new secretary button
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context, controller),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: MyText(
                      'اضافة سكرتير جديد',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecretaryCard(
    BuildContext context,
    SecretaryAccountsController controller,
    Map<String, dynamic> item,
    int index,
  ) {
    final isActive = item['status'] == 'نشط';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child:
                  item['image'] != null && item['image'].toString().isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        item['image'].toString(),
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
                    )
                  : Icon(Icons.person, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 12.w),

            // Secretary info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyText(
                          item['name'] ?? 'اسم السكرتير',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: MyText(
                          isActive ? 'نشط' : 'معطل',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  MyText(
                    item['phone'] ?? '',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 2.h),
                  MyText(
                    '${item['city'] ?? ''} - ${item['age'] ?? '0'} سنة',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                InkWell(
                  onTap: () => _showEditDialog(context, controller, item),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 16.sp),
                  ),
                ),
                SizedBox(width: 8.w),

                // Status toggle button
                InkWell(
                  onTap: () => _toggleStatus(context, controller, item),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.orange : Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isActive ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Delete button
                InkWell(
                  onTap: () => _confirmDelete(context, controller, item),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5252),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete, color: Colors.white, size: 16.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SecretaryAccountsController controller,
    Map<String, dynamic> item,
  ) {
    final secretaryId = item['id']?.toString() ?? '';
    final secretaryName = item['name']?.toString() ?? 'السكرتير';

    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        backgroundColor: const Color(0xFFF4FEFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF3B30),
                size: 72,
              ),
              SizedBox(height: 12.h),
              MyText(
                'حذف حساب السكرتير',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFF3B30),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              MyText(
                'هل أنت متأكد من حذف $secretaryName؟',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: MyText(
                        'الغاء',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await controller.deleteSecretary(secretaryId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: MyText(
                        'متأكد',
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

  void _toggleStatus(
    BuildContext context,
    SecretaryAccountsController controller,
    Map<String, dynamic> item,
  ) {
    final secretaryId = item['id']?.toString() ?? '';
    final currentStatus = item['status']?.toString() ?? 'نشط';
    final newStatus = currentStatus == 'نشط' ? 'معطل' : 'نشط';
    final secretaryName = item['name']?.toString() ?? 'السكرتير';

    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        backgroundColor: const Color(0xFFF4FEFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                newStatus == 'نشط' ? Icons.check_circle : Icons.pause_circle,
                color: newStatus == 'نشط' ? Colors.green : Colors.orange,
                size: 72,
              ),
              SizedBox(height: 12.h),
              MyText(
                newStatus == 'نشط' ? 'تفعيل السكرتير' : 'تعطيل السكرتير',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              MyText(
                'هل تريد ${newStatus == 'نشط' ? 'تفعيل' : 'تعطيل'} $secretaryName؟',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: MyText(
                        'الغاء',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await controller.updateSecretaryStatus(
                          secretaryId,
                          newStatus,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: newStatus == 'نشط'
                            ? Colors.green
                            : Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: MyText(
                        'متأكد',
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

  void _showAddDialog(
    BuildContext context,
    SecretaryAccountsController controller,
  ) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String selectedGender = 'ذكر';
    String? selectedCity;
    String? imageUrl;
    bool obscurePassword = true;

    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        backgroundColor: const Color(0xFFF4FEFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: MyText(
                        'اضافة سكرتير جديد',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // الاسم
                    _buildFieldLabel('الاسم *'),
                    _buildTextField(nameCtrl, 'أدخل الاسم الكامل'),
                    SizedBox(height: 16.h),

                    // رقم الهاتف
                    _buildFieldLabel('رقم الهاتف *'),
                    _buildTextField(
                      phoneCtrl,
                      '0000 000 0000',
                      TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),

                    // كلمة المرور
                    _buildFieldLabel('كلمة المرور *'),
                    _buildPasswordField(passwordCtrl, obscurePassword, (value) {
                      setState(() => obscurePassword = value);
                    }),
                    SizedBox(height: 16.h),

                    // الجنس
                    _buildFieldLabel('الجنس *'),
                    _buildGenderSelector(selectedGender, (value) {
                      setState(() => selectedGender = value);
                    }),
                    SizedBox(height: 16.h),

                    // العمر
                    _buildFieldLabel('العمر *'),
                    _buildTextField(ageCtrl, '25', TextInputType.number),
                    SizedBox(height: 16.h),

                    // المدينة
                    _buildFieldLabel('المدينة *'),
                    _buildCityDropdown(cityCtrl, selectedCity, (value) {
                      setState(() {
                        selectedCity = value;
                        cityCtrl.text = value ?? '';
                      });
                    }),
                    SizedBox(height: 16.h),

                    // العنوان
                    _buildFieldLabel('العنوان *'),
                    _buildTextField(addressCtrl, 'أدخل العنوان التفصيلي'),
                    SizedBox(height: 16.h),

                    // الصورة
                    _buildFieldLabel('الصورة الشخصية (اختيارية)'),
                    _buildImageSelector(imageUrl, (url) {
                      setState(() => imageUrl = url);
                    }),
                    SizedBox(height: 24.h),

                    // أزرار
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: MyText(
                              'الغاء',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: controller.isCreating.value
                                  ? null
                                  : () async {
                                      final name = nameCtrl.text.trim();
                                      final phone = phoneCtrl.text.trim();
                                      final password = passwordCtrl.text.trim();
                                      final city = cityCtrl.text.trim();
                                      final address = addressCtrl.text.trim();
                                      final age =
                                          int.tryParse(ageCtrl.text.trim()) ??
                                          0;

                                      if (name.isEmpty ||
                                          phone.isEmpty ||
                                          password.isEmpty ||
                                          city.isEmpty ||
                                          address.isEmpty ||
                                          age <= 0) {
                                        Get.snackbar(
                                          'خطأ',
                                          'يرجى ملء جميع الحقول المطلوبة',
                                          backgroundColor: const Color(
                                            0xFFFF3B30,
                                          ),
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }

                                      final success = await controller
                                          .createSecretary(
                                            name: name,
                                            phone: phone,
                                            password: password,
                                            gender: selectedGender,
                                            age: age,
                                            city: city,
                                            address: address,
                                            image: imageUrl ?? '',
                                          );

                                      if (success) {
                                        Get.back();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                elevation: 0,
                              ),
                              child: controller.isCreating.value
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : MyText(
                                      'اضافة',
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MyText(
        label,
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, [
    TextInputType? keyboardType,
  ]) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.divider),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
        style: const TextStyle(fontFamily: 'Expo Arabic'),
      ),
    );
  }

  Widget _buildCityDropdown(
    TextEditingController cityCtrl,
    String? selectedCity,
    Function(String?) onChanged,
  ) {
    const List<String> allowedCities = [
      'بغداد',
      'البصرة',
      'نينوى',
      'أربيل',
      'النجف',
      'كربلاء',
      'الأنبار',
      'ديالى',
      'صلاح الدين',
      'واسط',
      'ذي قار',
      'بابل',
      'كركوك',
      'السليمانية',
      'المثنى',
      'القادسية',
      'ميسان',
      'دهوك',
    ];

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCity,
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
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
          size: 24.r,
        ),
        style: TextStyle(
          fontFamily: 'Expo Arabic',
          fontSize: 14.sp,
          color: AppColors.textPrimary,
        ),
        items: allowedCities
            .map(
              (c) => DropdownMenuItem<String>(
                value: c,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MyText(
                    c,
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    bool obscureText,
    Function(bool) onToggle,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.divider),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'أدخل كلمة المرور',
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textSecondary,
            ),
            onPressed: () => onToggle(!obscureText),
          ),
        ),
        style: const TextStyle(fontFamily: 'Expo Arabic'),
      ),
    );
  }

  Widget _buildGenderSelector(
    String selectedGender,
    Function(String) onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: MyText(
                'ذكر',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              value: 'ذكر',
              groupValue: selectedGender,
              onChanged: (value) => onChanged(value!),
              activeColor: AppColors.primary,
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: MyText(
                'أنثى',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              value: 'أنثى',
              groupValue: selectedGender,
              onChanged: (value) => onChanged(value!),
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelector(
    String? currentImage,
    Function(String?) onImageSelected,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      child: Column(
        children: [
          if (currentImage != null && currentImage.isNotEmpty)
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  currentImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: 40.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          SizedBox(height: 8.h),
          ElevatedButton.icon(
            onPressed: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                final uploadService = UploadService();
                final result = await uploadService.uploadImage(
                  File(image.path),
                );
                if (result['ok'] == true) {
                  final url = result['data']?['data']?['url']?.toString() ?? '';
                  if (url.isNotEmpty) {
                    onImageSelected(url);
                  }
                }
              }
            },
            icon: Icon(Icons.camera_alt, size: 18.sp),
            label: MyText(
              currentImage != null ? 'تغيير الصورة' : 'اختيار صورة',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    SecretaryAccountsController controller,
    Map<String, dynamic> item,
  ) {
    final secretaryId = item['id']?.toString() ?? '';
    final nameCtrl = TextEditingController(
      text: item['name']?.toString() ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: item['phone']?.toString() ?? '',
    );
    final cityCtrl = TextEditingController(
      text: item['city']?.toString() ?? '',
    );
    final addressCtrl = TextEditingController(
      text: item['address']?.toString() ?? '',
    );
    final ageCtrl = TextEditingController(text: item['age']?.toString() ?? '');
    String selectedGender = item['gender']?.toString() ?? 'ذكر';
    String? selectedCity = item['city']?.toString();
    String? imageUrl = item['image']?.toString();

    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        backgroundColor: const Color(0xFFF4FEFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: MyText(
                        'تعديل معلومات السكرتير',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // الاسم
                    _buildFieldLabel('الاسم *'),
                    _buildTextField(nameCtrl, 'أدخل الاسم الكامل'),
                    SizedBox(height: 16.h),

                    // رقم الهاتف
                    _buildFieldLabel('رقم الهاتف *'),
                    _buildTextField(
                      phoneCtrl,
                      '0000 000 0000',
                      TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),

                    // الجنس
                    _buildFieldLabel('الجنس *'),
                    _buildGenderSelector(selectedGender, (value) {
                      setState(() => selectedGender = value);
                    }),
                    SizedBox(height: 16.h),

                    // العمر
                    _buildFieldLabel('العمر *'),
                    _buildTextField(ageCtrl, '25', TextInputType.number),
                    SizedBox(height: 16.h),

                    // المدينة
                    _buildFieldLabel('المدينة *'),
                    _buildCityDropdown(cityCtrl, selectedCity, (value) {
                      setState(() {
                        selectedCity = value;
                        cityCtrl.text = value ?? '';
                      });
                    }),
                    SizedBox(height: 16.h),

                    // العنوان
                    _buildFieldLabel('العنوان *'),
                    _buildTextField(addressCtrl, 'أدخل العنوان التفصيلي'),
                    SizedBox(height: 16.h),

                    // الصورة
                    _buildFieldLabel('الصورة الشخصية'),
                    _buildImageSelector(imageUrl, (url) {
                      setState(() => imageUrl = url);
                    }),
                    SizedBox(height: 24.h),

                    // أزرار
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: MyText(
                              'الغاء',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = nameCtrl.text.trim();
                              final phone = phoneCtrl.text.trim();
                              final city = cityCtrl.text.trim();
                              final address = addressCtrl.text.trim();
                              final age =
                                  int.tryParse(ageCtrl.text.trim()) ?? 0;

                              if (name.isEmpty ||
                                  phone.isEmpty ||
                                  city.isEmpty ||
                                  address.isEmpty ||
                                  age <= 0) {
                                Get.snackbar(
                                  'خطأ',
                                  'يرجى ملء جميع الحقول المطلوبة',
                                  backgroundColor: const Color(0xFFFF3B30),
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              final success = await controller.updateSecretary(
                                secretaryId: secretaryId,
                                name: name,
                                phone: phone,
                                city: city,
                                address: address,
                                age: age,
                                image: imageUrl,
                              );

                              if (success) {
                                Get.back();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              elevation: 0,
                            ),
                            child: MyText(
                              'حفظ التعديلات',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // زر تغيير كلمة المرور
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          _showChangePasswordDialog(
                            context,
                            controller,
                            secretaryId,
                            item['name']?.toString() ?? 'السكرتير',
                          );
                        },
                        icon: Icon(Icons.lock, size: 18.sp),
                        label: MyText(
                          'تغيير كلمة المرور',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange),
                          foregroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    SecretaryAccountsController controller,
    String secretaryId,
    String secretaryName,
  ) {
    final passwordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        backgroundColor: const Color(0xFFF4FEFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: MyText(
                      'تغيير كلمة المرور',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: MyText(
                      'للسكرتير: $secretaryName',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // كلمة المرور الجديدة
                  _buildFieldLabel('كلمة المرور الجديدة *'),
                  _buildPasswordField(passwordCtrl, obscurePassword, (value) {
                    setState(() => obscurePassword = value);
                  }),
                  SizedBox(height: 16.h),

                  // تأكيد كلمة المرور
                  _buildFieldLabel('تأكيد كلمة المرور *'),
                  _buildPasswordField(
                    confirmPasswordCtrl,
                    obscureConfirmPassword,
                    (value) {
                      setState(() => obscureConfirmPassword = value);
                    },
                  ),
                  SizedBox(height: 24.h),

                  // أزرار
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: MyText(
                            'الغاء',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final password = passwordCtrl.text.trim();
                            final confirmPassword = confirmPasswordCtrl.text
                                .trim();

                            if (password.isEmpty || confirmPassword.isEmpty) {
                              Get.snackbar(
                                'خطأ',
                                'يرجى ملء جميع الحقول',
                                backgroundColor: const Color(0xFFFF3B30),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (password != confirmPassword) {
                              Get.snackbar(
                                'خطأ',
                                'كلمة المرور غير متطابقة',
                                backgroundColor: const Color(0xFFFF3B30),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (password.length < 6) {
                              Get.snackbar(
                                'خطأ',
                                'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                                backgroundColor: const Color(0xFFFF3B30),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final success = await controller
                                .changeSecretaryPassword(secretaryId, password);

                            if (success) {
                              Get.back();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            elevation: 0,
                          ),
                          child: MyText(
                            'تغيير كلمة المرور',
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
            );
          },
        ),
      ),
    );
  }
}
