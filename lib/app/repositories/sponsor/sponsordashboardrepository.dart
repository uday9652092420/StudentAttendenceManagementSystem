import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class SponsorRepository {
  Future<dynamic> getDashboard() async {
    return await ApiService.get(
      EndPoints.sponsorDashboard,
      requireAuthToken: true,
    );
  }
}
