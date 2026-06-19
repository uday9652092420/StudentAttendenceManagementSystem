import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class GatePassRepository {
  /// GET GATE PASS DETAILS BY QR
  Future<Response?> getGatePassDetails(
    String gatePassId,
  ) async {
    final response = await ApiService.get(
      "${EndPoints.getGatePassDetails}$gatePassId",
      requireAuthToken: true,
    );

    return response;
  }

  /// CREATE OUT MOVEMENT
  Future<Response?> saveMovement(
    Map<String, dynamic> body,
  ) async {
    return await ApiService.post(
      EndPoints.saveMovement,
      body,
      requireAuthToken: false,
    );
  }

  /// GET EXISTING MOVEMENT BY MOVEMENT ID
  Future<Response?> getMovementDetails(
    String movementId,
  ) async {
    return await ApiService.get(
      "${EndPoints.updateMovement}/$movementId",
      requireAuthToken: false,
    );
  }

  /// GET MOVEMENT BY GATE PASS ID
  Future<Response?> getMovementByGatePass(
    String gatePassId,
  ) async {
    return await ApiService.get(
      "${EndPoints.getGatePassDetails}$gatePassId",
      requireAuthToken: false,
    );
  }

  /// UPDATE RETURN MOVEMENT
  Future<Response?> updateMovement(
    String movementId,
    Map<String, dynamic> body,
  ) async {
    return await ApiService.put(
      "${EndPoints.updateMovement}/$movementId",
      body,
      requireAuthToken: false,
    );
  }
}
