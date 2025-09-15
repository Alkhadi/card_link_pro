class FeatureFlags {
  // Paid rails OFF for now
  static const enablePispPayByBank = false;
  static const enableCardProcessor = false;
  static const enableMonzoMe = false; // set true only if you actually use it
  static const enableRevolutMe = false;

  // Deep link on iOS requires Apple Developer Program
  static const enableIosUniversalLinks = false;

  // Free features (keep ON)
  static const enableCopyAndOpenBankApp = true;
  static const enablePdfLinks = true;
  static const enableSharePack = true;
}
