class Properties {
  factory Properties() {
    return _singleton;
  }
  static final Properties _singleton = Properties._internal();

  Properties._internal();

  //CONSTANTES DO APP
  static const TITLE = "Agenda de Animes";

  //API SINFO - PRODUÇÃO
  static const CLIENT_ID = "3f2362c3b451351901583c4182a97945";
  static const CLIENT_SECRET = "xxx";
  static const XAPI_KEY = "xxx";
  static const URL_API_CONSULTA = "https://api.jikan.moe/v3";
  static const URL_API_AUTENTICACAO = "https://myanimelist.net/v1/oauth2/authorize";
  static const URL_REDIRECT = "http://localhost/oauth";
  static const STATE = "1F0DD5735849BE6B3AA17E7B77DCC4D2D4974A1A25B7F875CC7CAB818A7A9B8A";
}
