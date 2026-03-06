class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }
}
