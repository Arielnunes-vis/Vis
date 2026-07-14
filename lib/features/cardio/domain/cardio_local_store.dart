/// Armazenamento local (offline-first) do cardio (PROMPT 09).
abstract interface class CardioLocalStore {
  List<Map<String, dynamic>> read(String userId, String collection);
  Future<void> write(
    String userId,
    String collection,
    List<Map<String, dynamic>> items,
  );
}
