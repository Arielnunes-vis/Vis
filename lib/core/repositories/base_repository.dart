/// Contrato base de todos os repositórios do VIS.
///
/// A camada de apresentação (Screen → Controller) nunca acessa o
/// Supabase diretamente: sempre passa por um repositório
/// (04_FLUTTER_ARCHITECTURE.md / Regra 5).
abstract interface class BaseRepository {
  /// Nome da tabela/coleção que o repositório gerencia.
  String get table;
}
