import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hagz/widget/my_text.dart';
import '../../../controller/hospital_details_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../widget/status_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../utils/app_colors.dart';
import '../../../widget/animated_pressable.dart';
import '../../../widget/specialization_text.dart';
import '../doctors/doctor_profile_page.dart';
import '../../../bindings/doctor_profile_binding.dart';
import '../../../widget/back_button_widget.dart';

class HospitalDetailsPage extends StatelessWidget {
  const HospitalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HospitalDetailsController>();

    // تحميل الأطباء عند فتح الصفحة
    final args = Get.arguments;
    final String? id = (args is Map && args['id'] != null)
        ? args['id'].toString()
        : null;
    if (id != null &&
        controller.doctors.isEmpty &&
        !controller.isLoadingDoctors.value) {
      controller.loadDoctors(id);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Main content section
              Obx(() {
                if (controller.isLoading.value ||
                    controller.hospital.value == null) {
                  // Skeleton layout mimicking the card structure
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Skeletonizer(
                      enabled: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 120.w,
                                      height: 120.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    MyText(' ', fontSize: 18.sp),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 20.r),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: MyText(' ', fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.phone, size: 18.r),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.phone, size: 18.r),
                                            SizedBox(width: 5.w),
                                            MyText(' ', fontSize: 14.sp),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20.w),
                          Container(
                            width: 70.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            height: 220.h,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _buildMainContent(controller);
              }),

              SizedBox(height: 20.h),

              // Ride request section
              _buildRideRequestSection(controller),

              SizedBox(height: 30.h),

              // Doctors grid section
              _buildDoctorsSection(),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final controller = Get.find<HospitalDetailsController>();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Obx(() {
        final hospital = controller.hospital.value;
        final isLoading = controller.isLoading.value;

        if (isLoading || hospital == null) {
          // عرض Skeleton أثناء التحميل
          return Skeletonizer(
            enabled: true,
            child: MyText(
              'تفاصيل المستشفى',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
          );
        }

        final type = hospital.type;
        final title = type == 'مجمع طبي'
            ? 'تفاصيل المجمع الطبي'
            : 'تفاصيل المستشفى';

        return MyText(
          title,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        );
      }),
      centerTitle: true,
      leading: const SizedBox.shrink(),
      actions: [
        // Back button on the left (in RTL, we use Directionality to force left position)
        Padding(
          padding: EdgeInsets.only(right: 16.w, left: 16.w),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: const BackButtonWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(HospitalDetailsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital info section
          Expanded(child: _buildHospitalInfoCard(controller)),

          SizedBox(width: 20.w),
          // Social media icons column
          _buildSocialMediaColumn(),
        ],
      ),
    );
  }

  Widget _buildSocialMediaColumn() {
    final controller = Get.find<HospitalDetailsController>();
    return Container(
      width: 70.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final url = controller.hospital.value?.instagram ?? '';
                if (url.isEmpty) {
                  await showStatusDialog(
                    title: 'لا يوجد رابط',
                    message: 'لا يتوفر رابط إنستغرام',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                  return;
                }
                try {
                  final ok = await launchUrlString(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!ok) {
                    await showStatusDialog(
                      title: 'لا يمكن فتح الرابط',
                      message: 'تحقق من الرابط أو التطبيق المثبت',
                      color: const Color(0xFFFF3B30),
                      icon: Icons.error_outline,
                    );
                  }
                } catch (_) {
                  await showStatusDialog(
                    title: 'خطأ في فتح الرابط',
                    message: 'حاول لاحقاً',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                }
              },
              child: _buildSocialIconItem(
                'assets/icons/home/instgram.png',
                const Color(0xFFE4405F),
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () async {
                final phone = controller.hospital.value?.phone ?? '';
                if (phone.isEmpty) {
                  await showStatusDialog(
                    title: 'لا يوجد رقم',
                    message: 'لا يتوفر رقم هاتف',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                  return;
                }
                final uri = 'tel:$phone';
                try {
                  final ok = await launchUrlString(uri);
                  if (!ok) {
                    await showStatusDialog(
                      title: 'تعذر إجراء الاتصال',
                      message: 'تحقق من إذن الاتصال أو صحة الرقم',
                      color: const Color(0xFFFF3B30),
                      icon: Icons.error_outline,
                    );
                  }
                } catch (_) {
                  await showStatusDialog(
                    title: 'تعذر إجراء الاتصال',
                    message: 'حاول لاحقاً',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                }
              },
              child: _buildSocialIconItem(
                'assets/icons/home/phone.png',
                const Color(0xFFFF3040),
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () async {
                final wa = controller.hospital.value?.whatsapp ?? '';
                if (wa.isEmpty) {
                  await showStatusDialog(
                    title: 'لا يوجد رابط',
                    message: 'لا يتوفر رابط واتساب',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                  return;
                }
                try {
                  final ok = await launchUrlString(
                    wa,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!ok) {
                    await showStatusDialog(
                      title: 'لا يمكن فتح واتساب',
                      message: 'تأكد من تثبيت التطبيق أو صحة الرابط',
                      color: const Color(0xFFFF3B30),
                      icon: Icons.error_outline,
                    );
                  }
                } catch (_) {
                  await showStatusDialog(
                    title: 'لا يمكن فتح واتساب',
                    message: 'حاول لاحقاً',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                }
              },
              child: _buildSocialIconItem(
                'assets/icons/home/watsapp.png',
                const Color(0xFF25D366),
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () async {
                final url = controller.hospital.value?.facebook ?? '';
                if (url.isEmpty) {
                  await showStatusDialog(
                    title: 'لا يوجد رابط',
                    message: 'لا يتوفر رابط فيسبوك',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                  return;
                }
                try {
                  final ok = await launchUrlString(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!ok) {
                    await showStatusDialog(
                      title: 'لا يمكن فتح الرابط',
                      message: 'تحقق من الرابط أو التطبيق المثبت',
                      color: const Color(0xFFFF3B30),
                      icon: Icons.error_outline,
                    );
                  }
                } catch (_) {
                  await showStatusDialog(
                    title: 'خطأ في فتح الرابط',
                    message: 'حاول لاحقاً',
                    color: const Color(0xFFFF3B30),
                    icon: Icons.error_outline,
                  );
                }
              },
              child: _buildSocialIconItem(
                'assets/icons/home/facebook.png',
                const Color(0xFF1877F2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIconItem(String imagePath, Color color) {
    return Container(
      width: 45.w,
      height: 45.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Image.asset(
          imagePath,
          width: 25,
          height: 25,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icons
            IconData fallbackIcon = Icons.link;
            if (imagePath.contains('instgram')) {
              fallbackIcon = Icons.camera_alt;
            } else if (imagePath.contains('watsapp')) {
              fallbackIcon = Icons.phone;
            } else if (imagePath.contains('facebook')) {
              fallbackIcon = Icons.facebook;
            } else if (imagePath.contains('phone')) {
              fallbackIcon = Icons.phone;
            }
            return Icon(fallbackIcon, color: color, size: 25);
          },
        ),
      ),
    );
  }

  Widget _buildHospitalInfoCard(HospitalDetailsController controller) {
    final h = controller.hospital.value!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Hospital logo
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: h.image.isNotEmpty
                    ? Image.network(
                        h.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Padding(
                            padding: EdgeInsets.all(15.w),
                            child: Image.asset(
                              'assets/icons/home/hospital.png',
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      )
                    : Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Image.asset(
                          'assets/icons/home/hospital.png',
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 20.h),

            // Hospital name
            MyText(
              h.name,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 15.h),

            // Address
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: const Color(0xFF7FC8D6),
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: MyText(
                    h.address,
                    fontSize: 12.sp,
                    color: const Color(0xFF7FC8D6),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Phone number - copyable
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.phone, color: const Color(0xFF7FC8D6), size: 18.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: SelectableText(
                    h.phone.isEmpty ? '—' : h.phone,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7FC8D6),
                      fontFamily: 'Expo Arabic',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideRequestSection(HospitalDetailsController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Expanded(
                child: MyText(
                  'طلب سيارة أجرة',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  textAlign: TextAlign.right,
                ),
              ),
              Obx(
                () => AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: controller.isRideExpanded.value ? 0.5 : 0,
                  child: GestureDetector(
                    onTap: controller.toggleRideExpansion,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black54,
                      size: 24.r,
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

  Widget _buildDoctorsSection() {
    final controller = Get.find<HospitalDetailsController>();

    return Obx(() {
      final doctors = controller.doctors;
      final isLoading = controller.isLoadingDoctors.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            // Section header
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: const Color(0xFF7FC8D6),
                  size: 24.r,
                ),
                SizedBox(width: 10.w),
                MyText(
                  'الأطباء',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Doctors grid
            if (isLoading)
              Container(
                padding: EdgeInsets.all(20.w),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (doctors.isEmpty)
              Container(
                padding: EdgeInsets.all(20.w),
                child: MyText(
                  'لا توجد بيانات الأطباء حالياً',
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  textAlign: TextAlign.center,
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.75,
                ),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return _buildDoctorCardFromData(doctor);
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDoctorCardFromData(Map<String, dynamic> doctor) {
    final String id = (doctor['id'] ?? doctor['_id'] ?? '').toString();
    final String name = (doctor['name'] ?? '').toString();

    // Handle specialization: can be ID (String) or Object (Map)
    String specialization = '';
    final spec = doctor['specialization'];
    if (spec != null) {
      if (spec is String) {
        specialization = spec;
      } else if (spec is Map) {
        specialization = (spec['_id'] ?? spec['id'] ?? '').toString();
      }
    }

    final String image = (doctor['image'] ?? '').toString();
    return AnimatedPressable(
      onTap: () {
        Get.to(
          () => DoctorProfilePage(
            doctorId: id,
            doctorName: name,
            specializationId: specialization.isEmpty ? '—' : specialization,
          ),
          binding: DoctorProfileBinding(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Hero(
                      tag: 'doctor-image-$id',
                      child: image.isNotEmpty
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/icons/home/doctor.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/icons/home/doctor.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Hero(
              tag: 'doctor-name-$id',
              flightShuttleBuilder: (ctx, anim, dir, from, to) => to.widget,
              child: MyText(
                name,
                fontSize: 15.sp,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 6.h),
            SpecializationText(
              specializationId: specialization.isEmpty ? null : specialization,
              fontSize: 12.45.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              defaultText: '—',
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
