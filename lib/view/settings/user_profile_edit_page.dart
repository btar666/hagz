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
import '../../service_layer/services/specialization_service.dart';
import '../../model/specialization_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widget/loading_dialog.dart';
import '../../widget/status_dialog.dart';

class UserProfileEditPage extends StatefulWidget {
  const UserProfileEditPage({super.key});

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  String? _imageUrl; // profile image url
  bool _uploadingImage = false;
  final _nameCtrl = TextEditingController(text: '');
  final _phoneCtrl = TextEditingController(text: '');
  int _genderIndex = 1; // 0 ذكر - 1 انثى
  String _city = 'دهوك';
  String _age = '22';

  final SessionController _session = Get.find<SessionController>();
  final UserService _userService = UserService();
  final CvService _cvService = CvService();
  final UploadService _uploadService = UploadService();
  final SpecializationService _specializationService = SpecializationService();

  // CV state
  final TextEditingController _cvDescCtrl = TextEditingController(text: '');
  final List<String> _cvCertificates = [];
  String _cvId = '';

  // Specialization state
  List<SpecializationModel> _specializations = [];
  String? _selectedSpecializationId;
  bool _loadingSpecializations = false;

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
  final List<String> _ages = [for (int i = 10; i <= 80; i++) i.toString()];

  @override
  void initState() {
    super.initState();
    _prefillFromSession();
    _fetchLatestUser();
    _fetchCvIfAny();
    _fetchSpecializations();
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
    } else if (g == 'female' || g == 'أنثى') {
      _genderIndex = 1;
    }

    _imageUrl = user.image;

    if (user.city.trim().isNotEmpty) {
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

  Future<void> _fetchSpecializations() async {
    if (_session.currentUser.value?.userType != 'Doctor') return;

    setState(() => _loadingSpecializations = true);
    try {
      final specializations = await _specializationService
          .getSpecializationsList();
      setState(() {
        _specializations = specializations;
        _loadingSpecializations = false;
      });
    } catch (_) {
      setState(() => _loadingSpecializations = false);
    }
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
              // Profile image picker
              Center(
                child: GestureDetector(
                  onTap: _uploadingImage ? null : _pickAndUploadProfileImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD9D9D9),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (_imageUrl == null || _imageUrl!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 6.h,
                        right: 6.w,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _uploadingImage
                                ? Icons.hourglass_top
                                : Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
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
                  Expanded(child: _genderButton('أنثى', 1)),
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
                      hintText: 'اختر العمر',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              if ((_session.currentUser.value?.userType.trim() ?? '') ==
                  'Doctor') ...[
                // Specialization dropdown (doctors only)
                _label('الاختصاص'),
                SizedBox(height: 8.h),
                _specializationDropdown(),
                SizedBox(height: 16.h),

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

  Widget _specializationDropdown() {
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
      child: DropdownButtonFormField<String>(
        value: _selectedSpecializationId,
        decoration: InputDecoration(
          hintText: _loadingSpecializations
              ? 'جاري التحميل...'
              : 'اختر الاختصاص',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 16.h,
          ),
        ),
        isExpanded: true,
        items: _specializations.map((spec) {
          return DropdownMenuItem<String>(
            value: spec.id,
            child: Text(
              spec.name,
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.right,
            ),
          );
        }).toList(),
        onChanged: _loadingSpecializations
            ? null
            : (value) {
                setState(() {
                  _selectedSpecializationId = value;
                });
              },
      ),
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
    String? hintText,
  }) {
    final isAgeDropdown =
        items.length > 50; // Assume age dropdown has many items
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
        menuMaxHeight: isAgeDropdown ? 400.h : null,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Expo Arabic',
            fontSize: 16.sp,
            color: AppColors.textLight,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
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
        selectedItemBuilder: isAgeDropdown
            ? (BuildContext context) {
                return items.map((String item) {
                  return Align(
                    alignment: Alignment.center,
                    child: MyText(
                      item,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  );
                }).toList();
              }
            : null,
        items: items.map((String item) {
          final isSelected = value == item;
          return DropdownMenuItem<String>(
            value: item,
            child: isAgeDropdown
                ? SizedBox(
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
                              item,
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
                  )
                : MyText(
                    item,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.center,
                  ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _onSave() async {
    await LoadingDialog.show(message: 'جاري حفظ التعديلات...');
    try {
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final gender = _genderIndex == 0 ? 'ذكر' : 'أنثى';
      final age = int.tryParse(_age) ?? 0;
      final res = await _userService.updateUserInfo(
        name: name,
        city: _city,
        phone: phone,
        gender: gender,
        age: age,
        specializationId: (_session.currentUser.value?.userType == 'Doctor')
            ? _selectedSpecializationId
            : null,
        image: _imageUrl,
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
                  image: _imageUrl,
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

  Future<void> _pickAndUploadProfileImage() async {
    try {
      setState(() => _uploadingImage = true);
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) {
        setState(() => _uploadingImage = false);
        return;
      }
      final res = await _uploadService.uploadImage(File(picked.path));
      if (res['ok'] == true) {
        final url = (res['data']?['data']?['url']?.toString() ?? '');
        if (url.isNotEmpty) setState(() => _imageUrl = url);
      }
    } catch (_) {
    } finally {
      setState(() => _uploadingImage = false);
    }
  }
}
