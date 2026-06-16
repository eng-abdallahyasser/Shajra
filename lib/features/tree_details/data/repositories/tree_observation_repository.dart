import 'package:get_storage/get_storage.dart';
import '../../domain/entities/tree_observation_entity.dart';

/// Repository for persisting tree inspection observations using GetStorage.
///
/// Observations are stored under the key `tree_observations_{treeId}` so each
/// tree has its own history.
class TreeObservationRepository {
  final _storage = GetStorage();

  /// Storage key prefix per tree.
  static String _key(String treeId) => 'tree_observations_$treeId';

  /// Save a new observation entry.
  Future<void> insert(TreeObservationEntity observation) async {
    final list = _loadList(observation.treeId);
    list.add(observation.toJson());
    await _storage.write(_key(observation.treeId), list);
  }

  /// Retrieve all observations for a given tree, newest first.
  List<TreeObservationEntity> fetchByTreeId(String treeId) {
    final list = _loadList(treeId)
        .map((e) => TreeObservationEntity.fromJson(e))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Retrieve observations for a specific tree + category, newest first.
  List<TreeObservationEntity> fetchByTreeIdAndCategory(
    String treeId,
    String category,
  ) {
    return fetchByTreeId(treeId)
        .where((o) => o.category == category)
        .toList();
  }

  /// Delete a single observation entry.
  Future<void> delete(String treeId, String observationId) async {
    final list = _loadList(treeId);
    list.removeWhere((e) => e['id'] == observationId);
    await _storage.write(_key(treeId), list);
  }

  /// Delete all observations for a tree.
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
