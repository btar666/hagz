import '../services/specialization_service.dart';
import '../../model/specialization_model.dart';

class SpecializationCacheService {
  static final SpecializationCacheService _instance = SpecializationCacheService._internal();
  factory SpecializationCacheService() => _instance;
  SpecializationCacheService._internal();

  final SpecializationService _specializationService = SpecializationService();
  final Map<String, SpecializationModel> _cache = {};
  final Map<String, Future<SpecializationModel?>> _pendingRequests = {};

  /// جلب اسم الاختصاص بالـ ID مع استخدام الـ cache
  Future<String> getSpecializationName(String? specializationId, {String defaultName = 'غير محدد'}) async {
    if (specializationId == null || specializationId.isEmpty) {
      return defaultName;
    }

    try {
      final specialization = await getSpecializationById(specializationId);
      return specialization?.name ?? defaultName;
    } catch (e) {
      print('🏥 Error getting specialization name: $e');
      return defaultName;
    }
  }

  /// جلب الاختصاص بالـ ID مع استخدام الـ cache
  Future<SpecializationModel?> getSpecializationById(String id) async {
    // التحقق من الـ cache أولاً
    if (_cache.containsKey(id)) {
      return _cache[id];
    }

    // التحقق من الطلبات المعلقة لتجنب الطلبات المكررة
    if (_pendingRequests.containsKey(id)) {
      return await _pendingRequests[id];
    }

    // إنشاء طلب جديد
    final future = _fetchSpecialization(id);
    _pendingRequests[id] = future;

    try {
      final result = await future;
      _pendingRequests.remove(id);
      
      if (result != null) {
        _cache[id] = result;
      }
      
      return result;
    } catch (e) {
      _pendingRequests.remove(id);
      rethrow;
    }
  }

  Future<SpecializationModel?> _fetchSpecialization(String id) async {
    return await _specializationService.getSpecializationById(id);
  }

  /// تحديث الـ cache بقائمة كاملة من الاختصاصات
  void updateCache(List<SpecializationModel> specializations) {
    for (final spec in specializations) {
      _cache[spec.id] = spec;
    }
  }

  /// مسح الـ cache
  void clearCache() {
    _cache.clear();
    _pendingRequests.clear();
  }

  /// الحصول على جميع الاختصاصات المحفوظة في الـ cache
  List<SpecializationModel> getCachedSpecializations() {
    return _cache.values.toList();
  }

  /// التحقق من وجود اختصاص في الـ cache
  bool isSpecializationCached(String id) {
    return _cache.containsKey(id);
  }
}