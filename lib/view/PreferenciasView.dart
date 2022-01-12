import 'package:animeschedule/util/GlobalVar.dart';
import 'package:animeschedule/view/MeusAnimesView.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasView extends StatefulWidget {
  @override
  _PreferenciasViewState createState() => _PreferenciasViewState();
}

class _PreferenciasViewState extends State<PreferenciasView> {

  TextEditingController usuarioController = new TextEditingController();
  List<String> opcoesNotificacao = ['Desabilitar todas', 'No início do dia', 'Quando sair o episódio'];
  int opcaoSelecionada = 1;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      print(prefs.getInt("opcaoNotificacao") ?? 1);
      setState(() {
        this.opcaoSelecionada = prefs.getInt("opcaoNotificacao") ?? 1;
        this.usuarioController.text = prefs.getString("usuarioMAL") ?? "";
      });

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preferências"),
      ),
      body: 
        Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Container(
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  controller: usuarioController,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Seu usuário do MyAnimeList',
                      labelStyle: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(height: 10,),
              Text("Prefências de notificação"),
              new DropdownButton<String>(
                items: opcoesNotificacao.map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                value: opcoesNotificacao[opcaoSelecionada],
                onChanged: (newVal) {
                  this.setState(() {
                    this.opcaoSelecionada = opcoesNotificacao.indexOf(newVal);
                    print("Trocou: ${opcaoSelecionada}");
                  });
                },
              ),
              ElevatedButton(
                onPressed: (){
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setString('usuarioMAL', usuarioController.text);
                    GlobalVar().usuarioMAL = usuarioController.text;
                    prefs.setInt('opcaoNotificacao', opcaoSelecionada);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MeusAnimesView()));
                    //print("Setou usuarioMAL: "+response);
                    Fluttertoast.showToast(
                        msg: "Preferências atualizadas com sucesso",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  });
                }, 
                child: Text("Salvar")
              )
            ],
          ),
        )
        
    );
  }
}