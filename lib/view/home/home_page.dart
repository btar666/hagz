import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hagz/view/home/hospital/hospital_details_page.dart';
import 'package:hagz/view/home/complex/complex_details_page.dart';
import '../../controller/main_controller.dart';
import '../../controller/home_controller.dart';
import '../../controller/hospitals_controller.dart';
import '../../bindings/hospital_details_binding.dart';
import '../../utils/app_colors.dart';
import '../../widget/search_widget.dart';
import 'search_page.dart';
import '../../bindings/search_binding.dart';
import '../../widget/banner_carousel.dart';
import '../../widget/my_text.dart';
import '../../widget/specialization_text.dart';
import '../../widget/animated_pressable.dart';
import '../../widget/doctors_filter_dialog.dart';
import '../chat/chats_page.dart';
import 'doctors/top_rated_doctors_page.dart';
import 'doctors/doctor_profile_page.dart';
import '../../model/hospital_model.dart';
import '../../bindings/chats_binding.dart';
import '../../bindings/doctor_profile_binding.dart';
import '../../bindings/complex_details_binding.dart';
import '../../controller/session_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    final HomeController home = Get.find<HomeController>();

    // تأكد من تحديث البيانات عند العودة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDataRefresh(home);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await home.fetchDoctors(reset: true);
          final hospitals = Get.find<HospitalsController>();
          await hospitals.fetchHospitals();
          await home.fetchTopRatedDoctors();
        },
        child: Column(
          children: [
            // Top section with header and search
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Chat icon
                    GestureDetector(
                      onTap: () => Get.to(
                        () => const ChatsPage(),
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
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 22,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Search bar (expanded to take remaining space)
                    Expanded(
                      child: SearchWidget(
                        hint: 'ابحث عن طبيب أو مستشفى...',
                        readOnly: true,
                        onTap: () => Get.to(
                          () => const SearchPage(),
                          binding: SearchBinding(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Profile avatar
                    Obx(() {
                      final session = Get.find<SessionController>();
                      final user = session.currentUser.value;
                      final String img = user?.image ?? '';
                      final String gender = (user?.gender ?? '').toLowerCase();
                      final String type = (user?.userType ?? '')
                          .toString(); // 'User' | 'Doctor' | 'Secretary' | 'Representative'
                      String? fallbackAsset;
                      if (img.isEmpty) {
                        final isFemale =
                            gender.contains('female') ||
                            gender.contains('أنث') ||
                            gender.contains('انث');
                        if (type == 'Doctor') {
                          fallbackAsset = 'assets/icons/home/doctor.png';
                        } else {
                          fallbackAsset = isFemale
                              ? 'assets/icons/home/person_woman.jpg'
                              : 'assets/icons/home/person_man.png';
                        }
                      }
                      return Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: img.isNotEmpty
                            ? Image.network(
                                img,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    (fallbackAsset != null
                                    ? Image.asset(
                                        fallbackAsset,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 28,
                                      )),
                              )
                            : (fallbackAsset != null
                                  ? Image.asset(
                                      fallbackAsset,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    )),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Rest of the content (scrollable)
            Expanded(
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: home.scrollController,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            // Banner carousel section
                            const BannerCarousel(),
                            SizedBox(height: 20.h),

                            // Top rated doctors section - يظهر فقط في تبويب الأطباء
                            Obx(() {
                              if (controller.homeTabIndex.value == 0) {
                                return Column(
                                  children: [
                                    _buildTopRatedDoctorsSection(home),
                                    SizedBox(height: 20.h),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            }),

                            // Tab buttons (الكل)
                            _buildTabHeader(),
                            SizedBox(height: 20.h),

                            // Content tabs (scrolls with whole page)
                            Obx(() {
                              final i = controller.homeTabIndex.value;
                              if (i == 0) return _buildDoctorsTab(home);
                              if (i == 1) return _buildHospitalsTab();
                              return _buildMedicalCentersTab();
                            }),
                            SizedBox(
                              height: 20.h,
                            ), // Space before fixed bottom tabs
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Fixed bottom tab selector
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                    child: _buildBottomTabs(controller),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabHeader() {
    return Row(
      children: [
        MyText(
          'الكل',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          textAlign: TextAlign.start,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            final result = await Get.dialog(const DoctorsFilterDialog());
            if (result is Map) {
              // TODO: apply filters to data source if needed
            }
          },
          child: Icon(Icons.tune, color: AppColors.textSecondary, size: 24.sp),
        ),
      ],
    );
  }

  Widget _buildDoctorsTab(HomeController home) {
    return Obx(() {
      final items = home.doctors;
      final isLoading = home.isLoadingDoctors.value;
      final isLoadingMore = home.isLoadingMoreDoctors.value;

      return Skeletonizer(
        enabled: isLoading,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 178 / 247,
          ),
          itemCount: isLoading ? 6 : items.length + (isLoadingMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (isLoading) {
              return _buildDoctorCardFromData({
                'id': '',
                'name': '—',
                'specialization': '—',
              });
            }
            if (index < items.length) {
              final doctor = items[index];
              return _buildDoctorCardFromData(doctor);
            }
            // loading more placeholders
            return _buildDoctorCardFromData({
              'id': '',
              'name': '—',
              'specialization': '—',
            });
          },
        ),
      );
    });
  }

  Widget _buildHospitalsTab() {
    final HospitalsController hospitals = Get.find<HospitalsController>();
    return Obx(() {
      final items = hospitals.hospitals;
      final isLoading = hospitals.isLoading.value;

      const placeholder = HospitalModel(
        id: '',
        name: '',
        image: '',
        address: '',
        phone: '',
        facebook: '',
        instagram: '',
        whatsapp: '',
      );

      return Skeletonizer(
        enabled: isLoading,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 178 / 209,
          ),
          itemCount: isLoading ? 6 : items.length,
          itemBuilder: (context, index) {
            if (isLoading) {
              return _buildHospitalCardFromData(placeholder);
            }
            return _buildHospitalCardFromData(items[index]);
          },
        ),
      );
    });
  }

  Widget _buildMedicalCentersTab() {
    // عرض المجمعات بقائمة منفصلة لكن بنفس تصميم المستشفيات وبنفس شبكة العرض
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 178 / 209,
      ),
      itemCount: _complexNames.length,
      itemBuilder: (context, index) {
        return _buildComplexCard(index);
      },
    );
  }

  Widget _buildDoctorCardFromData(Map<String, dynamic> doctor) {
    final String id = (doctor['id'] ?? doctor['_id'] ?? '').toString();
    final String name = (doctor['name'] ?? '').toString();
    final String specialization = (doctor['specialization'] ?? '').toString();
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

  // بيانات المجمعات (منفصلة عن المستشفيات)
  final List<String> _complexNames = const [
    'مجمع الشفاء الطبي',
    'مجمع الرفاه الطبي',
    'مجمع الحياة الطبي',
    'مجمع النخيل الطبي',
  ];
  final List<String> _complexLocations = const [
    'شارع الزهور قرب دوار الجامعة',
    'المنطقة الطبية قرب المستشفى التعليمي',
    'شارع المدينة مجاور مجمع الأطباء',
    'الحي الراقي قرب حديقة النخيل',
  ];

  // removed legacy _buildHospitalCard

  Widget _buildHospitalCardFromData(hospital) {
    final String name = hospital.name;
    final String image = hospital.image;
    return GestureDetector(
      onTap: () {
        Get.to(
          () => const HospitalDetailsPage(),
          arguments: {'id': hospital.id},
          binding: HospitalDetailsBinding(),
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
              padding: EdgeInsets.symmetric(horizontal: 9.w),
              child: Container(
                width: 155.w,
                height: 140.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.local_hospital,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          'assets/icons/home/hospital.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Flexible(
              child: MyText(
                name,
                fontFamily: 'Expo Arabic',
                color: AppColors.textPrimary,
                fontSize: 16.46.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: 0,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexCard(int index) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ComplexDetailsPage(
            complexName: _complexNames[index % _complexNames.length],
            complexLocation:
                _complexLocations[index % _complexLocations.length],
          ),
          binding: ComplexDetailsBinding(),
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
              padding: EdgeInsets.symmetric(horizontal: 9.w),
              child: Container(
                width: 155.w,
                height: 140.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    'assets/icons/home/hospital.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.apartment,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Flexible(
              child: MyText(
                _complexNames[index % _complexNames.length],
                fontFamily: 'Expo Arabic',
                color: AppColors.textPrimary,
                fontSize: 16.46.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: 0,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  // Skeleton card for regular doctors grid
  // Widget _buildDoctorSkeletonCard() { return SizedBox.shrink(); }

  // Skeleton card for top-rated doctors
  // Widget _buildTopRatedDoctorSkeletonCard() { return SizedBox.shrink(); }

  // Skeleton card for hospitals
  // Widget _buildHospitalSkeletonCard() { return SizedBox.shrink(); }

  Widget _buildTopRatedDoctorsSection(HomeController home) {
    return Obx(() {
      final items = home.topRatedDoctors;
      final isLoading = home.isLoadingTopRated.value;

      // إخفاء القسم تماماً إذا لم يكن هناك تحميل ولا بيانات
      if (!isLoading && items.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.to(
              () => const TopRatedDoctorsPage(),
              binding: BindingsBuilder(() {
                // TopRatedDoctorsPage لا يحتاج controller خاص
              }),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyText(
                      'الأطباء الأعلى تقييماً',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 197.h,
            child: Skeletonizer(
              enabled: isLoading,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: isLoading ? 4 : items.length,
                separatorBuilder: (context, index) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final item = isLoading
                      ? {'doctorId': '', 'name': '—', 'specialty': ''}
                      : items[index];
                  return SizedBox(
                    width: 137.w,
                    height: 197.h,
                    child: _buildTopRatedDoctorCardFromItem(item),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}

Widget _buildTopRatedDoctorCardFromItem(Map<String, dynamic> item) {
  final String doctorId = (item['doctorId'] ?? '').toString();
  final String name = (item['name'] ?? 'طبيب').toString();
  final String specialty = (item['specialty'] ?? '').toString();
  final String image = (item['image'] ?? '').toString();
  // final avgRaw = item['avg'];
  // final countRaw = item['count'];
  'د. آرين';
  'د. صوفيا';
  'د. سونجوز';
  'د. مالوون';
  'د. أحمد';
  'د. فاطمة';
  'د. خالد';
  'د. مريم';

  // final List<String> specialties = [];

  return GestureDetector(
    onTap: () {
      Get.to(
        () => DoctorProfilePage(
          doctorId: doctorId,
          doctorName: name,
          specializationId: specialty,
        ),
        binding: DoctorProfileBinding(),
      );
    },
    child: Container(
      width: double.infinity,
      height: double.infinity,
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
          SizedBox(height: 5.h),
          Center(
            child: Container(
              width: 126.w,
              height: 135.h,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
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
          SizedBox(height: 8.h),
          MyText(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 6.h),
          SpecializationText(
            specializationId: specialty.isEmpty ? null : specialty,
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

Widget _buildBottomTabs(MainController controller) {
  final List<String> tabLabels = ['أطباء', 'مستشفيات', 'مجمعات'];

  return Obx(
    () => Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // أبيض
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = controller.homeTabIndex.value == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeHomeTab(index),
              child: Container(
                height: 50.h,
                decoration: isSelected
                    ? BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25.r),
                      )
                    : null,
                child: Center(
                  child: MyText(
                    tabLabels[index],
                    fontFamily: 'Expo Arabic',
                    fontWeight: FontWeight.w600, // SemiBold
                    fontSize: 16.sp,
                    height: 1.0, // line-height: 100%
                    letterSpacing: 0, // letter-spacing: 0%
                    color: isSelected ? Colors.white : AppColors.primary,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}

Future<void> _ensureDataRefresh(HomeController home) async {
  try {
    if (home.doctors.isEmpty && !home.isLoadingDoctors.value) {
      await home.fetchDoctors(reset: true);
    }
    if (home.topRatedDoctors.isEmpty && !home.isLoadingTopRated.value) {
      await home.fetchTopRatedDoctors();
    }
  } catch (_) {}
}
