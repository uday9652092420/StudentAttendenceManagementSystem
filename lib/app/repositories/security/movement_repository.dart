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
    print("=================================");
    print("POST URL => ${EndPoints.saveMovement}");
    print("POST BODY => $body");
    print("=================================");

    final response = await ApiService.post(
      EndPoints.saveMovement,
      body,
      requireAuthToken: false,
    );

    print("=================================");
    print("POST STATUS => ${response?.statusCode}");
    print("POST RESPONSE => ${response?.data}");
    print("=================================");

    return response;
  }
}
