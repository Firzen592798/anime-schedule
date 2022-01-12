import 'package:animeschedule/util/GlobalVar.dart';
import 'package:animeschedule/view/PreferenciasView.dart';
import 'package:animeschedule/widget/Dialogs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                backgroundImage:url == null
                    ? null
                    : NetworkImage(url),
              ),
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
            title: Text('Preferências'),
            onTap: () async{
              Navigator.pop(context);
              Navigator.push(context,MaterialPageRoute(builder: (context) => PreferenciasView()));
            },
          ),
          ListTile(
            title: Text('Sair'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
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