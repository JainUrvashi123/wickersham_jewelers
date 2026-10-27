import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../core/network/dio_client.dart';
import '../models/jewelry_model.dart';
import '../models/jewelry_filter_model.dart';

class JewelryService {
  final Dio _dio = DioClient().dio;

  Future<JewelryFilterData> getFilters() async {
    try {
      final response = await _dio.get('/m_api/jewelry-filter-list');

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }
      
      if (response.statusCode == 200) {
        if (responseData is Map && responseData['status'] == 1) {
          return JewelryFilterData.fromJson(responseData['data']);
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch filters');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching filters'));
    }
  }

  Future<Map<String, dynamic>> getNewArrivals() async {
    try {
      final response = await _dio.get('/m_api/new-arrival');

      // Log the type so you can see exactly what Dio is doing
      debugPrint("DATA TYPE: ${response.data.runtimeType}");
      debugPrint("NEW ARRIVAL RESPONSE: ${response.data}");

      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        // If the server sends a string, manually decode it to a Map

        final decoded = jsonDecode(response.data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }

      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint("NEW ARRIVAL SERVICE ERROR: $e");
      throw Exception('Network Error: $e');
    }
  }

  Future<List<JewelryItem>> getJewelry({
    List<String>? categoryName,
    List<String>? metalType,
    List<String>? stoneShape,
    List<String>? stoneName,
    String? price,
    String sort = 'p_low',
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> data = {
        if (categoryName != null && categoryName.isNotEmpty) "category_name": categoryName,
        if (metalType != null && metalType.isNotEmpty) "metal_type": metalType,
        if (stoneShape != null && stoneShape.isNotEmpty) "stone_shape": stoneShape,
        if (stoneName != null && stoneName.isNotEmpty) "stone_name": stoneName,
        if (price != null && price.isNotEmpty) "price": price,
        "sort": sort,
        "offset": offset.toString(),
        "limit": limit.toString(),
      };

      final response = await _dio.post('/m_api/jewelry', data: data);

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['code'] == 3 || responseData['code'] == 1 || responseData['status'] == 1 || responseData['code'] == 2)) {
          final records = responseData['record'] as List?;
          if (records != null) {
            return records.map((e) => JewelryItem.fromJson(e)).toList();
          }
          return [];
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch jewelry');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching jewelry'));
    }
  }

  Future<Map<String, dynamic>> getJewelryDetail(String jewelryId) async {
    try {
      final response = await _dio.request(
        '/m_api/jewelry-detail',
        options: Options(method: 'GET'),
        data: {'jewelry_id': jewelryId},
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching jewelry detail'));
    }
  }

  Future<Map<String, dynamic>> addToCart(String jewelryId, {String? userId}) async {
    try {
      final response = await _dio.request(
        '/m_api/jewelry-add-cart',
        options: Options(method: 'GET'),
        data: {
          'jewelry_id': jewelryId,
          if (userId != null) 'user_id': userId,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred adding to cart'));
    }
  }
}
