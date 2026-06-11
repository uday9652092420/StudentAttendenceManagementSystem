import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class GatePassRepository {
  Future<Response?> getGatePassDetails(
    String gatePassId,
  ) async {
    print(
      "REPOSITORY URL => ${EndPoints.getGatePassDetails}$gatePassId",
    );

    final response = await ApiService.get(
      "${EndPoints.getGatePassDetails}$gatePassId",
      requireAuthToken: true,
    );

    print(
      "REPOSITORY RESPONSE => ${response?.data}",
    );

    return response;
  }

  Future<Response?> saveMovement(
    Map<String, dynamic> body,
  ) async {
    return await ApiService.post(
      EndPoints.saveMovement,
      body,
      requireAuthToken:
          false, //temperary change, will handle auth token in controller
    );
  }
}
