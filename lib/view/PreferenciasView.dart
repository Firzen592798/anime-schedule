import 'package:animeschedule/model/ConfigPrefs.dart';
import 'package:animeschedule/service/LocalService.dart';
import 'package:animeschedule/util/GlobalVar.dart';
import 'package:animeschedule/util/Toasts.dart';
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
    LocalService().getConfigPrefs().then((configPrefs) => {
      setState(() {
        this.opcaoSelecionada = configPrefs.opcaoNotificacao;
        this.usuarioController.text = configPrefs.usuarioMAL;
      })
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
                  ConfigPrefs configPrefs = ConfigPrefs();
                  configPrefs.usuarioMAL = usuarioController.text;
                  configPrefs.opcaoNotificacao = opcaoSelecionada;
                  LocalService().salvarPrefs(configPrefs);
                  GlobalVar().usuarioMAL = configPrefs.usuarioMAL;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MeusAnimesView()));
                  Toasts.mostrarToast("Preferências atualizadas com sucesso");
                }, 
                child: Text("Salvar")
              )
            ],
          ),
        )
        
    );
  }
}