import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import '../../widget/my_text.dart';
import '../../widget/back_button_widget.dart';
import 'login_page.dart';
import '../main_page.dart';
import '../../controller/auth_controller.dart';
import '../../controller/session_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../service_layer/services/upload_service.dart';
import '../../service_layer/services/specialization_service.dart';
import '../../model/specialization_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _imageUrl; // uploaded profile image url
  bool _uploadingImage = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _specializationCtrl = TextEditingController();
  int? _genderIndex; // 0 male, 1 female
  String? _age; // kept for future submission
  bool _obscurePassword = true; // لإظهار/إخفاء كلمة المرور

  // Specialization dropdown state
  List<SpecializationModel> _specializations = [];
  String? _selectedSpecializationId;
  bool _loadingSpecializations = false;
  final SpecializationService _specializationService = SpecializationService();

  // Cities dropdown
  final List<String> _allowedCities = const [
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
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    // تأخير قصير للتأكد من تهيئة الجلسة
    Future.delayed(const Duration(milliseconds: 500), () {
      _fetchSpecializationsForDoctor();
    });
  }

  Future<void> _fetchSpecializationsForDoctor() async {
    final session = Get.find<SessionController>();
    if (session.role.value != 'doctor') return;

    setState(() => _loadingSpecializations = true);
    try {
      print('🏥 Fetching specializations for doctor registration...');
      final specializations = await _specializationService
          .getSpecializationsList();
      print('🏥 Fetched ${specializations.length} specializations');
      setState(() {
        _specializations = specializations;
        _loadingSpecializations = false;
      });
    } catch (e) {
      print('🏥 Error fetching specializations: $e');
      setState(() => _loadingSpecializations = false);
    }
  }

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
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BackButtonWidget(),
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: _uploadingImage ? null : _pickAndUploadProfileImage,
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
                        child: _imageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              )
                            : Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
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
                            _uploadingImage
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
                  isPassword: true,
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
                            child: DropdownButtonFormField<String>(
                              value: _selectedCity,
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
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
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
                                'اختر المحافظة',
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                              items: _allowedCities
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
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'هذا الحقل مطلوب !'
                                  : null,
                              onChanged: (v) {
                                setState(() {
                                  _selectedCity = v;
                                  _cityCtrl.text = v ?? '';
                                });
                              },
                            ),
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
                        _specializationDropdown(),
                      ],
                    );
                  },
                ),

                SizedBox(height: 24.h),
                SizedBox(
                  height: 64.h,
                  child: ElevatedButton(
                    onPressed: () async {
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
                          // If user didn't pick an image, upload gender-based default
                          if ((_imageUrl == null || _imageUrl!.isEmpty)) {
                            final isFemale =
                                auth.gender.value == 'انثى' ||
                                auth.gender.value == 'أنثى' ||
                                auth.gender.value.toLowerCase() == 'female';
                            final role = session
                                .role
                                .value; // 'user' | 'doctor' | 'secretary' | 'delegate'
                            String defaultAsset;
                            if (role == 'doctor') {
                              defaultAsset = isFemale
                                  ? 'assets/icons/home/doctor_geairl.jpg'
                                  : 'assets/icons/home/doctor_boy.jpg';
                            } else {
                              defaultAsset = isFemale
                                  ? 'assets/icons/home/person_woman.jpg'
                                  : 'assets/icons/home/person_man.png';
                            }
                            final uploaded = await _uploadAssetImage(
                              defaultAsset,
                            );
                            if (uploaded != null && uploaded.isNotEmpty) {
                              _imageUrl = uploaded;
                            }
                          }
                          if (_imageUrl != null && _imageUrl!.isNotEmpty) {
                            auth.imageUrl.value = _imageUrl!;
                          }
                          if (session.role.value == 'doctor') {
                            // إرسال ID الاختصاص بدلاً من النص
                            if (_selectedSpecializationId != null) {
                              auth.specializationId.value =
                                  _selectedSpecializationId!;
                            }
                          }
                          await auth.registerUser();
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
      obscureText: isPassword ? _obscurePassword : false,
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
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                  size: 24.r,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
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

  Widget _specializationDropdown() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSpecializationId,
            decoration: InputDecoration(
              hintText: _loadingSpecializations
                  ? 'جاري التحميل...'
                  : _specializations.isEmpty
                  ? 'لا توجد اختصاصات'
                  : 'اختر الاختصاص',
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
            isExpanded: true,
            items: _specializations.map((spec) {
              return DropdownMenuItem<String>(
                value: spec.id,
                child: Text(
                  spec.name,
                  style: TextStyle(fontSize: 18.sp, fontFamily: 'Expo Arabic'),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
            onChanged: _loadingSpecializations || _specializations.isEmpty
                ? null
                : (value) {
                    setState(() {
                      _selectedSpecializationId = value;
                    });
                  },
            validator: (value) {
              final session = Get.find<SessionController>();
              if (session.role.value == 'doctor' &&
                  (value == null || value.isEmpty)) {
                return 'هذا الحقل مطلوب للطبيب!';
              }
              return null;
            },
          ),
        ),
        if (_specializations.isEmpty && !_loadingSpecializations) ...[
          SizedBox(height: 8.h),
          InkWell(
            onTap: _fetchSpecializationsForDoctor,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: AppColors.primary, size: 16.sp),
                  SizedBox(width: 4.w),
                  MyText(
                    'إعادة المحاولة',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: DropdownButtonFormField<String>(
            value: null,
            items: ages
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.textLight, width: 1),
              ),
            ),
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
      final upload = UploadService();
      final res = await upload.uploadImage(File(picked.path));
      if (res['ok'] == true) {
        final url = (res['data']?['data']?['url']?.toString() ?? '');
        if (url.isNotEmpty) {
          setState(() => _imageUrl = url);
        }
      }
    } catch (_) {
    } finally {
      setState(() => _uploadingImage = false);
    }
  }

  Future<String?> _uploadAssetImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final fileName = assetPath.split('/').last;
      final file = File('${Directory.systemTemp.path}/$fileName');
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      final upload = UploadService();
      final res = await upload.uploadImage(file);
      if (res['ok'] == true) {
        final url = (res['data']?['data']?['url']?.toString() ?? '');
        if (url.isNotEmpty) return url;
      }
    } catch (_) {}
    return null;
  }
}
