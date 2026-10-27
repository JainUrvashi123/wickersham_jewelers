import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';

class MetalService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>?> getMetalPrices() async {
    try {
      final response = await _dio.get('/m_api/metal-prices');
      var responseData = response.data;
      if (response.statusCode == 200 && responseData != null) {
        if (responseData is Map && responseData['status'] == true) {
          return responseData['data'] as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      print('Failed to get metal prices: $e');
      return null;
    }
  }
}
