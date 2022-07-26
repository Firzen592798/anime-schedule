import 'package:animeschedule/service-impl/LocalStorageService.dart';
import 'package:animeschedule/view/LoginView.dart';
import 'package:animeschedule/view/MeusAnimesView.dart';
import 'package:animeschedule/view/PreferenciasView.dart';
import 'package:flutter/material.dart';

import '../core/Globals.dart';
import '../domain/User.dart';

class MenuLateral extends StatefulWidget {
  final dynamic contextTelaPrincipal;
  MenuLateral(this.contextTelaPrincipal);

  @override
  _MenuLateralState createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  TextEditingController usuarioController = TextEditingController();

  String url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfeBf-Hc33XkfWZdbRpvxHYgbKaW9Gogn7qA&usqp=CAU";

  @override
  Widget build(BuildContext context) {
    User user = GlobalVar().user;
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            padding: EdgeInsets.all(8),
            child: Row(children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: user?.picture == null ? NetworkImage(url) : NetworkImage(user?.picture),
              ),
              SizedBox(width: 16),
              Flexible(
                  child: Text(
                user?.name == null ? 'Header' : user.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ))
            ]),
          ),
          /*ListTile(
            title: Text('Autorizar MyAnimeList'),
            onTap: () async{
              Navigator.pop(context);
              Navigator.push(context,MaterialPageRoute(builder: (context) => LoginView()));
            },
          ),*/
          ListTile(
            title: Text('Preferências'),
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PreferenciasView()));
            },
          ),
          if(!GlobalVar().isLoggedIn) ListTile(
            title: Text('Entrar no MyAnimeList'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                MaterialPageRoute(
                  builder: (context) => LoginView()));
            },
          ),
          if(GlobalVar().isLoggedIn) ListTile(
            title: Text('Deslogar'),
            onTap: () async {
              Navigator.pop(context);
              await LocalStorageService().deslogar();
              Navigator.pushReplacementNamed(context,'/meusanimes',arguments: {
                'restart': true,
              });
            },
          ),
          ListTile(
            title: Text('Sair do app'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
