import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import 'delegate_success_page.dart';
import '../../service_layer/services/auth_service.dart';
import '../../service_layer/services/device_token_service.dart';
import '../../widget/loading_dialog.dart';
import '../../widget/status_dialog.dart';
import '../../service_layer/services/upload_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DelegateRegisterPage extends StatefulWidget {
  const DelegateRegisterPage({super.key});

  @override
  State<DelegateRegisterPage> createState() => _DelegateRegisterPageState();
}

class _DelegateRegisterPageState extends State<DelegateRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _certificateCtrl = TextEditingController();
  final TextEditingController _idFrontCtrl = TextEditingController();
  final TextEditingController _idBackCtrl = TextEditingController();
  int? _age;
  final List<String> _attachments = [];
  final AuthService _auth = AuthService();
  final UploadService _upload = UploadService();
  final ImagePicker _picker = ImagePicker();
  String _idFrontUrl = '';
  String _idBackUrl = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _certificateCtrl.dispose();
    _idFrontCtrl.dispose();
    _idBackCtrl.dispose();
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
                  controller: _passwordCtrl,
                  hint: 'ادخل كلمة المرور',
                  keyboardType: TextInputType.visiblePassword,
                  validator: (v) => (v == null || v.trim().length < 6)
                      ? 'كلمة المرور 6 أحرف على الأقل'
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
                  controller: _certificateCtrl,
                  hint: 'اكتب تحصيلك العلمي',
                  validator: (_) => null,
                  onChanged: (_) {},
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
                if (_attachments.length < 2) _uploadRow(),

                SizedBox(height: 16.h),
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
                    onPressed: _submit,
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
    return Row(
      children: [
        Expanded(
          child: _ageDropdownField((v) {
            setState(() {
              _age = int.tryParse((v ?? '').trim());
            });
          }),
        ),
      ],
    );
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_age == null) {
      await showStatusDialog(
        title: 'العمر مطلوب',
        message: 'يرجى اختيار العمر',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
      return;
    }
    await LoadingDialog.show(message: 'جاري إنشاء حساب المندوب...');
    try {
      final deviceToken = await DeviceTokenService.getOrCreateToken();
      final res = await _auth.registerDelegate(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        age: _age!,
        certificate: _certificateCtrl.text.trim(),
        idFrontImage: (_idFrontCtrl.text.trim().isNotEmpty
            ? _idFrontCtrl.text.trim()
            : _idFrontUrl),
        idBackImage: (_idBackCtrl.text.trim().isNotEmpty
            ? _idBackCtrl.text.trim()
            : _idBackUrl),
        deviceToken: deviceToken,
      );
      if (res['ok'] == true) {
        LoadingDialog.hide();
        Get.offAll(() => const DelegateSuccessPage());
      } else {
        LoadingDialog.hide();
        await showStatusDialog(
          title: 'فشل إنشاء الحساب',
          message:
              res['error']?.toString() ?? 'تحقق من البيانات وحاول مرة أخرى',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
          buttonText: 'حسناً',
        );
      }
    } catch (_) {
      LoadingDialog.hide();
      await showStatusDialog(
        title: 'خطأ غير متوقع',
        message: 'حدث خطأ أثناء إنشاء الحساب',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _pickAndUpload({required bool isFront}) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      await LoadingDialog.show(message: 'جاري رفع الصورة...');
      final res = await _upload.uploadImage(File(picked.path));
      LoadingDialog.hide();
      if (res['ok'] == true) {
        final data = res['data'] as Map<String, dynamic>?;
        final url = data?['data']?['url']?.toString() ?? '';
        if (url.isNotEmpty) {
          setState(() {
            if (isFront) {
              _idFrontUrl = url;
              _idFrontCtrl.text = url;
            } else {
              _idBackUrl = url;
              _idBackCtrl.text = url;
            }
            final uri = Uri.tryParse(url);
            final fileName = (uri != null && uri.pathSegments.isNotEmpty)
                ? uri.pathSegments.last
                : 'image.jpg';
            if (!_attachments.contains(fileName)) {
              _attachments.add(fileName);
            }
          });
          await showStatusDialog(
            title: 'تم الرفع',
            message: (res['message']?.toString().isNotEmpty == true)
                ? res['message'] as String
                : 'تم رفع الصورة بنجاح',
            color: AppColors.primary,
            icon: Icons.check_circle_outline,
          );
        } else {
          await showStatusDialog(
            title: 'فشل الرفع',
            message: 'تعذر الحصول على الرابط من الخادم',
            color: const Color(0xFFFF3B30),
            icon: Icons.error_outline,
          );
        }
      } else {
        await showStatusDialog(
          title: 'فشل الرفع',
          message: (res['message']?.toString().isNotEmpty == true)
              ? res['message'] as String
              : 'يرجى المحاولة لاحقاً',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
      }
    } catch (_) {
      LoadingDialog.hide();
      await showStatusDialog(
        title: 'فشل الرفع',
        message: 'حدث خطأ أثناء رفع الصورة',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
    }
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
        final bool isFront = label.contains('الأمامي');
        await _pickAndUpload(isFront: isFront);
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
            onTap: () => setState(() {
              final removed = _attachments.removeAt(index);
              final frontName = Uri.tryParse(_idFrontUrl)?.pathSegments.last;
              final backName = Uri.tryParse(_idBackUrl)?.pathSegments.last;
              if (removed == frontName) _idFrontUrl = '';
              if (removed == backName) _idBackUrl = '';
            }),
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
