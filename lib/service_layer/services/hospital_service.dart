import '../../utils/constants.dart';
import 'api_request.dart';

class HospitalService {
  final ApiRequest _api = ApiRequest();

  Future<Map<String, dynamic>> getHospitals() async {
    final res = await _api.get(ApiConstants.hospitals);
    return res;
  }
}
