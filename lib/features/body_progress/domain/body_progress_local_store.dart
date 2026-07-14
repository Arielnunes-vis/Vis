/// Armazenamento local (offline-first) da evolução corporal (PROMPT 08).
///
/// Abstração testável: guarda listas serializadas por usuário e coleção
/// (weight, measurements, photos, goals).
abstract interface class BodyProgressLocalStore {
  List<Map<String, dynamic>> read(String userId, String collection);
  Future<void> write(
    String userId,
    String collection,
    List<Map<String, dynamic>> items,
  );
}
