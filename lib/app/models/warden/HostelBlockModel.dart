import 'package:my_new_app/app/models/warden/HostelFloorModel.dart';

class HostelBlockModel {
  String id;
  String blockName;
  List<HostelFloorModel> floors;

  HostelBlockModel({
    required this.id,
    required this.blockName,
    required this.floors,
  });

  factory HostelBlockModel.fromJson(Map<String, dynamic> json) {
    return HostelBlockModel(
      id: json["id"],
      blockName: json["block_name"],
      floors: (json["floors"] as List)
          .map((e) => HostelFloorModel.fromJson(e))
          .toList(),
    );
  }
}
