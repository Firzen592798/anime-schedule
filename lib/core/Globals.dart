
class GlobalVar{
  factory GlobalVar() {
    return _singleton;
  }
  static final GlobalVar _singleton = GlobalVar._internal();

  GlobalVar._internal();

  String _usuarioMAL;

  String _token;

  String _refreshTOken;

  String get usuarioMAL => _usuarioMAL;

  set usuarioMAL(String value) => _usuarioMAL = value;

  get token => this._token;

  set token( value) => this._token = value;

  get refreshTOken => this._refreshTOken;

  set refreshTOken( value) => this._refreshTOken = value;
}