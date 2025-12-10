import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../widget/my_text.dart';
import '../service_layer/services/permission_service.dart';

class LocationPickerController extends GetxController {
  MapController? mapController;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingLocation = false.obs;
  final Rx<LatLng> selectedLocation = const LatLng(
    33.3152,
    44.3661,
  ).obs; // بغداد
  final RxString selectedAddress = ''.obs;
  final Location location = Location();

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
  }

  Future<void> getCurrentLocation() async {
    isLoadingLocation.value = true;

    try {
      bool hasPermission = await PermissionService.ensureLocationPermission();
      if (!hasPermission) return;

      bool serviceEnabled = await PermissionService.ensureLocationService();
      if (!serviceEnabled) return;

      await location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 10000,
        distanceFilter: 5,
      );

      LocationData? locationData = await location.getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('انتهت مهلة تحديد الموقع'),
      );

      if (locationData.latitude != null && locationData.longitude != null) {
        selectedLocation.value = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );

        await Future.delayed(const Duration(milliseconds: 100));
        mapController?.move(selectedLocation.value, 15.0);

        await getAddressFromLatLng(selectedLocation.value);
      }
    } catch (e) {
      print('خطأ في تحديد الموقع: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديد الموقع الحالي',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    isLoading.value = true;

    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        selectedAddress.value = _formatAddress(place);
      }
    } catch (e) {
      selectedAddress.value = 'العنوان غير متوفر';
    } finally {
      isLoading.value = false;
    }
  }

  String _formatAddress(geo.Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }

    return addressParts.isNotEmpty ? addressParts.join(', ') : 'عنوان غير محدد';
  }

  void onMapTapped(LatLng position) {
    selectedLocation.value = position;
    getAddressFromLatLng(position);
  }

  Map<String, dynamic> getLocationData() {
    return {
      'latitude': selectedLocation.value.latitude,
      'longitude': selectedLocation.value.longitude,
      'address': selectedAddress.value,
    };
  }

  String getGoogleMapsLink() {
    final lat = selectedLocation.value.latitude;
    final lng = selectedLocation.value.longitude;
    return 'https://www.google.com/maps?q=$lat,$lng';
  }
}

class LocationPickerWidget extends StatelessWidget {
  final Function(Map<String, dynamic>)? onLocationSelected;

  const LocationPickerWidget({super.key, this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationPickerController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: MyText(
                        'تحديد الموقع على الخريطة',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
            ),

            // Map
            Expanded(
              child: Stack(
                children: [
                  Obx(
                    () => FlutterMap(
                      mapController: controller.mapController,
                      options: MapOptions(
                        initialCenter: controller.selectedLocation.value,
                        initialZoom: 15.0,
                        onTap: (tapPosition, point) =>
                            controller.onMapTapped(point),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.hagz.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: controller.selectedLocation.value,
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_on,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Current location button
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: Obx(
                      () => Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.isLoadingLocation.value
                              ? null
                              : controller.getCurrentLocation,
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            width: 48.w,
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: controller.isLoadingLocation.value
                                ? Center(
                                    child: SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.my_location,
                                    color: AppColors.primary,
                                    size: 24.sp,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Address info card
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      MyText(
                        'العنوان:',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => controller.isLoading.value
                        ? Row(
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              MyText(
                                'جاري تحديد العنوان...',
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          )
                        : Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.textLight),
                            ),
                            child: MyText(
                              controller.selectedAddress.value.isNotEmpty
                                  ? controller.selectedAddress.value
                                  : 'العنوان غير محدد',
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                              maxLines: 3,
                            ),
                          ),
                  ),
                  SizedBox(height: 16.h),
                  // عرض رابط جوجل ماب
                  Obx(
                    () {
                      // قراءة selectedLocation مباشرة لضمان التفاعل
                      final location = controller.selectedLocation.value;
                      final lat = location.latitude;
                      final lng = location.longitude;
                      final mapLink = 'https://www.google.com/maps?q=$lat,$lng';
                      
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.map,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        'رابط جوجل ماب',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                      SizedBox(height: 4.h),
                                      MyText(
                                        'تم إنشاء الرابط تلقائياً',
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            // عرض الرابط
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: MyText(
                                      mapLink,
                                      fontSize: 13.sp,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),
                            // أزرار الإجراءات
                            Row(
                              children: [
                                // زر فتح في جوجل ماب
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      try {
                                        final uri = Uri.parse(mapLink);
                                        final launched = await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                        if (!launched) {
                                          await launchUrl(
                                            uri,
                                            mode: LaunchMode.platformDefault,
                                          );
                                        }
                                      } catch (e) {
                                        Get.snackbar(
                                          'خطأ',
                                          'لا يمكن فتح رابط جوجل ماب',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      Icons.open_in_new,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    label: MyText(
                                      'فتح في جوجل ماب',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // زر نسخ
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: AppColors.primary),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: mapLink));
                                      Get.snackbar(
                                        'تم النسخ',
                                        'تم نسخ رابط جوجل ماب',
                                        backgroundColor: AppColors.primary,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 2),
                                        icon: Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.copy,
                                      color: AppColors.primary,
                                      size: 22.sp,
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
                  SizedBox(height: 20.h),
                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final locationData = controller.getLocationData();
                        if (onLocationSelected != null) {
                          onLocationSelected!(locationData);
                        }
                        Get.back(result: locationData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: MyText(
                        'تأكيد الموقع',
                        fontSize: 18.sp,
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
    );
  }
}
