class MovementDetailsModel {
  String? id;
  bool? outConfirmed;
  String? outConfirmedAt;
  String? outSecurityGuard;
  bool? returnConfirmed;
  String? returnSecurityGuard;

  MovementDetailsModel({
    this.id,
    this.outConfirmed,
    this.outConfirmedAt,
    this.outSecurityGuard,
    this.returnConfirmed,
    this.returnSecurityGuard,
  });

  factory MovementDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovementDetailsModel(
      id: json["id"],
      outConfirmed: json["outConfirmed"],
      outConfirmedAt: json["outConfirmedAt"],
      outSecurityGuard: json["outSecurityGuard"],
      returnConfirmed: json["returnConfirmed"],
      returnSecurityGuard: json["returnSecurityGuard"],
    );
  }
}
