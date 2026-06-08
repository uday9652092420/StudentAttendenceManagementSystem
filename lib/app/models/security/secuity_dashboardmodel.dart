class GatepassScanModel {
  final String qrCode;
  final String securityName;
  final String scanTime;

  GatepassScanModel({
    required this.qrCode,
    required this.securityName,
    required this.scanTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "qrCode": qrCode,
      "securityName": securityName,
      "scanTime": scanTime,
    };
  }
}
