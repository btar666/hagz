import '../../utils/constants.dart';
import 'api_request.dart';

class SecretaryService {
  final ApiRequest _api = ApiRequest();

  /// إنشاء حساب سكرتير جديد للطبيب
  Future<Map<String, dynamic>> createSecretary({
    required String name,
    required String phone,
    required String password,
    required String gender,
    required int age,
    required String city,
    required String address,
    String image = '',
  }) async {
    print('👤 CREATE SECRETARY REQUEST');
    print('📝 Name: $name');
    print('📞 Phone: $phone');
    print('👤 Gender: $gender');
    print('🎂 Age: $age');
    print('🏙️ City: $city');
    print('📍 Address: $address');
    print('🖼️ Image: $image');

    final body = {
      'name': name,
      'phone': phone,
      'password': password,
      'gender': gender,
      'age': age,
      'city': city,
      'address': address,
      if (image.isNotEmpty) 'image': image,
    };

    print('📤 CREATE SECRETARY REQUEST BODY:');
    print('URL: ${ApiConstants.secretary}');
    print('Body: $body');

    final res = await _api.post(ApiConstants.secretary, body);

    print('📥 CREATE SECRETARY RESPONSE: $res');
    return res;
  }

  /// جلب جميع السكرتارية التابعين للطبيب
  Future<Map<String, dynamic>> getSecretaries({
    int page = 1,
    int limit = 20,
  }) async {
    print('📋 GET SECRETARIES REQUEST');
    print('📄 Page: $page, Limit: $limit');

    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    print('📤 GET SECRETARIES REQUEST:');
    print('URL: ${ApiConstants.secretary}');
    print('Params: $params');

    final url =
        '${ApiConstants.secretary}?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final res = await _api.get(url);

    print('📥 GET SECRETARIES RESPONSE: $res');
    return res;
  }

  /// جلب تفاصيل سكرتير محدد
  Future<Map<String, dynamic>> getSecretaryById(String secretaryId) async {
    print('👤 GET SECRETARY BY ID REQUEST');
    print('🆔 Secretary ID: $secretaryId');

    final url = '${ApiConstants.secretary}/$secretaryId';
    print('📤 GET SECRETARY BY ID REQUEST:');
    print('URL: $url');

    final res = await _api.get(url);

    print('📥 GET SECRETARY BY ID RESPONSE: $res');
    return res;
  }

  /// تحديث معلومات سكرتير
  Future<Map<String, dynamic>> updateSecretary({
    required String secretaryId,
    String? name,
    String? phone,
    String? city,
    String? address,
    int? age,
    String? image,
  }) async {
    print('✏️ UPDATE SECRETARY REQUEST');
    print('🆔 Secretary ID: $secretaryId');

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (city != null) body['city'] = city;
    if (address != null) body['address'] = address;
    if (age != null) body['age'] = age;
    if (image != null && image.isNotEmpty) body['image'] = image;

    print('📤 UPDATE SECRETARY REQUEST BODY:');
    print('URL: ${ApiConstants.secretary}/$secretaryId');
    print('Body: $body');

    final res = await _api.put('${ApiConstants.secretary}/$secretaryId', body);

    print('📥 UPDATE SECRETARY RESPONSE: $res');
    return res;
  }

  /// حذف حساب سكرتير
  Future<Map<String, dynamic>> deleteSecretary(String secretaryId) async {
    print('🗑️ DELETE SECRETARY REQUEST');
    print('🆔 Secretary ID: $secretaryId');

    final url = '${ApiConstants.secretary}/$secretaryId';
    print('📤 DELETE SECRETARY REQUEST:');
    print('URL: $url');

    final res = await _api.delete(url);

    print('📥 DELETE SECRETARY RESPONSE: $res');
    return res;
  }

  /// تفعيل أو تعطيل حساب سكرتير
  Future<Map<String, dynamic>> updateSecretaryStatus({
    required String secretaryId,
    required String status, // 'نشط' | 'معطل'
  }) async {
    print('🔄 UPDATE SECRETARY STATUS REQUEST');
    print('🆔 Secretary ID: $secretaryId');
    print('📊 Status: $status');

    final body = {'status': status};
    final url = '${ApiConstants.secretary}/$secretaryId/status';

    print('📤 UPDATE SECRETARY STATUS REQUEST BODY:');
    print('URL: $url');
    print('Body: $body');

    final res = await _api.put(url, body);

    print('📥 UPDATE SECRETARY STATUS RESPONSE: $res');
    return res;
  }

  /// تغيير كلمة مرور السكرتير
  Future<Map<String, dynamic>> changeSecretaryPassword({
    required String secretaryId,
    required String newPassword,
  }) async {
    print('🔐 CHANGE SECRETARY PASSWORD REQUEST');
    print('🆔 Secretary ID: $secretaryId');

    final body = {'newPassword': newPassword};
    final url = '${ApiConstants.secretary}/$secretaryId/password';

    print('📤 CHANGE SECRETARY PASSWORD REQUEST BODY:');
    print('URL: $url');
    print('Body: {newPassword: [HIDDEN]}');

    final res = await _api.put(url, body);

    print('📥 CHANGE SECRETARY PASSWORD RESPONSE: $res');
    return res;
  }
}
