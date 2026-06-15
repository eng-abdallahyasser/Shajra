import 'package:get_storage/get_storage.dart';
import '../../domain/entities/scan_log_entity.dart';

/// Repository for persisting disease scan logs using GetStorage.
///
/// Logs are stored under the key `scan_logs_{treeId}` so each tree has its
/// own history, avoiding loading all scans across the entire app at once.
class ScanLogRepository {
  final _storage = GetStorage();

  /// Storage key prefix per tree.
  static String _key(String treeId) => 'scan_logs_$treeId';

  /// Save a new scan log entry.
  Future<void> insert(ScanLogEntity log) async {
    final logs = _loadList(log.treeId);
    logs.add(log.toJson());
    await _storage.write(_key(log.treeId), logs);
  }

  /// Retrieve all scan logs for a given tree, newest first.
  List<ScanLogEntity> fetchByTreeId(String treeId) {
    final logs = _loadList(treeId)
        .map((e) => ScanLogEntity.fromJson(e))
        .toList();
    logs.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return logs;
  }

  /// Delete a single log entry.
  Future<void> delete(String treeId, String logId) async {
    final logs = _loadList(treeId);
    logs.removeWhere((e) => e['id'] == logId);
    await _storage.write(_key(treeId), logs);
  }

  /// Delete all logs for a tree.
  Future<void> deleteAll(String treeId) async {
    await _storage.remove(_key(treeId));
  }

  // ---- Internal ----

  List<Map<String, dynamic>> _loadList(String treeId) {
    final raw = _storage.read<List<dynamic>>(_key(treeId));
    if (raw == null) return [];
    return raw.cast<Map<String, dynamic>>();
  }
}
