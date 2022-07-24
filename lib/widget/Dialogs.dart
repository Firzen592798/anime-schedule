import 'package:animeschedule/core/Globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AcaoDialog { sim, nao }

TextEditingController usuarioController = new TextEditingController();

///Conjunto de métodos de geração de dialogs usados no app
class Dialogs {
  static Future<AcaoDialog> confirmDialog(
      BuildContext context, String title, String body) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(AcaoDialog.nao),
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(AcaoDialog.sim),
              child: const Text(
                'Sim',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return (action != null) ? action : AcaoDialog.nao;
  }

  static Future<bool> logoutDialog(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Aviso'),
            content: new Text('Deseja sair do aplicativo'),
            actions: <Widget>[
              new TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Não'),
              ),
              new TextButton(
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                //onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginView(true) ) ),
                child: new Text('Sim'),
              ),
            ],
          ),
        )) ??
        false;
  }

  static Future<String> mostrarDialogUsuarioMal(BuildContext context) async {
    String resultado;
    usuarioController.text = GlobalVar().user.name;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Digite seu nome de usuário do MyAnimeList"),
          content: Container(
            height: 200.0,
            width: 200,
            child: Column(
              children: [
                TextField(
                  controller: usuarioController,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Digite o seu nome do usuário',
                      labelStyle: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: <Widget>[
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(""),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(usuarioController.text),
                  child: Text('Sim'),
                )
              ],
            )
          ],
        );
      },
    ).then((value) {
      resultado = value;
    });
    print(resultado);
    return resultado;
  }
}
