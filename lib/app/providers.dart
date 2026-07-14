/// Barrel de providers globais do VIS.
///
/// Reexporta os providers mais usados para facilitar o consumo pelas
/// features. A injeção de dependência é sempre feita via Riverpod
/// (04_FLUTTER_ARCHITECTURE.md).
library;

export '../core/network/connection_provider.dart';
export '../core/supabase/supabase_provider.dart';
export '../features/ai/providers/ai_providers.dart';
export '../features/authentication/providers/authentication_providers.dart';
export '../features/onboarding/providers/onboarding_providers.dart';
export 'router.dart';
