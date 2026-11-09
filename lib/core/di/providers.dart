/// Dependency Injection providers (Riverpod) para el módulo Core.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymusic/core/logging/app_logger.dart';
import 'package:mymusic/core/network/retry_policy.dart';
import 'package:mymusic/core/utils/text_utils.dart';

// Logger
final loggerProvider = Provider<AppLogger>((ref) => AppLogger());

/// Text utilities (solo lectura, stateless)
final textUtilsProvider = Provider<TextUtils>((ref) => TextUtils());

/// Retry policy configurado por defecto (3 intentos, backoff 2-4-8s)
final retryPolicyProvider =
    Provider<RetryPolicy>((ref) => RetryPolicy(maxAttempts: 3));
