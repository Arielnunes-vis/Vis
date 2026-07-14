import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../logger/app_logger.dart';

/// Armazenamento local (Hive) para cache e suporte offline (PROMPT 01).
///
/// Prepara as boxes usadas pelas features (treinos, peso, medidas,
/// cardio, cache, fila de sincronização). A gravação/leitura de
/// domínio fica nos repositórios de cada feature.
final class LocalStorageService {
  const LocalStorageService();

  /// Inicializa o Hive e abre as boxes base. Chamado no bootstrap.
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(AppConstants.boxWorkouts),
      Hive.openBox<dynamic>(AppConstants.boxWeight),
      Hive.openBox<dynamic>(AppConstants.boxMeasurements),
      Hive.openBox<dynamic>(AppConstants.boxCardio),
      Hive.openBox<dynamic>(AppConstants.boxCache),
      Hive.openBox<dynamic>(AppConstants.boxSyncQueue),
    ]);
    AppLogger.i('[Hive] Boxes locais inicializadas.');
  }

  Box<dynamic> box(String name) => Hive.box<dynamic>(name);

  Future<void> put(String boxName, String key, Object value) =>
      box(boxName).put(key, value);

  T? get<T>(String boxName, String key) => box(boxName).get(key) as T?;

  Future<void> delete(String boxName, String key) =>
      box(boxName).delete(key);

  Future<void> clearBox(String boxName) => box(boxName).clear();
}
