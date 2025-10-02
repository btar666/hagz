import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/banner_model.dart';
import '../../utils/constants.dart';

class BannerService {
  static const String baseUrl = ApiConstants.sliders;
  static const String bannersEndpoint = '';
  static const Map<String, String> headers = {'Accept': 'application/json'};

  /// جلب جميع الإعلانات النشطة
  Future<List<BannerModel>> getActiveBanners() async {
    try {
      final uri = Uri.parse('$baseUrl$bannersEndpoint');
      final response = await http.get(uri, headers: headers);
      // ignore: avoid_print
      print(
        'SLIDERS RESPONSE (active): ${response.statusCode} ${response.body}',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = json.decode(response.body);
        // ignore: avoid_print
        print('SLIDERS DATA: ' + data.toString());
        final List<dynamic> bannersJson = (data['data'] as List? ?? []);
        return bannersJson
            .map((json) => BannerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('فشل في جلب الإعلانات: ${response.statusCode}');
      }
    } catch (e) {
      // في حالة عدم وجود اتصال بالإنترنت أو خطأ في API
      print('خطأ في جلب الإعلانات: $e');

      // إرجاع بيانات وهمية للاختبار
      return _getMockBanners();
    }
  }

  /// جلب جميع الإعلانات (نشطة وغير نشطة)
  Future<List<BannerModel>> getAllBanners() async {
    try {
      final uri = Uri.parse('$baseUrl$bannersEndpoint');
      final response = await http.get(uri, headers: headers);
      // ignore: avoid_print
      print('SLIDERS RESPONSE (all): ${response.statusCode} ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = json.decode(response.body);
        // ignore: avoid_print
        print('SLIDERS DATA: ' + data.toString());
        final List<dynamic> bannersJson = (data['data'] as List? ?? []);
        return bannersJson
            .map((json) => BannerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('فشل في جلب الإعلانات: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في جلب الإعلانات: $e');
      return _getMockBanners();
    }
  }

  /// بيانات وهمية للاختبار عندما لا يتوفر API
  List<BannerModel> _getMockBanners() {
    return [
      BannerModel(
        id: 1,
        image: 'assets/icons/home/news1.png',
        title: 'إعلان طبي 1',
        description: 'احصل على استشارة طبية مجانية',
        url: 'https://example.com/medical-consultation',
        isActive: true,
      ),
      BannerModel(
        id: 2,
        image: 'assets/icons/home/news1.png',
        title: 'إعلان طبي 2',
        description: 'خصم 20% على جميع الفحوصات',
        url: 'https://example.com/medical-tests',
        isActive: true,
      ),
      BannerModel(
        id: 3,
        image: 'assets/icons/home/news1.png',
        title: 'إعلان طبي 3',
        description: 'حجز موعد مع أفضل الأطباء',
        url: 'https://example.com/book-appointment',
        isActive: true,
      ),
    ];
  }

  /// تحديث حالة الإعلان
  Future<bool> updateBannerStatus(int bannerId, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$bannersEndpoint/$bannerId'),
        headers: headers,
        body: json.encode({'is_active': isActive ? 1 : 0}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('خطأ في تحديث حالة الإعلان: $e');
      return false;
    }
  }

  /// جلب إعلان واحد بواسطة ID
  Future<BannerModel?> getBannerById(int bannerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$bannersEndpoint/$bannerId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return BannerModel.fromJson(data['data'] ?? data);
      }
      return null;
    } catch (e) {
      print('خطأ في جلب الإعلان: $e');
      return null;
    }
  }
}
