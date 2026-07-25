import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/vehicle.dart';

class VehicleRepository {
  VehicleRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Vehicle>> fetchAll({String? search, String? sort}) async {
    final List<String> querySegments = [];
    if (search != null && search.isNotEmpty) {
      querySegments.add('search=${Uri.encodeComponent(search)}');
    }
    if (sort != null && sort.isNotEmpty) {
      querySegments.add('sort=$sort');
    }
    final String queryString =
        querySegments.isNotEmpty ? '?${querySegments.join('&')}' : '';

    final data = await _apiClient.get('/vehicles$queryString');
    final items = data['data'] as List<dynamic>;

    return items
        .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Vehicle> fetchById(int id) async {
    final data = await _apiClient.get('/vehicles/$id');
    final vehicleJson = data['data'] as Map<String, dynamic>? ?? data;

    return Vehicle.fromJson(vehicleJson);
  }

  Future<Vehicle> create(
    Map<String, dynamic> payload, {
    File? photo,
  }) async {
    FormData? formData;
    if (photo != null) {
      formData = FormData.fromMap({
        ...payload,
        'photo': await MultipartFile.fromFile(photo.path),
      });
    }
    final data = await _apiClient.post(
      '/vehicles',
      data: formData ?? payload,
    );
    final vehicleJson = data['data'] as Map<String, dynamic>;

    return Vehicle.fromJson(vehicleJson);
  }

  Future<Vehicle> update(
    int id,
    Map<String, dynamic> payload, {
    File? photo,
    bool? removePhoto,
  }) async {
    FormData? formData;
    if (photo != null || removePhoto != null) {
      formData = FormData.fromMap({
        ...payload,
        if (photo != null) 'photo': await MultipartFile.fromFile(photo.path),
        if (removePhoto != null) 'remove_photo': removePhoto,
      });
    }
    final data = await _apiClient.put(
      '/vehicles/$id',
      data: formData ?? payload,
    );
    final vehicleJson = data['data'] as Map<String, dynamic>? ?? data;

    return Vehicle.fromJson(vehicleJson);
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('/vehicles/$id');
  }
}
