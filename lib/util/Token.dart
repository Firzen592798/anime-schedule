class Token {
  String _accessToken;
  String _refreshToken;
  int _accessTokenExpiresIn;
  int _refreshTokenExpiresIn;

  String get accessToken => _accessToken;

  set accessToken(String value) => _accessToken = value;

  String get refreshToken => _refreshToken;

  set refreshToken(String value) => _refreshToken = value;

  get accessTokenExpiresIn => _accessTokenExpiresIn;

  set accessTokenExpiresIn(int value) => _accessTokenExpiresIn = value;

  int get refreshTokenExpiresIn => _refreshTokenExpiresIn;

  set refreshTokenExpiresIn(int value) => _refreshTokenExpiresIn = value;
}
