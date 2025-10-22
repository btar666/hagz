import '../../model/specialization_model.dart';
import '../../utils/constants.dart';
import 'api_request.dart';

class SpecializationService {
  final ApiRequest _api = ApiRequest();

  /// جلب قائمة الاختصاصات النشطة
  Future<Map<String, dynamic>> getSpecializations({
    int page = 1,
    int limit = 100,
  }) async {
    print('🏥 GET SPECIALIZATIONS REQUEST');
    
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/specializations/')
        .replace(queryParameters: params);
    
    final res = await _api.get(uri.toString());
    
    print('🏥 GET SPECIALIZATIONS RESPONSE: $res');
    
    return res;
  }

  /// جلب قائمة الاختصاصات كـ List<SpecializationModel>
  Future<List<SpecializationModel>> getSpecializationsList() async {
    try {
      final res = await getSpecializations();
      print('🏥 Full response: $res');
      
      // التحقق من نجاح الطلب
      if (res['ok'] == true && res['data'] != null) {
        final responseData = res['data'];
        print('🏥 Response data: $responseData');
        
        // في حالة API هذا، البيانات تأتي بهذا الشكل:
        // { "status": true, "data": [...], "total": 16 }
        if (responseData is Map<String, dynamic> && 
            responseData['status'] == true && 
            responseData['data'] is List) {
          final List<dynamic> dataList = responseData['data'] as List<dynamic>;
          print('🏥 Found ${dataList.length} specializations');
          
          return dataList.map((item) {
            return SpecializationModel.fromJson(item as Map<String, dynamic>);
          }).toList();
        }
        // إذا كانت البيانات مباشرة في شكل list
        else if (responseData is List) {
          print('🏥 Direct list with ${responseData.length} specializations');
          return responseData.map((item) {
            return SpecializationModel.fromJson(item as Map<String, dynamic>);
          }).toList();
        }
      }
    } catch (e) {
      print('🏥 ERROR GETTING SPECIALIZATIONS LIST: $e');
    }
    return [];
  }

  /// جلب اختصاص واحد بالـ ID
  Future<SpecializationModel?> getSpecializationById(String id) async {
    try {
      print('🏥 GET SPECIALIZATION BY ID: $id');
      
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/specializations/$id');
      final res = await _api.get(uri.toString());
      
      print('🏥 GET SPECIALIZATION BY ID RESPONSE: $res');
      
      if (res['ok'] == true && res['data'] != null) {
        final responseData = res['data'];
        
        // التحقق من بنية الاستجابة
        if (responseData is Map<String, dynamic>) {
          // إذا كانت البيانات تحتوي على status و data
          if (responseData['status'] == true && responseData['data'] != null) {
            return SpecializationModel.fromJson(responseData['data'] as Map<String, dynamic>);
          }
          // إذا كانت البيانات مباشرة
          else if (responseData['_id'] != null) {
            return SpecializationModel.fromJson(responseData);
          }
        }
      }
    } catch (e) {
      print('🏥 ERROR GETTING SPECIALIZATION BY ID: $e');
    }
    return null;
  }

  /// جلب الأطباء المرتبطين باختصاص معين
  Future<Map<String, dynamic>> getDoctorsBySpecialization({
    required String specializationId,
    int page = 1,
    int limit = 20,
    String? city,
    String? search,
  }) async {
    print('🏥 GET DOCTORS BY SPECIALIZATION REQUEST: $specializationId');
    
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (city != null && city.isNotEmpty) {
      params['city'] = city;
    }
    
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/specializations/$specializationId/doctors')
        .replace(queryParameters: params);
    
    final res = await _api.get(uri.toString());
    
    print('🏥 GET DOCTORS BY SPECIALIZATION RESPONSE: $res');
    
    return res;
  }
}