import 'package:animeschedule/service/ApiService.dart';
import 'package:animeschedule/util/Properties.dart';
import 'package:animeschedule/util/Toasts.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

//URL Tutorial MAL https://myanimelist.net/blog.php?eid=835707

//URL padrão de login
String _urlLogin = "${Properties.URL_API_AUTENTICACAO}&response_type=code&client_id=${Properties.CLIENT_ID}";
  
class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  WebViewController _controller;
  ApiService apiService = ApiService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text(Properties.TITLE)),
       body: Container(
          child: WebView(
            initialUrl: _urlLogin,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
            },

             navigationDelegate: (NavigationRequest request) {
               Toasts.mostrarToast("Login");
             }
          )
       )
    );
  }
}