import 'package:animeschedule/util/Token.dart';

class GlobalVar{
  factory GlobalVar() {
    return _singleton;
  }
  static final GlobalVar _singleton = GlobalVar._internal();

  GlobalVar._internal();

  //Token do myanimelist
  Token _token;

  set token(Token value) => _token = value;

  Token get token => _token;
}