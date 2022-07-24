import 'dart:async';

import 'package:animeschedule/core/Globals.dart';
import 'package:animeschedule/service-impl/MALService.dart';
import 'package:animeschedule/service-impl/SchedulerService.dart';
import 'package:animeschedule/service/ILocalStorageService.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/Properties.dart';
import '../service-impl/LocalStorageService.dart';
import 'MeusAnimesView.dart';

class LoginView extends StatefulWidget {

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool DEBUG_ACTIONS = true;

  MALService malService = MALService();

  String authorizationUrl;

  String redirectUrl;

  String responseUrl;

  ILocalStorageService localStorageService = LocalStorageService();

  final String TOKEN = '''
{
    "token_type": "Bearer",
    "expires_in": 2678400,
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjA1NTZkMTA4N2VjNTVhMDU0ZmZmZDRjMzM0NjliMmJhMzQ3M2UzNTBhMjZiNzkyZmY4MDVkODhkMGE1NmE1YmU3NzQ2OGQyOTNiY2I2MDJjIn0.eyJhdWQiOiIzZjIzNjJjM2I0NTEzNTE5MDE1ODNjNDE4MmE5Nzk0NSIsImp0aSI6IjA1NTZkMTA4N2VjNTVhMDU0ZmZmZDRjMzM0NjliMmJhMzQ3M2UzNTBhMjZiNzkyZmY4MDVkODhkMGE1NmE1YmU3NzQ2OGQyOTNiY2I2MDJjIiwiaWF0IjoxNjU3MDc1MDc0LCJuYmYiOjE2NTcwNzUwNzQsImV4cCI6MTY1OTc1MzQ3NCwic3ViIjoiMTE3OTk1MyIsInNjb3BlcyI6W119.BirzOQy3hEClwDc0pYY_Ba4CVBz-5EjnANOUe_bc404GBzZ070wgm8-MYsv8ole8fVPVCsKYT8swWVPUJWvlwZUI6sCsNu9OCewRDM6vaWxOE8QpJUkUXSb0cTsq81lxpsrvgFZHH-Zask3K_c_BY3N5V06pmIqPl4WEHJwwhsmT-mtv5pxV5tHZmXLYEDAvzzYU0A0WT73mFAUOj55egxzOTEwiF5BUtl_V3U2cJ2Uxl9JrbIAuQufOTOaebOo5xwQ9TAz7FJDsmCW9rYAiZyW_KM2HVyaOCRc7ygHM3fqhqJhLutAoXZ27mXPzHtHWcecQwWt16V3Ne54goLQzcw",
    "refresh_token": "def5020085a3fd39ab05ce4d0257260a6749983cf42955b395ae67d37543b55aa590007084f49ebd49154d45d18cb6b653a76d224231af74cba1f4cc6be9cdf8dd4b66dc525acdf33d448ec188c376b34cd6462b02d0102c3a1e63f0e6bacce136bb9f43ab2593a85a9447416ad17e220059357f4ca0b0249415113e513d48338cfd8b8ac6e0bcf847a0b4a22aca12a78459adcb10b6f17490c891cb934ece5c3a6ea0a68520d4ff7561cf5d13a27fed31ff343a7e87ec6e2867a0028386f47bfac2f126b99aa44580c0b3f965468a688cfbb78a6a1b263f4ea3adfe26978d2be7975def51c62212778e2e297bd886925c3abd5ca64675fd3600d8b2543b394576328740035bd5294ecbd393cad90aea6a3ad518ab924ec7b952234ac6777f9b1505e1b6ed69c4147d8f2e175786003afecff4e78a33be49d93756173b623c754f3d22f8b9e9a4c28223482110f6a2151977be9675ef718595951d52f831057aac24b141a0fe605dae98fa0106e6987bc54af6c11a58418c2f96da9ece103f6e058bf91c5cdcf745"
}
''';

  void debugActions(){
    if(DEBUG_ACTIONS){
      localStorageService.printStorage();
      SchedulerService schedulerService = SchedulerService();
      DateTime now = DateTime.now();
      int hour = now.hour;
      int minutes = now.minute + 1;
      String timeOfDay ="${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
      schedulerService.scheduleFixedTimeOfDay(timeOfDay, now);
    }
  }

  //Fazer uma tela de splash pra carregar umas coisinhas antes de entrar na tela MeusAnimesView
  @override
  Future<void> initState() {
    //localStorageService.saveToken(TOKEN);
    authorizationUrl = malService.getAuthorizationPage();
    debugActions();
    localStorageService.getToken().then((token) async {
      if(token != null){
        print("Token not null");
        GlobalVar().token = token;
        await localStorageService.getUser().then((user) async {
           GlobalVar().user = user;
        });
        Navigator.pushReplacement(context,
          MaterialPageRoute(
          builder: (context) => MeusAnimesView()));
        
      }else{
        print(authorizationUrl);
      }
    });

    super.initState();
  }



  Future<String> handleAuthorizationCodeUrl(String url) async {
    print("handleAuthorizationCodeUrl");
    String code = url.split("code=")[1].split("&state")[0];
    String tokenJson = await malService.generateToken(code);
    String token = await localStorageService.saveToken(tokenJson);
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),

      body: Container(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: authorizationUrl,
          navigationDelegate: (navReq) async {
            if (navReq.url.startsWith("http://localhost/oauth")) {
              String token = await handleAuthorizationCodeUrl(navReq.url);
              await malService.getUserData(token).then((response) {
                print("getUserData");
                if(!response.isError){
                  GlobalVar().firstMalLogin = true;
                  GlobalVar().user = response.data;
                  localStorageService.saveUser(response.data);
                }
              });
              /*malService.getUserWatchingAnimeList(token).then((userAnimeList) {
                localStorageService.atualizarMarcacoes(userAnimeList);
              });*/
              print("First login ${GlobalVar().isFirstMalLogin}");
              Navigator.pushReplacementNamed(context, "/meusanimes");
              return NavigationDecision.prevent;
            }
            if (navReq.url.startsWith(Properties.URL_API_AUTENTICACAO)) {
              responseUrl = Uri.parse(navReq.url) as String;
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          // ------- 8< -------
        )
      )
    );
  }
}