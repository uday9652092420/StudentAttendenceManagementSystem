class HostelRoomModel {
  String id;
  String roomName;
  int capacity;
  int availableCapacity;
  HostelRoomModel({
    required this.id,
    required this.roomName,
    required this.capacity,
    required this.availableCapacity,
  });
  factory HostelRoomModel.fromJson(Map<String, dynamic> json) {
    return HostelRoomModel(
      id: json["id"],
      roomName: json["room_name"],
      capacity: json["capacity"],
      availableCapacity: json["available_capacity"],
    );
  }
}
