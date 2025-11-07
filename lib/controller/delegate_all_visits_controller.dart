import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service_layer/services/visits_service.dart';
import 'session_controller.dart';

class DelegateAllVisitsController extends GetxController {
  final VisitsService _service = VisitsService();
  final SessionController _session = Get.find<SessionController>();

  // البيانات من الـ API
  final doctorsVisits = <Map<String, dynamic>>[].obs;
  final hospitalsVisits = <Map<String, dynamic>>[].obs;
  final complexesVisits = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final currentTab = 0.obs; // 0: أطباء, 1: مستشفيات, 2: مجمعات
  
  // البحث
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllVisits();
  }

  /// تحميل جميع الزيارات
  Future<void> loadAllVisits() async {
    final userId = _session.currentUser.value?.id;
    if (userId == null || userId.isEmpty) return;

    isLoading.value = true;
    try {
      final res = await _service.getRepresentativeVisits(
        representativeId: userId,
        limit: 100, // جلب عدد كبير من الزيارات
      );

      if (res['ok'] == true) {
        final responseData = res['data'];
        List<dynamic> dataList = [];

        if (responseData != null) {
          if (responseData['data'] != null && responseData['data'] is List) {
            dataList = responseData['data'];
          } else if (responseData is List) {
            dataList = responseData;
          }
        }

        // معالجة البيانات وتحويلها إلى كروت
        final allVisits = dataList.map((item) {
          final specialization = item['doctorSpecialization']?.toString() ?? '';

          // تحديد النوع بناءً على التخصص
          String visitType = 'doctor'; // افتراضي طبيب
          if (specialization == 'مستشفى' ||
              specialization.toLowerCase().contains('مستشفى')) {
            visitType = 'hospital';
          } else if (specialization == 'مجمع طبي' ||
              specialization == 'مجمع' ||
              specialization.toLowerCase().contains('مجمع')) {
            visitType = 'complex';
          }

          return {
            'id': item['_id']?.toString() ?? '',
            'title': item['doctorName']?.toString() ?? 'غير معروف',
            'subtitle': specialization,
            'isSubscribed': item['visitStatus']?.toString() == 'مشترك',
            'visits': item['visitCount'] as int?,
            'reason': item['nonSubscriptionReason']?.toString(),
            'type': visitType,
            'address': item['doctorAddress']?.toString() ?? '',
            'phone': item['doctorPhone']?.toString() ?? '',
            'governorate': item['governorate']?.toString() ?? '',
            'district': item['district']?.toString() ?? '',
            'notes': item['notes']?.toString() ?? '',
            'coordinates': item['coordinates'] as Map<String, dynamic>? ?? {},
          };
        }).toList();

        // فلترة حسب النوع
        doctorsVisits.value = allVisits.where((v) {
          final type = v['type']?.toString() ?? '';
          return type == 'doctor';
        }).toList();

        hospitalsVisits.value = allVisits.where((v) {
          final type = v['type']?.toString() ?? '';
          return type == 'hospital';
        }).toList();

        complexesVisits.value = allVisits.where((v) {
          final type = v['type']?.toString() ?? '';
          return type == 'complex';
        }).toList();

        print(
          '✅ Doctors: ${doctorsVisits.length}, Hospitals: ${hospitalsVisits.length}, Complexes: ${complexesVisits.length}',
        );

        print('✅ Loaded visits: ${allVisits.length} total');
      } else {
        print('❌ Failed to load visits: ${res['message']}');
        doctorsVisits.value = [];
        hospitalsVisits.value = [];
        complexesVisits.value = [];
      }
    } catch (e) {
      print('❌ Error loading visits: $e');
      doctorsVisits.value = [];
      hospitalsVisits.value = [];
      complexesVisits.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير التبويب
  void changeTab(int index) {
    currentTab.value = index;
  }

  /// جلب البيانات للتبويب الحالي مع البحث
  List<Map<String, dynamic>> get currentTabVisits {
    List<Map<String, dynamic>> visits;
    switch (currentTab.value) {
      case 0:
        visits = doctorsVisits;
        break;
      case 1:
        visits = hospitalsVisits;
        break;
      case 2:
        visits = complexesVisits;
        break;
      default:
        visits = doctorsVisits;
    }

    // تطبيق البحث
    if (searchQuery.value.isEmpty) {
      return visits;
    }

    final query = searchQuery.value.toLowerCase();
    return visits.where((visit) {
      final title = (visit['title']?.toString() ?? '').toLowerCase();
      final subtitle = (visit['subtitle']?.toString() ?? '').toLowerCase();
      final address = (visit['address']?.toString() ?? '').toLowerCase();
      final phone = (visit['phone']?.toString() ?? '').toLowerCase();
      
      return title.contains(query) ||
          subtitle.contains(query) ||
          address.contains(query) ||
          phone.contains(query);
    }).toList();
  }
  
  /// تحديث البحث
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// إعادة تحميل البيانات
  Future<void> refresh() async {
    await loadAllVisits();
  }

  @override
  void onClose() {
    // حذف البيانات عند مغادرة الصفحة
    doctorsVisits.clear();
    hospitalsVisits.clear();
    complexesVisits.clear();
    searchController.dispose();
    isLoading.value = false;
    currentTab.value = 0;
    super.onClose();
  }
}
