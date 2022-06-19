
class GlobalVar{
  factory GlobalVar() {
    return _singleton;
  }
  static final GlobalVar _singleton = GlobalVar._internal();

  GlobalVar._internal();

  String _usuarioMAL;

  String get usuarioMAL => _usuarioMAL;

  set usuarioMAL(String value) => _usuarioMAL = value;
}