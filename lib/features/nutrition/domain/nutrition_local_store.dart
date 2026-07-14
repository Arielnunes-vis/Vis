/// Armazenamento local (offline-first) da nutrição (PROMPT 10).
abstract interface class NutritionLocalStore {
  List<Map<String, dynamic>> readList(String userId, String collection);
  Future<void> writeList(
    String userId,
    String collection,
    List<Map<String, dynamic>> items,
  );

  Map<String, dynamic>? readMap(String userId, String key);
  Future<void> writeMap(String userId, String key, Map<String, dynamic> value);
}
