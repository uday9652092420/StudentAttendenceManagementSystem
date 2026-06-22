class MovementDetailsModel {
  String? id;

  bool? outConfirmed;
  String? outConfirmedAt;
  String? outSecurityGuard;

  bool? returnConfirmed;
  String? returnConfirmedAt;
  String? returnSecurityGuard;

  MovementDetailsModel({
    this.id,
    this.outConfirmed,
    this.outConfirmedAt,
    this.outSecurityGuard,
    this.returnConfirmed,
    this.returnConfirmedAt,
    this.returnSecurityGuard,
  });

  factory MovementDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MovementDetailsModel(
      id: json["id"]?.toString(),
      outConfirmed: json["outConfirmed"] ?? json["out_confirmed"],
      outConfirmedAt: json["outConfirmedAt"]?.toString() ??
          json["out_confirmed_at"]?.toString(),
      outSecurityGuard: json["outSecurityGuard"]?.toString() ??
          json["out_security_guard"]?.toString(),
      returnConfirmed: json["returnConfirmed"] ?? json["return_confirmed"],
      returnConfirmedAt: json["returnConfirmedAt"]?.toString() ??
          json["return_confirmed_at"]?.toString(),
      returnSecurityGuard: json["returnSecurityGuard"]?.toString() ??
          json["return_security_guard"]?.toString(),
    );
  }
}
