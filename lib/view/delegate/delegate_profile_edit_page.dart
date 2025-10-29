import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';
import '../../controller/session_controller.dart';
import '../../service_layer/services/user_service.dart';
import '../../service_layer/services/upload_service.dart';
import '../../widget/status_dialog.dart';

class DelegateProfileEditPage extends StatefulWidget {
  const DelegateProfileEditPage({super.key});

  @override
  State<DelegateProfileEditPage> createState() =>
      _DelegateProfileEditPageState();
}

class _DelegateProfileEditPageState extends State<DelegateProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String _selectedGender = 'ذكر';
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final List<String> _cities = const [
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

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() {
    final session = Get.find<SessionController>();
    final user = session.currentUser.value;

    if (user != null) {
      _nameCtrl.text = user.name;
      _cityCtrl.text = user.city;
      _addressCtrl.text = user.address.isNotEmpty
          ? user.address
          : (user.socialMedia['address']?.toString() ?? '');
      _ageCtrl.text = user.age > 0 ? user.age.toString() : '';
      _selectedGender = user.gender;
      _currentImageUrl = user.image;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const BackButtonWidget(),
                    Expanded(
                      child: Center(
                        child: MyText(
                          'تعديل الملف الشخصي',
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 48.w), // For alignment
                  ],
                ),
                SizedBox(height: 24.h),

                // Profile Image Section
                _buildProfileImageSection(),
                SizedBox(height: 24.h),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      _buildFieldLabel('الاسم الكامل *'),
                      _buildTextField(_nameCtrl, 'أدخل الاسم الكامل'),
                      SizedBox(height: 16.h),

                      // Gender
                      _buildFieldLabel('الجنس *'),
                      _buildGenderSelector(),
                      SizedBox(height: 16.h),

                      // Age
                      _buildFieldLabel('العمر *'),
                      _buildAgeDropdown(),
                      SizedBox(height: 16.h),

                      // City
                      _buildFieldLabel('المدينة *'),
                      _buildCityDropdown(),
                      SizedBox(height: 16.h),

                      // Address
                      _buildFieldLabel('العنوان *'),
                      _buildTextField(_addressCtrl, 'أدخل العنوان التفصيلي'),
                      SizedBox(height: 32.h),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : MyText(
                                  'حفظ التعديلات',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: Stack(
        children: [
          ClipOval(
            child: _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                ? Image.network(
                    _currentImageUrl!,
                    width: 120.w,
                    height: 120.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120.w,
                      height: 120.w,
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 60.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Container(
                    width: 120.w,
                    height: 120.w,
                    color: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 60.sp,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _isUploadingImage ? null : _changeProfileImage,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _isUploadingImage
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerRight,
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
        style: const TextStyle(fontFamily: 'Expo Arabic'),
      ),
    );
  }

  Widget _buildGenderSelector() {
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
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value!),
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
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value!),
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeDropdown() {
    final ages = [for (int i = 18; i <= 80; i++) i.toString()];
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.divider),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DropdownButtonFormField<String>(
        value: _ageCtrl.text.isNotEmpty ? _ageCtrl.text : null,
        isExpanded: true,
        menuMaxHeight: 400.h,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'اختر العمر',
          hintStyle: TextStyle(
            fontFamily: 'Expo Arabic',
            fontSize: 16.sp,
            color: AppColors.textLight,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
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
          final isSelected = _ageCtrl.text == age;
          return DropdownMenuItem<String>(
            value: age,
            child: SizedBox(
              height: 52.h,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
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
        onChanged: (value) {
          if (value != null) {
            setState(() => _ageCtrl.text = value);
          }
        },
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.divider),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DropdownButtonFormField<String>(
        value: _cityCtrl.text.isNotEmpty ? _cityCtrl.text : null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'اختر المدينة',
          hintStyle: TextStyle(fontFamily: 'Expo Arabic'),
        ),
        style: const TextStyle(
          fontFamily: 'Expo Arabic',
          color: AppColors.textPrimary,
        ),
        items: _cities.map((city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Center(child: Text(city)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _cityCtrl.text = value);
          }
        },
      ),
    );
  }

  Future<void> _changeProfileImage() async {
    try {
      setState(() => _isUploadingImage = true);

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final uploadService = UploadService();
        final result = await uploadService.uploadImage(File(image.path));

        if (result['ok'] == true) {
          final url = result['data']?['data']?['url']?.toString() ?? '';
          if (url.isNotEmpty) {
            setState(() => _currentImageUrl = url);

            // Update profile image in backend
            final userService = UserService();
            final updateResult = await userService.updateProfileImage(url);

            if (updateResult['ok'] == true) {
              // Update session
              final session = Get.find<SessionController>();
              final currentUser = session.currentUser.value;
              if (currentUser != null) {
                session.setCurrentUser(currentUser.copyWith(image: url));
              }

              await showStatusDialog(
                title: 'تم التحديث',
                message: 'تم تحديث صورتك الشخصية',
                color: AppColors.primary,
                icon: Icons.check_circle_outline,
              );
            } else {
              await showStatusDialog(
                title: 'فشل التحديث',
                message: 'تعذر تحديث الصورة في الخادم',
                color: const Color(0xFFFF3B30),
                icon: Icons.error_outline,
              );
            }
          }
        } else {
          await showStatusDialog(
            title: 'فشل الرفع',
            message: 'تعذر رفع الصورة',
            color: const Color(0xFFFF3B30),
            icon: Icons.error_outline,
          );
        }
      }
    } catch (e) {
      await showStatusDialog(
        title: 'خطأ',
        message: 'حدث خطأ أثناء رفع الصورة: $e',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;

    if (name.isEmpty || city.isEmpty || address.isEmpty || age <= 0) {
      Get.snackbar(
        'خطأ',
        'يرجى ملء جميع الحقول المطلوبة',
        backgroundColor: const Color(0xFFFF3B30),
        colorText: Colors.white,
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final userService = UserService();
      final result = await userService.updateUserInfo(
        name: name,
        phone: '', // المندوب لا يمكنه تغيير رقم الهاتف من هنا
        city: city,
        age: age,
        gender: _selectedGender,
        address: address,
        image: _currentImageUrl,
      );

      if (result['ok'] == true) {
        // Update session
        final session = Get.find<SessionController>();
        final currentUser = session.currentUser.value;
        if (currentUser != null) {
          session.setCurrentUser(
            currentUser.copyWith(
              name: name,
              city: city,
              age: age,
              gender: _selectedGender,
              address: address,
              image: _currentImageUrl ?? currentUser.image,
            ),
          );
        }

        await showStatusDialog(
          title: 'تم التحديث',
          message: 'تم تحديث معلوماتك الشخصية بنجاح',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      } else {
        await showStatusDialog(
          title: 'فشل التحديث',
          message: result['message']?.toString() ?? 'تعذر تحديث المعلومات',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      await showStatusDialog(
        title: 'خطأ',
        message: 'حدث خطأ أثناء تحديث المعلومات: $e',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
