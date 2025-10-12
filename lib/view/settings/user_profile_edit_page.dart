import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../controller/session_controller.dart';
import '../../model/user_model.dart';
import '../../service_layer/services/user_service.dart';
import '../../service_layer/services/cv_service.dart';
import '../../service_layer/services/upload_service.dart';
import '../../widget/loading_dialog.dart';
import '../../widget/status_dialog.dart';

class UserProfileEditPage extends StatefulWidget {
  const UserProfileEditPage({super.key});

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  final _nameCtrl = TextEditingController(text: '');
  final _phoneCtrl = TextEditingController(text: '');
  int _genderIndex = 1; // 0 ذكر - 1 انثى
  String _city = 'دهوك';
  String _age = '22';

  final SessionController _session = Get.find<SessionController>();
  final UserService _userService = UserService();
  final CvService _cvService = CvService();
  final UploadService _uploadService = UploadService();

  // CV state
  final TextEditingController _cvDescCtrl = TextEditingController(text: '');
  final List<String> _cvCertificates = [];
  String _cvId = '';

  final List<String> _cities = ['دهوك', 'أربيل', 'السليمانية', 'بغداد'];
  final List<String> _ages = [for (int i = 10; i <= 80; i++) i.toString()];

  @override
  void initState() {
    super.initState();
    _prefillFromSession();
    _fetchLatestUser();
    _fetchCvIfAny();
  }

  void _prefillFromSession() {
    final UserModel? user = _session.currentUser.value;
    if (user == null) return;

    _nameCtrl.text = user.name;
    _phoneCtrl.text = user.phone;
    _age = (user.age > 0 ? user.age : int.tryParse(_age) ?? 22).toString();

    final String g = user.gender.trim().toLowerCase();
    if (g == 'male' || g == 'ذكر') {
      _genderIndex = 0;
    } else if (g == 'female' || g == 'انثى' || g == 'أنثى') {
      _genderIndex = 1;
    }

    if (user.city.trim().isNotEmpty) {
      if (!_cities.contains(user.city)) {
        _cities.add(user.city);
      }
      _city = user.city;
    }
    setState(() {});
  }

  Future<void> _fetchLatestUser() async {
    await LoadingDialog.show(message: 'جاري جلب معلومات الحساب...');
    try {
      final res = await _userService.getUserInfo();
      if (res['ok'] == true) {
        _prefillFromSession();
      } else {
        await showStatusDialog(
          title: 'تعذر جلب البيانات',
          message: 'يرجى المحاولة لاحقاً',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
      }
    } finally {
      LoadingDialog.hide();
    }
  }

  Future<void> _fetchCvIfAny() async {
    try {
      final String? uid = _session.currentUser.value?.id;
      if (uid == null || uid.isEmpty) return;
      final res = await _cvService.getUserCvByUserId(uid);
      if (res['ok'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final Map<String, dynamic>? cv = data['data'] as Map<String, dynamic>?;
        if (cv != null) {
          _cvId = (cv['_id']?.toString() ?? '');
          _cvDescCtrl.text = (cv['description']?.toString() ?? '');
          final certs = (cv['certificates'] as List?)?.cast<dynamic>() ?? [];
          _cvCertificates
            ..clear()
            ..addAll(certs.map((e) => e.toString()));
          setState(() {});
        }
      }
    } catch (_) {}
  }

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

              if ((_session.currentUser.value?.userType.trim() ?? '') ==
                  'Doctor') ...[
                // CV section (doctors only)
                _label('السيرة الذاتية (CV)'),
                SizedBox(height: 8.h),
                _roundedMultilineField(
                  controller: _cvDescCtrl,
                  hint: 'اكتب السيرة الذاتية',
                ),
                SizedBox(height: 12.h),
                _label('صور الشهادات'),
                SizedBox(height: 8.h),
                _certificatesStrip(),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onSaveCv,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00A3A3)),
                          foregroundColor: const Color(0xFF00A3A3),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                        child: MyText(
                          'حفظ السيرة',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00A3A3),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onDeleteCv,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF3B30)),
                          foregroundColor: const Color(0xFFFF3B30),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                        child: MyText(
                          'حذف السيرة',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
              ],

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
                      onPressed: _onSave,
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

  Widget _roundedMultilineField({
    required TextEditingController controller,
    required String hint,
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
        maxLines: 5,
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

  Widget _certificatesStrip() {
    return SizedBox(
      height: 120.h,
      child: Row(
        children: [
          // Add button
          GestureDetector(
            onTap: _pickAndUploadCertificate,
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.add_a_photo, color: AppColors.primary),
            ),
          ),
          SizedBox(width: 12.w),
          // Images list
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final url = _cvCertificates[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.network(
                        url,
                        width: 160.w,
                        height: 120.h,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 160.w,
                          height: 120.h,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _cvCertificates.removeAt(i)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemCount: _cvCertificates.length,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadCertificate() async {
    // TODO: integrate image_picker similarly to delegate page, then call _uploadService.uploadImage(file)
  }

  Future<void> _onSaveCv() async {
    await LoadingDialog.show(message: 'جاري حفظ السيرة...');
    try {
      final desc = _cvDescCtrl.text.trim();
      Map<String, dynamic> res;
      if (_cvId.isNotEmpty) {
        res = await _cvService.updateCv(
          cvId: _cvId,
          description: desc,
          certificates: _cvCertificates,
        );
      } else {
        res = await _cvService.createCv(
          description: desc,
          certificates: _cvCertificates,
        );
        if (res['ok'] == true) {
          try {
            final created = res['data']?['data'] as Map<String, dynamic>?;
            _cvId = created?['_id']?.toString() ?? '';
          } catch (_) {}
        }
      }
      if (res['ok'] == true) {
        await showStatusDialog(
          title: 'تم الحفظ',
          message: 'تم حفظ السيرة الذاتية بنجاح',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      } else {
        await showStatusDialog(
          title: 'تعذر الحفظ',
          message: res['data']?['message']?.toString() ?? 'فشل حفظ السيرة',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
      }
    } finally {
      LoadingDialog.hide();
      setState(() {});
    }
  }

  Future<void> _onDeleteCv() async {
    if (_cvId.isEmpty) {
      await showStatusDialog(
        title: 'لا توجد سيرة',
        message: 'لا توجد سيرة لحذفها',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
      );
      return;
    }
    await LoadingDialog.show(message: 'جاري حذف السيرة...');
    try {
      final res = await _cvService.deleteCv(_cvId);
      if (res['ok'] == true) {
        _cvId = '';
        _cvDescCtrl.text = '';
        _cvCertificates.clear();
        await showStatusDialog(
          title: 'تم الحذف',
          message: 'تم حذف السيرة الذاتية',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
        );
      } else {
        await showStatusDialog(
          title: 'تعذر الحذف',
          message: res['data']?['message']?.toString() ?? 'فشل حذف السيرة',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
        );
      }
    } finally {
      LoadingDialog.hide();
      setState(() {});
    }
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

  Future<void> _onSave() async {
    await LoadingDialog.show(message: 'جاري حفظ التعديلات...');
    try {
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final gender = _genderIndex == 0 ? 'ذكر' : 'انثى';
      final age = int.tryParse(_age) ?? 0;
      final res = await _userService.updateUserInfo(
        name: name,
        city: _city,
        phone: phone,
        gender: gender,
        age: age,
      );
      if (res['ok'] == true) {
        // حدث جلسة المستخدم
        final current = _session.currentUser.value;
        final updated =
            (current ??
                    UserModel(
                      id: (current?.id ?? '').toString(),
                      name: name,
                      phone: phone,
                      gender: gender,
                      age: age,
                      city: _city,
                      userType: _session.apiUserType,
                    ))
                .copyWith(
                  name: name,
                  phone: phone,
                  gender: gender,
                  age: age,
                  city: _city,
                );
        _session.setCurrentUser(updated);
        Get.back();
        await showStatusDialog(
          title: 'تم الحفظ',
          message: 'تم تحديث معلوماتك بنجاح',
          color: AppColors.primary,
          icon: Icons.check_circle_outline,
          buttonText: 'حسناً',
        );
      } else {
        await showStatusDialog(
          title: 'تعذر الحفظ',
          message: 'يرجى المحاولة لاحقاً',
          color: const Color(0xFFFF3B30),
          icon: Icons.error_outline,
          buttonText: 'حسناً',
        );
      }
    } catch (_) {
      await showStatusDialog(
        title: 'تعذر الحفظ',
        message: 'يرجى المحاولة لاحقاً',
        color: const Color(0xFFFF3B30),
        icon: Icons.error_outline,
        buttonText: 'حسناً',
      );
    } finally {
      LoadingDialog.hide();
    }
  }
}
