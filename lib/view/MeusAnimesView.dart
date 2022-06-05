import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service/JikanApiService.dart';
import 'package:animeschedule/service/LocalDataService.dart';
import 'package:animeschedule/service/NotificationService.dart';
import 'package:animeschedule/util/ApiResponse.dart';
import 'package:animeschedule/widget/MenuLateral.dart';
import 'package:flutter/material.dart';

class MeusAnimesView extends StatefulWidget {
  @override
  _MeusAnimesViewState createState() => _MeusAnimesViewState();
}

class _MeusAnimesViewState extends State<MeusAnimesView> {

  List<Anime> _listaAnimes = [];
  List<Anime> _listaAnimesUsuario;
  ApiService _apiService = ApiService();

  int selectedDay = 0;

  bool showOnlyMarkedAnimes = false;

  List<String> listaDias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

  LocalService localService = LocalService();

  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    notificationService.showNotification();
    selectedDay = (DateTime.now().weekday - 1) % 7;
    _carregarAnimes();
  }

  _carregarAnimes() async{
    //GlobalVar().usuarioMAL = usuarioMAL;
    String usuarioMAL = "";

      ApiResponse response = await _apiService.listarAnimesPorDia(selectedDay);
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
      ),
      drawer: MenuLateral(context),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              border: Border.all(
                color: Colors.blueGrey,
                width: 1,
              )
            ),
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  items: listaDias.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(
                        value,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  value: listaDias[selectedDay],
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (newVal) {
                    this.setState(() {
                      selectedDay = listaDias.indexOf(newVal);
                      _carregarAnimes();
                    });
                  },
                ),
                Spacer(),
                Text(
                  "Mostrar somente animes marcados"
                ),
                Switch(
                  value: showOnlyMarkedAnimes,
                  onChanged: (value) {
                    setState(() {
                      showOnlyMarkedAnimes = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height-130,
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
      final isMarked = _listaAnimes[index].marcado;
      if(isMarked || !showOnlyMarkedAnimes){
        return  Container(
          child: ListTile(
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children:  <Widget>[
                IconButton(
                  icon: !isMarked ? const Icon(Icons.star_outline) :  const Icon(Icons.star),
                  tooltip: !isMarked ? 'Marcar como Assistindo' : 'Remover marcação',
                  onPressed: () {
                    setState(() {
                      if(!isMarked){
                        _marcar(index);
                      }else{
                        _desmarcar(index);
                      }
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
                Text(_listaAnimes[index].broadcastTime),
                ],
              ),
              
            
            leading: CircleAvatar(backgroundImage: NetworkImage(_listaAnimes[index].urlImagem)),
          )

        );
    }else{
      return SizedBox.shrink();
    }
  }
}

