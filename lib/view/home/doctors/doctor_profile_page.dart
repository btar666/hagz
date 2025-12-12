import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hagz/utils/app_colors.dart';
import 'package:hagz/widget/my_text.dart';
import '../../../controller/doctor_profile_controller.dart';
import '../../../controller/session_controller.dart';
import '../../../service_layer/services/opinion_service.dart';
import '../../../widget/loading_dialog.dart';
import '../../../widget/status_dialog.dart';
import '../../appointments/patient_registration_page.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../chat/chat_details_page.dart';
import '../../../bindings/chats_binding.dart';
import '../../../utils/constants.dart';
import '../../../widget/specialization_text.dart';
import '../../../widget/back_button_widget.dart';
import '../../../service_layer/services/user_service.dart';

class DoctorProfilePage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specializationId;

  const DoctorProfilePage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specializationId,
  });

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final RxBool isFollowing = false.obs;
  final RxInt followersCount = 0.obs;
  final RxBool isLoadingFollow = false.obs;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    final controller = Get.put(DoctorProfileController());
    // Load opinions and read-only CV for this doctor
    controller.loadOpinionsForTarget(widget.doctorId);
    controller.loadCvForUserId(widget.doctorId);
    controller.loadDoctorPricing(widget.doctorId);
    controller.loadDoctorSocial(widget.doctorId);
    controller.loadRatingsCount(widget.doctorId);

    // Load followers count and check follow status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFollowersCount();
      _checkFollowStatus();
    });

    // Load calendar for this doctor
    // Check if we need to load (different doctor or first time)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentDoctorIdForCalendar.value != widget.doctorId) {
        print(
          '📅 Loading calendar for doctor: ${widget.doctorId} (${widget.doctorName})',
        );
        // Reset calendar data for new doctor
        controller.dayStatuses.clear();
        controller.selectedMonth.value = DateTime.now();
        // Load calendar for this doctor
        controller.loadDoctorCalendar(doctorId: widget.doctorId);
      } else {
        print('📅 Calendar already loaded for doctor: ${widget.doctorId}');
      }
    });
  }

  Future<void> _loadFollowersCount() async {
    try {
      final res = await _userService.getFollowersCount(widget.doctorId);
      print('📊 FOLLOWERS COUNT RESPONSE: $res');

      if (res['ok'] == true && res['data'] != null) {
        final data = res['data'];
        int count = 0;

        // Handle different response structures
        if (data is Map<String, dynamic>) {
          // Try data.data.followersCount first (based on API response structure)
          if (data['data'] != null && data['data'] is Map) {
            final innerData = data['data'] as Map<String, dynamic>;
            if (innerData['followersCount'] != null) {
              final countValue = innerData['followersCount'];
              if (countValue is int) {
                count = countValue;
              } else if (countValue is String) {
                count = int.tryParse(countValue) ?? 0;
              } else if (countValue is num) {
                count = countValue.toInt();
              }
            } else if (innerData['count'] != null) {
              final countValue = innerData['count'];
              if (countValue is int) {
                count = countValue;
              } else if (countValue is String) {
                count = int.tryParse(countValue) ?? 0;
              } else if (countValue is num) {
                count = countValue.toInt();
              }
            }
          } else if (data['followersCount'] != null) {
            final countValue = data['followersCount'];
            if (countValue is int) {
              count = countValue;
            } else if (countValue is String) {
              count = int.tryParse(countValue) ?? 0;
            } else if (countValue is num) {
              count = countValue.toInt();
            }
          } else if (data['count'] != null) {
            final countValue = data['count'];
            if (countValue is int) {
              count = countValue;
            } else if (countValue is String) {
              count = int.tryParse(countValue) ?? 0;
            } else if (countValue is num) {
              count = countValue.toInt();
            }
          }
        } else if (data is int) {
          count = data;
        } else if (data is String) {
          count = int.tryParse(data) ?? 0;
        } else if (data is num) {
          count = data.toInt();
        }

        followersCount.value = count;
        print('📊 Parsed followers count: $count');
      } else {
        print('⚠️ Followers count response not OK or data is null');
        followersCount.value = 0;
      }
    } catch (e) {
      print('❌ Error loading followers count: $e');
      followersCount.value = 0;
    }
  }

  Future<void> _checkFollowStatus() async {
    final session = Get.find<SessionController>();
    final currentUserId = session.currentUser.value?.id;
    if (currentUserId == null || currentUserId.isEmpty) {
      isFollowing.value = false;
      return;
    }

    try {
      final isFollowingStatus = await _userService.checkFollowStatus(
        widget.doctorId,
      );
      isFollowing.value = isFollowingStatus;
      print('✅ Follow status checked: $isFollowingStatus');
    } catch (e) {
      print('❌ Error checking follow status: $e');
      isFollowing.value = false;
    }
  }

  Future<void> _toggleFollow() async {
    final session = Get.find<SessionController>();
    if (!session.isAuthenticated) {
      Get.snackbar(
        'غير مسجل دخول',
        'يرجى تسجيل الدخول أولاً',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoadingFollow.value = true;
    try {
      Map<String, dynamic> res;
      if (isFollowing.value) {
        res = await _userService.unfollowUser(widget.doctorId);
      } else {
        res = await _userService.followUser(widget.doctorId);
      }

      if (res['ok'] == true) {
        isFollowing.value = !isFollowing.value;
        // Update followers count
        await _loadFollowersCount();
        Get.snackbar(
          isFollowing.value ? 'تمت المتابعة' : 'تم إلغاء المتابعة',
          '',
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'خطأ',
          res['data']?['message']?.toString() ?? 'حدث خطأ',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingFollow.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorProfileController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FEFF),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Doctor profile container (image, name, specialty, social media)
                      _buildDoctorProfileContainer(controller),

                      SizedBox(height: 30.h),

                      // Expandable sections
                      _buildExpandableSections(controller),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
              // Book appointment button - fixed at bottom
              _buildBookButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final session = Get.find<SessionController>();
    final isOwnProfile = session.currentUser.value?.id == widget.doctorId;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 80.w,
      leading: !isOwnProfile
          ? Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Get.to(
                    () => ChatDetailsPage(
                      title: widget.doctorName,
                      receiverId: widget.doctorId,
                    ),
                    binding: ChatsBinding(),
                  ),
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/home/Message Icon.png',
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 20,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
      title: MyText(
        'بروفايل الطبيب',
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        textAlign: TextAlign.center,
      ),
      centerTitle: true,
      actions: [
        // Back button on the right in RTL
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: const BackButtonWidget(),
        ),
      ],
    );
  }

  Widget _buildDoctorProfileContainer(DoctorProfileController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Doctor image
            _buildDoctorImage(controller),

            SizedBox(height: 20.h),

            // Doctor name and specialty
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildDoctorInfo(),
            ),

            SizedBox(height: 20.h),

            // Social media icons
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: _buildSocialMediaIcons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorImage(DoctorProfileController controller) {
    return Container(
      width: double.infinity,
      height: 400.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
          bottom: Radius.circular(20.r),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
          bottom: Radius.circular(20.r),
        ),
        child: Stack(
          children: [
            // Doctor image
            Obx(() {
              final img = controller.doctorImageUrl.value.trim();
              final loading = controller.isLoadingSocial.value;
              return Hero(
                tag: 'doctor-image-${widget.doctorId}',
                child: loading
                    ? Skeletonizer(
                        enabled: true,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[300],
                        ),
                      )
                    : (img.isNotEmpty
                          ? Image.network(
                              img,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Image.asset(
                                'assets/icons/home/doctor.png',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/icons/home/doctor.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )),
              );
            }),

            // Rating badge
            Positioned(
              bottom: 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => MyText(
                        '${controller.ratingsCount.value} تقييم',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                  ],
                ),
              ),
            ),
            // Followers count badge
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        '${followersCount.value} متابع',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 4.w),
                      const Icon(
                        Icons.people,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    final session = Get.find<SessionController>();
    final currentUser = session.currentUser.value;
    final isOwnProfile = currentUser?.id == widget.doctorId;
    // يظهر زر المتابعة لأي مستخدم (User أو Doctor) طالما أنه ليس هو نفسه الطبيب المعروض
    final showFollowButton = !isOwnProfile && session.isAuthenticated;

    return Column(
      children: [
        // Name (centered)
        Center(
          child: Hero(
            tag: 'doctor-name-${widget.doctorId}',
            flightShuttleBuilder: (ctx, anim, dir, from, to) => to.widget,
            child: MyText(
              widget.doctorName,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SpecializationText(
          specializationId: widget.specializationId,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
        // Follow/Unfollow button
        if (showFollowButton) ...[
          SizedBox(height: 16.h),
          Obx(
            () => GestureDetector(
              onTap: isLoadingFollow.value ? null : _toggleFollow,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isFollowing.value
                      ? Colors.grey[300]
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: isLoadingFollow.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFollowing.value
                                ? Icons.person_remove
                                : Icons.person_add,
                            color: isFollowing.value
                                ? Colors.black87
                                : Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8.w),
                          MyText(
                            isFollowing.value ? 'إلغاء متابعة' : 'متابعة',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isFollowing.value
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialMediaIcons() {
    final controller = Get.find<DoctorProfileController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(() {
            final phone = controller.doctorPhone.value;
            return _buildSocialIconImage(
              'assets/icons/home/phone.png',
              const Color.fromARGB(255, 182, 113, 103),
              onTap: phone.trim().isEmpty ? null : () => _openPhone(phone),
              fallbackIcon: Icons.phone,
            );
          }),
          SizedBox(width: 8.w),
          Obx(() {
            final ig = controller.instagram.value;
            return _buildSocialIconImage(
              'assets/icons/home/instgram.png',
              const Color(0xFFE4405F),
              onTap: ig.trim().isEmpty ? null : () => _openUrlIfAny(ig),
            );
          }),
          SizedBox(width: 8.w),
          Obx(() {
            final wa = controller.whatsapp.value;
            return _buildSocialIconImage(
              'assets/icons/home/watsapp.png',
              const Color(0xFF25D366),
              onTap: wa.trim().isEmpty ? null : () => _openWhatsapp(wa),
            );
          }),
          SizedBox(width: 8.w),
          Obx(() {
            final fb = controller.facebook.value;
            return _buildSocialIconImage(
              'assets/icons/home/facebook.png',
              const Color(0xFF1877F2),
              onTap: fb.trim().isEmpty ? null : () => _openUrlIfAny(fb),
            );
          }),
          SizedBox(width: 8.w),
          _buildSocialIconImage(
            'assets/icons/home/link.png',
            const Color(0xFF6366F1),
            onTap: () => _copyProfileLink(),
            fallbackIcon: Icons.link,
          ),
        ],
      ),
    );
  }

  // Widget _buildSocialIcon(IconData icon, Color color) {
  //   return Container(
  //     width: 50.w,
  //     height: 50.w,
  //     decoration: BoxDecoration(
  //       color: color.withValues(alpha: 0.1),
  //       borderRadius: BorderRadius.circular(15.r),
  //     ),
  //     child: Icon(icon, color: color, size: 24),
  //   );
  // }

  Widget _buildSocialIconImage(
    String imagePath,
    Color color, {
    VoidCallback? onTap,
    IconData? fallbackIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Image.asset(
            imagePath,
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icons if image fails to load
              if (imagePath.contains('instgram')) {
                return Icon(Icons.camera_alt, color: color, size: 28);
              } else if (imagePath.contains('watsapp')) {
                return Icon(Icons.phone, color: color, size: 28);
              } else if (imagePath.contains('facebook')) {
                return Icon(Icons.facebook, color: color, size: 28);
              } else if (imagePath.contains('phone')) {
                return Icon(
                  fallbackIcon ?? Icons.phone,
                  color: color,
                  size: 28,
                );
              } else if (imagePath.contains('link')) {
                return Icon(Icons.link, color: color, size: 28);
              }
              return Icon(Icons.link, color: color, size: 28);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSections(DoctorProfileController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildExpandableSection(
              title: 'السيرة الذاتية و صور الشهادات',
              isExpanded: controller.isBioExpanded,
              onToggle: controller.toggleBioExpansion,
              content: _buildBioContent(controller),
              isFirst: true,
              isLast: false,
            ),
            const Divider(height: 1, thickness: 1),
            _buildExpandableSection(
              title: 'العنوان',
              isExpanded: controller.isAddressExpanded,
              onToggle: controller.toggleAddressExpansion,
              content: _buildAddressContent(controller),
              isFirst: false,
              isLast: false,
            ),
            const Divider(height: 1, thickness: 1),
            _buildExpandableSection(
              title: 'الآراء',
              isExpanded: controller.isOpinionsExpanded,
              onToggle: controller.toggleOpinionsExpansion,
              content: _buildReviewsContent(controller),
              isFirst: false,
              isLast: false,
            ),
            const Divider(height: 1, thickness: 1),
            _buildExpandableSection(
              title: 'سعر الحجز',
              isExpanded: controller.isInsuranceExpanded,
              onToggle: controller.toggleInsuranceExpansion,
              content: _buildPricingContent(controller),
              isFirst: false,
              isLast: false,
            ),
            const Divider(height: 1, thickness: 1),
            _buildExpandableSection(
              title: 'صور لحالات تمت معالجتها',
              isExpanded: controller.isCasesExpanded,
              onToggle: controller.toggleCasesExpansion,
              content: _buildCaseImagesContent(controller),
              isFirst: false,
              isLast: false,
            ),
            const Divider(height: 1, thickness: 1),
            _buildExpandableSection(
              title: 'المواعيد المتاحة',
              isExpanded: controller.isAvailabilityExpanded,
              onToggle: controller.toggleAvailabilityExpansion,
              content: _buildAvailabilityContent(controller),
              isFirst: false,
              isLast: true,
            ),
            // const Divider(height: 1, thickness: 1),
            // _buildExpandableSection(
            //   title: 'طلب سيارة أجرة',
            //   isExpanded: false.obs,
            //   onToggle: () {},
            //   content: _buildInsuranceContent(controller),
            //   isFirst: false,
            //   isLast: true,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required RxBool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        // Header with tap functionality
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyText(
                    title,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    textAlign: TextAlign.right,
                  ),
                ),
                Obx(
                  () => AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded.value ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content with animation
        Obx(() {
          if (!isExpanded.value) {
            return const SizedBox.shrink();
          }
          return ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: content,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBioContent(DoctorProfileController controller) {
    return Obx(() {
      final hasCv = controller.cvDescription.value.isNotEmpty;
      final hasBio = controller.doctorBio.value.isNotEmpty;

      if (!hasCv && !hasBio) {
        return Center(
          child: MyText(
            'لا يوجد سيرة ذاتية',
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            hasCv ? controller.cvDescription.value : controller.doctorBio.value,
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 16.h),
          MyText(
            'الشهادات:',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final certificates = controller.cvCertificates;
            if (certificates.isEmpty) {
              return Container(
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(certificates.length, (i) {
                final item = certificates[i];
                final url = item['url'] ?? '';
                final name = _certificateName(item, i);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i == certificates.length - 1 ? 0 : 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _openImage(url),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image(
                            image: _imageProvider(url),
                            height: 180.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 180.h,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      MyText(
                        name,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }),
            );
          }),
          // Read-only in doctor details page (no actions)
        ],
      );
    });
  }

  Widget _buildAddressContent(DoctorProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final session = Get.find<SessionController>();
          final user = session.currentUser.value;
          final combinedAddress =
              user?.address ?? controller.doctorAddress.value;

          // فصل العنوان عن رابط جوجل ماب
          final parsed = controller.parseAddressAndLink(combinedAddress);
          final addressText = parsed['address'] ?? '';
          final mapLink = parsed['mapLink'] ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عرض العنوان المكتوب
              Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primary, size: 20.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: MyText(
                      addressText.isNotEmpty ? addressText : 'العنوان غير محدد',
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              // عرض رابط جوجل ماب إذا كان موجوداً
              if (mapLink.isNotEmpty) ...[
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () async {
                    try {
                      final uri = Uri.parse(mapLink);
                      final launched = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );

                      if (!launched) {
                        // محاولة فتح الرابط بطريقة أخرى
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.platformDefault,
                          );
                        } catch (_) {
                          Get.snackbar(
                            'خطأ',
                            'لا يمكن فتح رابط جوجل ماب',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      }
                    } catch (e) {
                      Get.snackbar(
                        'خطأ',
                        'رابط جوجل ماب غير صحيح: $e',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.map, color: AppColors.primary, size: 18.r),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: MyText(
                          'عرض على الخريطة',
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          textAlign: TextAlign.right,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildReviewsContent(DoctorProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => Column(
            children: controller.opinions
                .map(
                  (opinion) => Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: _buildReviewItem(
                      opinion['patientName'],
                      opinion['date'],
                      opinion['comment'],
                      opinion['rating'].toDouble(),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.centerRight,
          child: _buildAddOpinionButton(),
        ),
      ],
    );
  }

  Widget _buildAddOpinionButton() {
    return GestureDetector(
      onTap: _showAddOpinionDialog,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_comment, color: Colors.white, size: 20),
            SizedBox(width: 8.w),
            MyText(
              'إضافة رأي',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOpinionDialog() {
    final TextEditingController commentCtrl = TextEditingController();
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.rate_review_rounded,
                color: AppColors.primary,
                size: 56,
              ),
              SizedBox(height: 10.h),
              Text(
                'إضافة رأي',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Expo Arabic',
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'شارك تجربتك ليستفيد الآخرون.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Expo Arabic',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: commentCtrl,
                maxLines: 4,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اكتب تعليقك هنا...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14.sp,
                    fontFamily: 'Expo Arabic',
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.4,
                    ),
                  ),
                ),
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
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Expo Arabic',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final text = commentCtrl.text.trim();
                        if (text.isEmpty) return;
                        await LoadingDialog.show(message: 'جاري الإرسال...');
                        try {
                          final session = Get.find<SessionController>();
                          final String? userId = session.currentUser.value?.id;
                          if (userId == null || userId.isEmpty) {
                            LoadingDialog.hide();
                            await showStatusDialog(
                              title: 'غير مسجل',
                              message: 'يرجى تسجيل الدخول أولاً',
                              color: const Color(0xFFFF3B30),
                              icon: Icons.error_outline,
                            );
                            return;
                          }
                          final service = OpinionService();
                          final res = await service.addOpinion(
                            userId: userId,
                            targetId: widget.doctorId,
                            targetModel: 'User',
                            comment: text,
                          );
                          LoadingDialog.hide();
                          if (res['ok'] == true) {
                            Get.back();
                            await showStatusDialog(
                              title: 'تم الإرسال',
                              message: 'تم إضافة رأيك بنجاح',
                              color: AppColors.primary,
                              icon: Icons.check_circle_outline,
                            );
                          } else {
                            await showStatusDialog(
                              title: 'فشل الإرسال',
                              message:
                                  res['data']?['message']?.toString() ??
                                  'تعذر إضافة الرأي',
                              color: const Color(0xFFFF3B30),
                              icon: Icons.error_outline,
                            );
                          }
                        } catch (e) {
                          LoadingDialog.hide();
                          await showStatusDialog(
                            title: 'خطأ',
                            message: 'حدث خطأ غير متوقع: $e',
                            color: const Color(0xFFFF3B30),
                            icon: Icons.error_outline,
                          );
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
                      child: Text(
                        'إرسال',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Expo Arabic',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildReviewItem(
    String name,
    String time,
    String review,
    double rating,
  ) {
    // عرض التاريخ فقط بدون الوقت
    // Keep original computed date only if needed in future
    // String dateOnly = time;
    // try {
    //   final dt = DateTime.tryParse(time);
    //   if (dt != null) {
    //     dateOnly =
    //         '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    //   } else if (time.contains('T')) {
    //     dateOnly = time.split('T').first;
    //   }
    // } catch (_) {
    //   if (time.contains('T')) dateOnly = time.split('T').first;
    // }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: AppColors.primaryLight,
          child: MyText(
            name.isNotEmpty ? name[0] : '-',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الاسم + (منذ ..) بين قوسين بجانبه
              Row(
                children: [
                  MyText(
                    name,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: 8.w),
                  MyText(
                    '( ${_relativeFrom(time)} )',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              SizedBox(height: 8.h),
              // التعليق
              MyText(
                review,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _certificateName(Map<String, String> cert, int index) {
    final provided = (cert['name'] ?? '').trim();
    if (provided.isNotEmpty) return provided;
    final url = (cert['url'] ?? '').trim();
    final fallback = 'شهادة ${index + 1}';
    if (url.isEmpty) return fallback;
    try {
      final last = url.split('/').last;
      final decoded = Uri.decodeComponent(last);
      return decoded.isNotEmpty ? decoded : fallback;
    } catch (_) {
      return fallback;
    }
  }

  void _openImage(String url) {
    showDialog(
      context: Get.context!,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(0),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: InteractiveViewer(
              child: Center(
                child: Image(
                  image: _imageProvider(url),
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.broken_image,
                    color: Colors.white70,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCaseImagesContent(DoctorProfileController controller) {
    // جلب الحالات عند عرض هذا القسم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLoadingCases.value && controller.apiCases.isEmpty) {
        controller.loadDoctorCases(widget.doctorId);
      }
    });

    return Obx(() {
      if (controller.isLoadingCases.value) {
        return Skeletonizer(
          enabled: true,
          child: Column(
            children: List.generate(
              2,
              (idx) => Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 150.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12.r),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            ' ',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 8.h),
                          MyText(' ', fontSize: 14.sp),
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

      if (controller.apiCases.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: MyText(
              'لا توجد حالات بعد',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return Column(
        children: controller.apiCases.map((caseData) {
          final images = (caseData['images'] as List<dynamic>?) ?? [];
          final firstImage = images.isNotEmpty ? images.first.toString() : '';

          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image or placeholder
                Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    image: firstImage.isNotEmpty
                        ? DecorationImage(
                            image: _imageProvider(firstImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: firstImage.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.medical_services,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
                // Title and description
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        caseData['title']?.toString() ?? '',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 8.h),
                      MyText(
                        caseData['description']?.toString() ?? '',
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  String _relativeFrom(String iso) {
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return iso.contains('T') ? iso.split('T').first : iso;
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعات';
      if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.contains('T') ? iso.split('T').first : iso;
    }
  }

  Widget _buildPricingContent(DoctorProfileController controller) {
    return Obx(() {
      if (controller.isLoadingPricing.value) {
        return Skeletonizer(
          enabled: true,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(' ', fontSize: 16.sp, fontWeight: FontWeight.w600),
                Row(
                  children: [
                    MyText(' ', fontSize: 24.sp, fontWeight: FontWeight.bold),
                    SizedBox(width: 6.w),
                    MyText(' ', fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      if (controller.defaultPrice.value == 0.0) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: MyText(
            'لم يتم تحديد سعر الحجز بعد',
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(
              'سعر الحجز:',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            Row(
              children: [
                MyText(
                  controller.defaultPrice.value.toStringAsFixed(0),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6.w),
                MyText(
                  controller.currency.value,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAvailabilityContent(DoctorProfileController controller) {
    final weekNames = [
      'أحد',
      'اثنين',
      'ثلاثاء',
      'أربعاء',
      'خميس',
      'جمعة',
      'سبت',
    ];

    Color bgForStatus(String status) {
      switch (status) {
        case 'full':
          return const Color(0xFFB8E6D1); // darker green - الحجز ممتلأ
        case 'available':
          return const Color(0xFFD1D9E6); // darker gray - الحجز متاح
        case 'holiday':
          return const Color(0xFFFFE0A8); // darker yellow
        case 'closed':
          return const Color(0xFFFFC9C9); // darker red
        case 'open':
        default:
          return const Color(0xFFD1D9E6); // darker gray
      }
    }

    Widget legendDot(Color color) => Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    return Obx(() {
      final DateTime month = controller.selectedMonth.value;
      final int year = month.year;
      final int m = month.month;
      final DateTime firstDay = DateTime(year, m, 1);
      final int startIndex = firstDay.weekday % 7; // 0 => Sunday
      final int daysInMonth = DateTime(year, m + 1, 0).day;
      final int total = ((startIndex + daysInMonth + 6) ~/ 7) * 7;

      return controller.isLoadingCalendar.value
          ? Skeletonizer(
              enabled: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: 50.h, color: Colors.grey[300]),
                  SizedBox(height: 10.h),
                  Container(height: 20.h, color: Colors.grey[300]),
                  SizedBox(height: 10.h),
                  Container(height: 300.h, color: Colors.grey[300]),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Month header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: controller.nextMonth,
                      child: Icon(
                        Icons.chevron_left,
                        color: AppColors.textSecondary,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: MyText(
                        '$year / $m',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    InkWell(
                      onTap: controller.prevMonth,
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 32.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // Weekdays header
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final name in weekNames)
                        MyText(
                          name,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                // Calendar grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cellSize = (constraints.maxWidth - (6 * 12.w)) / 7;
                    final rows = (total / 7).ceil();
                    final gridHeight = (rows * cellSize) + ((rows - 1) * 12.h);

                    return SizedBox(
                      height: gridHeight,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: total,
                        itemBuilder: (_, i) {
                          if (i < startIndex || i >= startIndex + daysInMonth) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: AppColors.divider,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            );
                          }
                          final day = i - startIndex + 1;
                          // Use Obx for each day to track individual status changes
                          return Obx(() {
                            final status =
                                controller.dayStatuses[day] ?? 'open';
                            return Container(
                              decoration: BoxDecoration(
                                color: bgForStatus(status),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Center(
                                child: MyText(
                                  '$day',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                // Legend
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyText(
                          'الحجز متاح',
                          fontSize: 18.sp,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 10.w),
                        legendDot(const Color(0xFF9FB0C8)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyText(
                          'الحجوزات ممتلئة',
                          fontSize: 18.sp,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 10.w),
                        legendDot(const Color(0xFF62C299)), // أخضر - full
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyText(
                          'عطلة العيادة',
                          fontSize: 18.sp,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 10.w),
                        legendDot(const Color(0xFFFFC04D)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyText(
                          'مغلق',
                          fontSize: 18.sp,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 10.w),
                        legendDot(const Color(0xFFFF8787)),
                      ],
                    ),
                  ],
                ),
              ],
            );
    });
  }

  Widget _buildInsuranceContent(DoctorProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          'خدمات النقل المتاحة:',
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 16.h),

        // Ride service button
        InkWell(
          onTap: () {
            // Handle taxi booking
            Get.snackbar(
              'طلب سيارة أجرة',
              'سيتم توجيهك لتطبيق بلي',
              backgroundColor: AppColors.primary,
              colorText: Colors.white,
            );
          },
          borderRadius: BorderRadius.circular(25.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F2FF), // Very light blue background
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Row(
              children: [
                // Company logo - Baly style
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          'بلي',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0066FF), // Bright blue
                        ),
                        MyText(
                          'BALY',
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0066FF),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),

                // Service name
                Expanded(
                  child: MyText(
                    'شركة بلي',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 16.w),

                // Forward arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[700],
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 16.h, 28.w, 28.h),
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => PatientRegistrationPage(
              doctorId: widget.doctorId,
              doctorName: widget.doctorName,
              doctorSpecialty: widget.specializationId,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                'حجز موعد',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 8.w),
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPhone(String phoneNumber) async {
    final phone = phoneNumber.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.isEmpty) {
      Get.snackbar(
        'لا يوجد رقم هاتف',
        'لم يتم ضبط رقم الهاتف',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }
    final url = 'tel:$phone';
    await _launchExternal(url);
  }

  Future<void> _copyProfileLink() async {
    // استخدام رابط ويب (https) مثل Facebook
    // هذا الرابط سيظهر كرابط ويب عادي لكنه سيفتح التطبيق مباشرة
    // عند إعداد Universal Links على السيرفر (ملفات assetlinks.json و apple-app-site-association)
    // الرابط: https://hagz.app/doctor/{doctorId}
    final link = 'https://hagz.app/doctor/${widget.doctorId}';

    try {
      await Clipboard.setData(ClipboardData(text: link));
      Get.snackbar(
        'تم النسخ',
        'تم نسخ رابط الملف الشخصي\nسيتم فتح التطبيق مباشرة عند الضغط على الرابط',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'تعذر نسخ الرابط',
        backgroundColor: const Color(0xFFFF3B30),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _openWhatsapp(String input) async {
    final v = input.trim();
    if (v.isEmpty || v.startsWith('http://ABCDEFG')) {
      Get.snackbar(
        'لا يوجد رابط',
        'لم يتم ضبط رابط الواتساب',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }
    String url = v;
    if (!v.startsWith('http')) {
      final digits = v.replaceAll(RegExp(r'[^0-9+]'), '');
      url = 'https://wa.me/$digits';
    }
    await _launchExternal(url);
  }

  Future<void> _openUrlIfAny(String input) async {
    var v = input.trim();
    if (v.isEmpty || v.startsWith('http://ABCDEFG')) {
      Get.snackbar(
        'لا يوجد رابط',
        'لم يتم ضبط الرابط',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }
    if (!v.startsWith('http')) {
      v = 'https://$v';
    }
    await _launchExternal(v);
  }

  Future<void> _launchExternal(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'تعذر الفتح',
          'لا يمكن فتح الرابط',
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      Get.snackbar(
        'تعذر الفتح',
        'الرابط غير صالح',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }

  ImageProvider _imageProvider(String path) {
    // Clean quotes and whitespace
    String p = path.trim();
    if (p.isEmpty) {
      return const AssetImage('assets/icons/home/doctor.png');
    }
    if (p.startsWith('"') || p.startsWith("'")) {
      p = p.substring(1);
    }
    if (p.endsWith('"') || p.endsWith("'")) {
      p = p.substring(0, p.length - 1);
    }

    // Absolute http(s)
    if (p.startsWith('http://') || p.startsWith('https://')) {
      final host = Uri.tryParse(p)?.host.toLowerCase() ?? '';
      if (host.contains('scontent') ||
          host.contains('fbcdn') ||
          host.contains('facebook.com')) {
        return const AssetImage('assets/icons/home/doctor.png');
      }
      // Handle URLs with special characters by encoding them properly
      try {
        final uri = Uri.parse(p);
        final encodedUrl = uri.toString();
        return NetworkImage(encodedUrl);
      } catch (_) {
        // If URL parsing fails, try manual encoding of the path part
        try {
          final parts = p.split('/');
          if (parts.length > 3) {
            final baseParts = parts.take(parts.length - 1).join('/');
            final fileName = Uri.encodeComponent(parts.last);
            final encodedUrl = '$baseParts/$fileName';
            return NetworkImage(encodedUrl);
          }
        } catch (_) {}
        return const AssetImage('assets/icons/home/doctor.png');
      }
    }
    // Server-relative path
    if (p.startsWith('/')) {
      final url = ApiConstants.baseUrl + p;
      return NetworkImage(url);
    }
    // Windows or local file
    final isWindowsDrive = RegExp(r'^[A-Za-z]:\\').hasMatch(p);
    if (p.contains('\\') || isWindowsDrive || p.startsWith('/')) {
      return FileImage(File(p));
    }
    // Looks like a filename (relative server resource) - but avoid bare filenames like 'image.jpg'
    if (RegExp(
      r'^[\w\-\./]+\.(jpg|jpeg|png|gif|webp)$',
      caseSensitive: false,
    ).hasMatch(p)) {
      // Skip bare filenames without path structure - these are likely invalid/test data
      if (p == 'image.jpg' || p == 'image.png' || !p.contains('/')) {
        return const AssetImage('assets/icons/home/doctor.png');
      }
      // If it already contains a directory like images/, keep it; otherwise prepend /images/
      final needsImagesPrefix =
          !p.contains('/') ||
          (!p.startsWith('images/') && !p.contains('/images/'));
      final pathPart = needsImagesPrefix
          ? '/images/' + p
          : (p.startsWith('/') ? p : '/' + p);
      final url = ApiConstants.baseUrl + pathPart;
      return NetworkImage(url);
    }
    // Fallback to asset
    return const AssetImage('assets/icons/home/doctor.png');
  }
}
