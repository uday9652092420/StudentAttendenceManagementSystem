import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/repositories/teacherstundentattendance/attendance_repository.dart';

class TeacherAttendanceHistoryController extends GetxController {
  final AttendanceRepository repository = AttendanceRepository();
  final RxList<Map<String, dynamic>> sessions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = "".obs;

  static const int _limit = 20;
  int _page = 1;
  bool _hasMore = true;
  bool _requestInFlight = false;

  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    loadHistory(reset: true);
  }

  Future<void> loadHistory({bool reset = false}) async {
    if (_requestInFlight || (!reset && !_hasMore)) return;
    if (reset) {
      _page = 1;
      _hasMore = true;
      sessions.clear();
      errorMessage.value = "";
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    _requestInFlight = true;

    try {
      final response = await repository.getStaffAttendanceHistory(
        page: _page,
        limit: _limit,
        rethrowErrors: true,
      );
      debugPrint("Attendance history HTTP status: ${response?.statusCode}");

      if (response == null) {
        throw const FormatException("No attendance history response received.");
      }
      if (response.statusCode != 200 ||
          (response.data is Map && response.data["success"] == false)) {
        throw Exception(
          _backendMessage(response.data) ??
              "Unable to load attendance history (HTTP ${response.statusCode}).",
        );
      }

      final parsed = _parsePage(response.data);
      sessions.addAll(parsed.rows);
      _hasMore = parsed.hasMore ?? parsed.rows.length == _limit;
      if (parsed.rows.isEmpty) _hasMore = false;
      if (_hasMore) _page++;
      debugPrint(
        "Attendance history page=$_page rows=${parsed.rows.length} "
        "hasMore=$_hasMore",
      );
    } on DioException catch (error) {
      errorMessage.value = _backendMessage(error.response?.data) ??
          error.message ??
          "Unable to load attendance history. Check your connection and retry.";
      debugPrint(
        "Attendance history DioException: type=${error.type}, "
        "statusCode=${error.response?.statusCode}, "
        "message=${_sanitize(errorMessage.value)}",
      );
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst("Exception: ", "");
    } finally {
      _requestInFlight = false;
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  _HistoryPage _parsePage(dynamic body) {
    dynamic payload = body;
    if (payload is Map && payload["data"] != null) payload = payload["data"];

    List<Map<String, dynamic>>? rows;
    dynamic pagination;
    if (payload is List) {
      rows = _mapRows(payload);
    } else if (payload is Map) {
      pagination = payload["pagination"] ?? payload["meta"];
      for (final key in ["sessions", "history", "items", "records", "data"]) {
        if (payload[key] is List) {
          rows = _mapRows(payload[key] as List);
          break;
        }
      }
    }
    if (rows == null) {
      throw const FormatException(
        "Attendance history response did not contain a session list.",
      );
    }

    bool? hasMore;
    if (pagination is Map) {
      final explicit = pagination["hasNext"] ??
          pagination["hasMore"] ??
          pagination["hasNextPage"];
      if (explicit is bool) hasMore = explicit;
      final totalPages = int.tryParse(
        (pagination["totalPages"] ?? pagination["total_pages"] ?? "")
            .toString(),
      );
      final currentPage = int.tryParse(
        (pagination["page"] ?? pagination["currentPage"] ?? _page).toString(),
      );
      if (hasMore == null && totalPages != null && currentPage != null) {
        hasMore = currentPage < totalPages;
      }
    }
    return _HistoryPage(rows, hasMore);
  }

  List<Map<String, dynamic>> _mapRows(List values) => values
      .whereType<Map>()
      .map((row) => Map<String, dynamic>.from(row))
      .toList();

  String? _backendMessage(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is Map) {
      for (final key in ["message", "error", "detail"]) {
        final message = value[key];
        if (message is String && message.trim().isNotEmpty) return message;
      }
      final data = value["data"];
      if (data is Map) return _backendMessage(data);
    }
    return null;
  }

  String _sanitize(String value) => value
      .replaceAll(
        RegExp(r'(authorization|token|password)\s*[:=]\s*\S+',
            caseSensitive: false),
        '[REDACTED]',
      )
      .replaceAll(
        RegExp(r'\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b'),
        '[REDACTED]',
      );
}

class _HistoryPage {
  const _HistoryPage(this.rows, this.hasMore);

  final List<Map<String, dynamic>> rows;
  final bool? hasMore;
}
