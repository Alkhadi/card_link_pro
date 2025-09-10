import 'dart:async';

/// Provider-agnostic interface for Open Banking PISP.
/// Replace the TODO parts with calls to your chosen provider (TrueLayer/Token/Yapily).
class PaymentIntentService {
  final bool enabled; // feature flag
  const PaymentIntentService({this.enabled = false});

  Future<Uri?> createAndGetRedirectUrl({
    required String payeeName,
    required String sortCode,
    required String accountNumber,
    String? iban,
    String? bic,
    String? amount, // "12.34"
    String? reference,
  }) async {
    if (!enabled) return null;

    // TODO: Implement Open Banking payment initiation here.
    // Return the redirect/app link provided by your OB provider.
    return null;
  }
}
