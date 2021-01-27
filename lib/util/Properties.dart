class Properties {
  factory Properties() {
    return _singleton;
  }
  static final Properties _singleton = Properties._internal();

  Properties._internal();

  //CONSTANTES DO APP
  static const TITLE = "Agenda de Animes";

  //API SINFO - PRODUÇÃO
  static const CLIENT_ID = "xxx";
  static const CLIENT_SECRET = "xxx";
  static const XAPI_KEY = "xxx";
  static const URL_API_CONSULTA = "https://api.ufrn.br/";
  static const URL_API_AUTENTICACAO = "https://myanimelist.net/v1/oauth2/authorize";
  static const URL_REDIRECT = "https://firzenanimeschedule.com";
}
