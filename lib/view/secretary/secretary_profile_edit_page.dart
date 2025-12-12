import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/session_controller.dart';
import '../../service_layer/services/user_service.dart';
import '../../service_layer/services/upload_service.dart';
import '../../widget/status_dialog.dart';
import '../../widget/back_button_widget.dart';

class SecretaryProfileEditPage extends StatefulWidget {
  const SecretaryProfileEditPage({super.key});

  @override
  State<SecretaryProfileEditPage> createState() =>
      _SecretaryProfileEditPageState();
}

class _SecretaryProfileEditPageState extends State<SecretaryProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String _selectedGender = 'ذكر';
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;

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
      _addressCtrl.text = user.socialMedia['address'] ?? '';
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.w, left: 16.w),
              child: const BackButtonWidget(),
            ),
          ],
          title: MyText(
            'تعديل الملف الشخصي',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                SizedBox(height: 12.h),

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
                      _buildTextField(_ageCtrl, '25', TextInputType.number),
                      SizedBox(height: 16.h),

                      // City
                      _buildFieldLabel('المدينة *'),
                      _buildTextField(_cityCtrl, 'أدخل المدينة'),
                      SizedBox(height: 16.h),

                      // Address
                      _buildFieldLabel('العنوان *'),
                      _buildTextField(_addressCtrl, 'أدخل العنوان التفصيلي'),
                      SizedBox(height: 32.h),

                      // Change Password Button
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: OutlinedButton.icon(
                          onPressed: _showChangePasswordDialog,
                          icon: Icon(Icons.lock, size: 20.sp),
                          label: MyText(
                            'تغيير كلمة المرور',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange),
                            foregroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

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
      final socialMedia = <String, String>{'address': address};

      final result = await userService.updateUserInfo(
        name: name,
        phone: '', // السكرتير لا يمكنه تغيير رقم الهاتف
        city: city,
        age: age,
        gender: _selectedGender,
        socialMedia: socialMedia,
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
              socialMedia: socialMedia,
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

  void _showChangePasswordDialog() {
    final oldPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    bool obscureOldPassword = true;
    bool obscureNewPassword = true;
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
                  SizedBox(height: 20.h),

                  // كلمة المرور الحالية
                  _buildFieldLabel('كلمة المرور الحالية *'),
                  _buildPasswordField(oldPasswordCtrl, obscureOldPassword, (
                    value,
                  ) {
                    setState(() => obscureOldPassword = value);
                  }),
                  SizedBox(height: 16.h),

                  // كلمة المرور الجديدة
                  _buildFieldLabel('كلمة المرور الجديدة *'),
                  _buildPasswordField(newPasswordCtrl, obscureNewPassword, (
                    value,
                  ) {
                    setState(() => obscureNewPassword = value);
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
                            final oldPassword = oldPasswordCtrl.text.trim();
                            final newPassword = newPasswordCtrl.text.trim();
                            final confirmPassword = confirmPasswordCtrl.text
                                .trim();

                            if (oldPassword.isEmpty ||
                                newPassword.isEmpty ||
                                confirmPassword.isEmpty) {
                              Get.snackbar(
                                'خطأ',
                                'يرجى ملء جميع الحقول',
                                backgroundColor: const Color(0xFFFF3B30),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (newPassword != confirmPassword) {
                              Get.snackbar(
                                'خطأ',
                                'كلمة المرور غير متطابقة',
                                backgroundColor: const Color(0xFFFF3B30),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (newPassword.length < 6) {
                              Get.snackbar(
                                'خطأ',
                                'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                                backgroundColor: const Color(0xFFFF3B30),
                                colorText: Colors.white,
                              );
                              return;
                            }

                            try {
                              final userService = UserService();
                              final result = await userService.changePassword(
                                oldPassword: oldPassword,
                                newPassword: newPassword,
                              );

                              if (result['ok'] == true) {
                                Get.back();
                                await showStatusDialog(
                                  title: 'تم التحديث',
                                  message: 'تم تغيير كلمة المرور بنجاح',
                                  color: AppColors.primary,
                                  icon: Icons.check_circle_outline,
                                );
                              } else {
                                await showStatusDialog(
                                  title: 'فشل التحديث',
                                  message:
                                      result['message']?.toString() ??
                                      'تعذر تغيير كلمة المرور',
                                  color: const Color(0xFFFF3B30),
                                  icon: Icons.error_outline,
                                );
                              }
                            } catch (e) {
                              await showStatusDialog(
                                title: 'خطأ',
                                message: 'حدث خطأ أثناء تغيير كلمة المرور: $e',
                                color: const Color(0xFFFF3B30),
                                icon: Icons.error_outline,
                              );
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
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
}
