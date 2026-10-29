class AppConfig {
  AppConfig._();

  static const String demoEmail = 'ayupramudita@gmail.com';
  static const String demoPassword = '123456';

  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '771436050247-6kqgnr059hiu1puecs7n3jv4it00grij.apps.googleusercontent.com',
  );
}