import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service/ApiService.dart';
import 'package:animeschedule/service/LocalService.dart';
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

  LocalService localService = LocalService();

  @override
  void initState() {
    super.initState();
    diaSelecionado = (DateTime.now().weekday - 1) % 7;
    _carregarAnimes();
  }

  _carregarAnimes() async{
    //GlobalVar().usuarioMAL = usuarioMAL;
    String usuarioMAL = "";

      ApiResponse response = await _apiService.listarAnimesPorDia(diaSelecionado);
      if(!response.isError){
        //Se tiver usuário do MAL logado, o código puxa a lista dos animes marcados como watching no mal
        if(usuarioMAL != ""){
          if(_listaAnimesUsuario == null){
            ApiResponse responseUsuario = await _apiService.listarAnimesUsuario(usuarioMAL);
            if(!responseUsuario.isError){
              _listaAnimesUsuario = responseUsuario.data;
            }
          }
          List<Anime> listaAnimesDia = response.data;
          _listaAnimes = [];
          for(int j = 0; j < listaAnimesDia.length; j++){
            Anime animeDia = listaAnimesDia[j];
            for(int i = 0; i < _listaAnimesUsuario.length; i++){
              if(_listaAnimesUsuario[i].id == animeDia.id){               
                _listaAnimes.add(animeDia);
                _listaAnimes.last.episodiosAssistidos = _listaAnimesUsuario[i].episodiosAssistidos;
              }
            }
          }
        }else{ //se não tiver usuário logado, puxa os animes do local storage que foram marcados como assistindo.
          _listaAnimes = response.data;
          //Anime animeLocal;
           List<int> listaAnimeLocal = await localService.getAnimes();
          _listaAnimes.where((element) => element.id > 0).forEach((element) {
            if(listaAnimeLocal.contains(element.id)){
              element.marcado = true;
            }
          });
         
        }
        setState(() {});
      }

  }

  _marcar(index){
    _listaAnimes[index].marcado = true;
    localService.adicionarMarcacaoAnime(_listaAnimes[index].id);
  }

  _desmarcar(index){
    _listaAnimes[index].marcado = false;
    localService.removerMarcacaoAnime(_listaAnimes[index].id);
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children:  <Widget>[
              !_listaAnimes[index].marcado ? 
              IconButton(
                icon: const Icon(Icons.star_outline),
                tooltip: 'Marcar como Assistindo',
                onPressed: () {
                  setState(() {
                    _marcar(index);
                  });
                },
              ) : 
              IconButton(
                icon: const Icon(Icons.star),
                tooltip: 'Remover marcação',
                onPressed: () {
                  setState(() {
                    _desmarcar(index);
                  });
                },
              )
            ],
          ),
          title: Text(_listaAnimes[index].titulo),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  <Widget>[
              Text("Último Assistido: ${_listaAnimes[index].episodiosAssistidos == null ? "-" : _listaAnimes[index].episodiosAssistidos}"),
              Text(_listaAnimes[index].diaSemana),
              
              /*Row(
                children: [
                  Text(_listaAnimes[index].diaSemana),
                  //_listaAnimes[index].episodios.toString() != null ? Text("Episódios: "+_listaAnimes[index].episodios.toString()) : Text("Episódios: Não especificado"),
                ],
              ),*/
              ],
            ),
            
          
          leading: CircleAvatar(backgroundImage: NetworkImage(_listaAnimes[index].urlImagem)),
        )

    );
  }
}

