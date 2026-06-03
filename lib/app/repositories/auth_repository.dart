import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class AuthRepository {
  //otp up
  Future<Response> postlogin(requestBody) async {
    return await ApiService.post(EndPoints.apipostlogin, requestBody,
        requireAuthToken: false);
  }

  // Future<void> partnerLogout() async {
  //   await ApiService.post(
  //     EndPoints.apiPostLogout, // ex: partners/logout
  //     {},
  //     requireAuthToken: true,
  //   );
  // }
}
//
