import 'package:my_new_app/app/models/warden/HostelRoomModel.dart';

class HostelFloorModel {
  String id;
  String blockId;
  String floorLabel;
  int floorIndex;
  List<HostelRoomModel> rooms;
  HostelFloorModel({
    required this.id,
    required this.blockId,
    required this.floorLabel,
    required this.floorIndex,
    required this.rooms,
  });
  factory HostelFloorModel.fromJson(Map<String, dynamic> json) {
    return HostelFloorModel(
      id: json["id"],
      blockId: json["block_id"],
      floorLabel: json["floor_label"],
      floorIndex: json["floor_index"],
      rooms: (json["rooms"] as List)
          .map((e) => HostelRoomModel.fromJson(e))
          .toList(),
    );
  }
}
