import 'package:animeschedule/util/GlobalVar.dart';
import 'package:animeschedule/widget/Dialogs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuLateral extends StatefulWidget {
  @override
  _MenuLateralState createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  TextEditingController usuarioController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            padding: EdgeInsets.all(8),
            child: Row(children: <Widget>[
              SizedBox(width: 16),
              Flexible(
                  child: Text('Header',
               
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ))
            ]),
          ),
          ListTile(
            title: Text('Usuário do myanimelist'),
            onTap: () {
              Dialogs.setarUsuarioMAL(context).then((response) {
                GlobalVar().usuarioMAL = response;
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('usuarioMAL', response);
                });
              });
              Navigator.pop(context);
              //Navigator.push(context);
                  //MaterialPageRoute(builder: (context) => InformacoesView()));
            },
          ),
          ListTile(
            title: Text('Sair'),
            onTap: () {
              /*SharedPreferences.getInstance().then((prefs) {
                prefs.remove('refreshToken');
                GlobalVar().tokenSinfo = null;
              });*/
            },
          ),
        ],
      ),
    );
  }
}