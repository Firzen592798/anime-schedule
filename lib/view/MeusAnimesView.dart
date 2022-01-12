import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service/ApiService.dart';
import 'package:animeschedule/util/ApiResponse.dart';
import 'package:animeschedule/util/GlobalVar.dart';
import 'package:animeschedule/widget/MenuLateral.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeusAnimesView extends StatefulWidget {
  @override
  _MeusAnimesViewState createState() => _MeusAnimesViewState();
}

class _MeusAnimesViewState extends State<MeusAnimesView> {

  List<Anime> _listaAnimes = [];
  List<Anime> _listaAnimesUsuario;
  ApiService _apiService = ApiService();

  int diaSelecionado = 0;

  List<String> listaDias = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];

  @override
  void initState() {
    super.initState();
    diaSelecionado = (DateTime.now().weekday - 1) % 7;
    _carregarAnimes();
  }

  _carregarAnimes() async{
    SharedPreferences.getInstance().then((prefs) async{
      String usuarioMAL = prefs.getString("usuarioMAL") ?? "";
      print("Usuario mal: "+usuarioMAL);
      GlobalVar().usuarioMAL = usuarioMAL;
      ApiResponse response = await _apiService.listarAnimesPorDia(diaSelecionado);
      if(!response.isError){
        if(usuarioMAL != ""){
          if(_listaAnimesUsuario == null){
            ApiResponse responseUsuario = await _apiService.listarAnimesUsuario(usuarioMAL);
            if(!responseUsuario.isError){
              _listaAnimesUsuario = responseUsuario.data;
            }
          }
          List<Anime> listaAnimesDia = response.data;
          _listaAnimes = [];
          
          //listaAnimesDia.forEach((animeDia) => {
          for(int j = 0; j < listaAnimesDia.length; j++){
            Anime animeDia = listaAnimesDia[j];
            for(int i = 0; i < _listaAnimesUsuario.length; i++){
              if(_listaAnimesUsuario[i].id == animeDia.id){               
                _listaAnimes.add(animeDia);
                _listaAnimes.last.episodiosAssistidos = _listaAnimesUsuario[i].episodiosAssistidos;
              }
            }
          }
        }else{
          _listaAnimes = response.data;
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Build");
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de animes"),
        actions: [
          Theme(
            child: DropdownButton<String>(
            items: listaDias.map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            value: listaDias[diaSelecionado],
            style: new TextStyle(
              color: Colors.white,
            ),
            onChanged: (newVal) {
              this.setState(() {
                diaSelecionado = listaDias.indexOf(newVal);
                _carregarAnimes();
              });
            },
          ),
          data: Theme.of(context).copyWith(
            canvasColor: Colors.blue.shade200,
          )
          )
        ],
      ),
      drawer: MenuLateral(context),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              itemCount: _listaAnimes.length,
              itemBuilder: criarItem,
              separatorBuilder: (context, index) {
                return Divider(
                  indent: 0,
                  height: 0,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  

  Widget criarItem(context, index){
    //final item = _listaTarefas[index]["titulo"];
    return  Container(
        child: ListTile(
          
          title: Text(_listaAnimes[index].titulo),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Último Assistido: ${_listaAnimes[index].episodiosAssistidos}"),
              Text(_listaAnimes[index].diaSemana),
              /*Row(
                children: [
                  Text(_listaAnimes[index].diaSemana),
                  //_listaAnimes[index].episodios.toString() != null ? Text("Episódios: "+_listaAnimes[index].episodios.toString()) : Text("Episódios: Não especificado"),
                ],
              ),*/
              ],
            ),
            
          
          leading: Image.network(_listaAnimes[index].urlImagem, fit: BoxFit.fitHeight,)
        )

    );
  }
}

