
import '../domain/User.dart';

class GlobalVar{
  factory GlobalVar() {
    return _singleton;
  }
  static final GlobalVar _singleton = GlobalVar._internal();

  GlobalVar._internal();

  User _user;

  String _token;

  String _refreshTOken;

  bool _firstMalLogin = false;

  User get user => _user;

  set user(User value) => _user = value;

  get token => this._token;

  set token( value) => this._token = value;

  get refreshTOken => this._refreshTOken;

  set refreshTOken( value) => this._refreshTOken = value;

  get isLoggedIn => this._token != null ? true : false;

  set firstMalLogin(bool value) => this._firstMalLogin = value;

  get isFirstMalLogin => this._firstMalLogin;
}