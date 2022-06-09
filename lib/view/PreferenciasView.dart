import 'package:animeschedule/model/ConfigPrefs.dart';
import 'package:animeschedule/service/LocalStorageService.dart';
import 'package:animeschedule/service/SchedulerService.dart';
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
  List<String> opcoesNotificacao = ['Desabilitar todas', 'Horário fixo', 'Ao sair o episódio'];
  int opcaoSelecionada = 0;

  String dropdownNotificationTimeValue;
  String dropdownTimeAfterEpisodeValue;
  List<String> dropdownNotificationTimeListItems = new List<String>.generate(24, (index) => "$index:00");
  List<String> dropdownTimeAfterEpisodeListItems = ["0", "30", "60", "90", "180"];
  @override
  void initState() {
    LocalStorageService().getConfigPrefs().then((configPrefs) => {
      setState(() {
        this.opcaoSelecionada = configPrefs.opcaoNotificacao;
        if(this.opcaoSelecionada > 0){
          dropdownNotificationTimeValue = configPrefs.horarioNotificacao;
          dropdownTimeAfterEpisodeValue = configPrefs.tempoAposOEpisodioParaDispararNotificacao;
        }
        this.usuarioController.text = configPrefs.usuarioMAL;
      })
    });
    super.initState();
  }

  Widget switchDropdownNotificationTime(){
    switch(opcaoSelecionada){       
      case 1: 
        return createDropdownNotificationTime(dropdownNotificationTimeListItems);
        break;
      case 2: 
        return createDropdownNotificationTime(dropdownTimeAfterEpisodeListItems);
        break;
      default: 
        return SizedBox.shrink();
    }
  }

  Widget createDropdownNotificationTime(List<String> dropdownItems){
    return DropdownButton<String>(
      value: opcaoSelecionada == 1 ? dropdownNotificationTimeValue : dropdownTimeAfterEpisodeValue,
      onChanged: (String newValue) {
        setState(() {
          print(newValue);
          if( opcaoSelecionada == 1){
            dropdownNotificationTimeValue = newValue;
          }else{
            dropdownTimeAfterEpisodeValue = newValue;
          }
         
        });
      },
      items: dropdownItems
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
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
                  });
                },
              ),
              switchDropdownNotificationTime(),
              ElevatedButton(
                onPressed: (){
                  ConfigPrefs configPrefs = ConfigPrefs();
                  configPrefs.usuarioMAL = usuarioController.text;
                  configPrefs.opcaoNotificacao = opcaoSelecionada;
                  configPrefs.tempoAposOEpisodioParaDispararNotificacao = dropdownTimeAfterEpisodeValue;
                  configPrefs.horarioNotificacao = dropdownNotificationTimeValue;
                  LocalStorageService().salvarPrefs(configPrefs);
                  if(configPrefs.opcaoNotificacao == 1){
                    SchedulerService().scheduleFixedTimeOfDay(configPrefs.horarioNotificacao);
                  }else{
                    SchedulerService().cancelAll();
                  }
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