import 'package:animeschedule/core/Toasts.dart';
import 'package:animeschedule/domain/ConfigPrefs.dart';
import 'package:animeschedule/service-impl/LocalStorageService.dart';
import 'package:animeschedule/service-impl/SchedulerService.dart';
import 'package:animeschedule/view/MeusAnimesView.dart';
import 'package:flutter/material.dart';

import '../core/Globals.dart';

class PreferenciasView extends StatefulWidget {
  @override
  _PreferenciasViewState createState() => _PreferenciasViewState();
}

class _PreferenciasViewState extends State<PreferenciasView> {
  TextEditingController usuarioController = new TextEditingController();
  List<String> opcoesNotificacao = [
    'Desabilitar todas',
    'Todos os dias'
  ];
  //List<String> opcoesNotificacao = ['Desabilitar todas', 'Horário fixo', 'Ao sair o episódio'];
  int opcaoSelecionada = 0;

  static const int DESABILITAR_TODAS = 0;

  static const int NOTIFICACAO_DIARIA = 1;

  static const int NOTIFICACAO_POR_EPISODIO = 2;

  static const double CONTAINER_HEIGHT = 70;

  String dropdownNotificationTimeValue;
  String dropdownTimeAfterEpisodeValue;
  List<String> dropdownNotificationTimeListItems =
      new List<String>.generate(24, (index) => "$index:00");
  List<String> dropdownTimeAfterEpisodeListItems = [
    "0",
    "30",
    "60",
    "90",
    "180"
  ];
  @override
  void initState() {
    LocalStorageService().getConfigPrefs().then((configPrefs) => {
          setState(() {
            this.opcaoSelecionada = configPrefs.opcaoNotificacao;
            if (this.opcaoSelecionada > DESABILITAR_TODAS) {
              dropdownNotificationTimeValue = configPrefs.horarioNotificacao ?? "0:00";
              dropdownTimeAfterEpisodeValue =
                  configPrefs.tempoAposOEpisodioParaDispararNotificacao;
            }
          })
        });
    super.initState();
  }

  Widget switchDropdownNotificationTime() {
    switch (opcaoSelecionada) {
      case NOTIFICACAO_DIARIA:
        return createDropdownNotificationTime(
            dropdownNotificationTimeListItems);
        break;
      case NOTIFICACAO_POR_EPISODIO:
        return createDropdownNotificationTime(
            dropdownTimeAfterEpisodeListItems);
        break;
      default:
        return SizedBox.shrink();
    }
  }

  Widget createDropdownNotificationTime(List<String> dropdownItems) {
    return DropdownButton<String>(

      value: opcaoSelecionada == NOTIFICACAO_DIARIA
          ? dropdownNotificationTimeValue
          : dropdownTimeAfterEpisodeValue,
      onChanged: (String newValue) {
        setState(() {
          print(newValue);
          if (opcaoSelecionada == NOTIFICACAO_DIARIA) {
            dropdownNotificationTimeValue = newValue;
          } else {
            dropdownTimeAfterEpisodeValue = newValue;
          }
        });
      },
      items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
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
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: CONTAINER_HEIGHT,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Usuário do MAL"),
                    
                    SizedBox(
                      width: 120,
                      height: 30,
                      child: Text(
                        GlobalVar().user?.name ?? "Não logado"
                      ),
                    ),
                  ]
                )
              ),
                

              Divider(
                indent: 0,
                height: 0,
              ),  
              Container(
                height: CONTAINER_HEIGHT,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Notificações de episódios"),
                    DropdownButton<String>(
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
                  
                  ]
                )
              ),
              Divider(
                indent: 0,
                height: 0,
              ),  
              Container(
                height: CONTAINER_HEIGHT,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text("Horário da notificação: "),
                  switchDropdownNotificationTime(),
                ],)
              ),
              Divider(
                indent: 0,
                height: 0,
              ),  
              Container(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                    onPressed: () {
                      ConfigPrefs configPrefs = ConfigPrefs();
                      configPrefs.opcaoNotificacao = opcaoSelecionada;
                      configPrefs.tempoAposOEpisodioParaDispararNotificacao =
                          dropdownTimeAfterEpisodeValue;
                      configPrefs.horarioNotificacao =
                          dropdownNotificationTimeValue;
                      LocalStorageService().salvarPrefs(configPrefs);
                      if (configPrefs.opcaoNotificacao == NOTIFICACAO_DIARIA) {
                        SchedulerService().scheduleFixedTimeOfDay(configPrefs.horarioNotificacao);
                      } else {
                        SchedulerService().cancelAll();
                      }
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MeusAnimesView()));
                      Toasts.mostrarToast("Preferências atualizadas com sucesso");
                    },
                    child: Text("Salvar")),
              )
            ],
          ),
        ));
  }
}
