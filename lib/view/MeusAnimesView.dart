import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service/JikanApiService.dart';
import 'package:animeschedule/service/LocalStorageService.dart';
import 'package:animeschedule/service/NotificationService.dart';
import 'package:animeschedule/util/ApiResponse.dart';
import 'package:animeschedule/view/DetalheAnimeView.dart';
import 'package:animeschedule/widget/MenuLateral.dart';
import 'package:flutter/material.dart';

import '../widget/AnimeListItem.dart';

class MeusAnimesView extends StatefulWidget {
  @override
  _MeusAnimesViewState createState() => _MeusAnimesViewState();
}

class _MeusAnimesViewState extends State<MeusAnimesView> {

  List<Anime> _listaAnimes = [];
  List<Anime> _listaAnimesUsuario;
  JikanApiService _apiService = JikanApiService();

  int selectedDay = 0;

  bool showOnlyMarkedAnimes = false;

  List<String> listaDias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

  LocalStorageService localService = LocalStorageService();

  NotificationService notificationService = NotificationService();

  @override
  initState() {
    super.initState();
    selectedDay = (DateTime.now().weekday - 1) % 7;
    _carregarAnimes();
  }

  _carregarAnimes() async{
    //GlobalVar().usuarioMAL = usuarioMAL;
    String usuarioMAL = "";

      List<Anime> dailyAnimeList = await _apiService.findAllByDay(selectedDay);
        //Se tiver usuário do MAL logado, o código puxa a lista dos animes marcados como watching no mal
        if(usuarioMAL != ""){
          if(_listaAnimesUsuario == null){
            ApiResponse responseUsuario = await _apiService.listarAnimesUsuario(usuarioMAL);
            if(!responseUsuario.isError){
              _listaAnimesUsuario = responseUsuario.data;
            }
          }
          _listaAnimes = [];
          
          for(int j = 0; j < dailyAnimeList.length; j++){
            Anime animeDia = dailyAnimeList[j];
            
            for(int i = 0; i < _listaAnimesUsuario.length; i++){
              if(_listaAnimesUsuario[i].id == animeDia.id){               
                _listaAnimes.add(animeDia);
                _listaAnimes.last.episodiosAssistidos = _listaAnimesUsuario[i].episodiosAssistidos;
              }
            }
          }
        }else{ //se não tiver usuário logado, puxa os animes do local storage que foram marcados como assistindo.
          List<Anime> favoriteAnimeList = await localService.getMarkedAnimes();
          dailyAnimeList.where((element) => element.id > 0).forEach((element) {
            if(favoriteAnimeList.contains(element)){
              element.marcado = true;
            }
          });
          setState(() {
            _listaAnimes = dailyAnimeList;
          });
        }
  }

  _marcar(Anime anime){
    localService.adicionarMarcacaoAnime(anime);
  }

  _desmarcar(Anime anime){
    localService.removerMarcacaoAnime(anime.id);
  }

  _showDetailsPage(index){
    print("showDetailsPage ${_listaAnimes[index].titulo}");
    //Navigator.push(context,  MaterialPageRoute(builder: (context) => DetalheAnimeView(anime: _listaAnimes[index])));
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
              itemBuilder: (BuildContext context, int index) {
                return (_listaAnimes[index].marcado || !showOnlyMarkedAnimes) ? GestureDetector(
                  onTap: _showDetailsPage(index),
                  child: AnimeListItem(
                    index: index,
                    anime: _listaAnimes[index],
                    desmarcarAnime: _desmarcar,
                    marcarAnime: _marcar,
                  ),
                ): SizedBox.shrink();
              },
              separatorBuilder: (context, index) {
                return Divider(
                  indent: 0,
                  height: 0,
                );
              },
            ),
          ),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: Container(
              alignment: Alignment.center,
              color: Colors.amber,
              child: Text("Desenvolvido por Firzen592798")
            )
          )
        ],
      ),
    );
  }

  

  Widget criarItem(context, index){
      final isMarked = _listaAnimes[index].marcado;
      if(isMarked || !showOnlyMarkedAnimes){
        return  SizedBox(
          height: 100,
          width: double.infinity,
          child: ListTile(
            dense:true,            
            onTap: () => _showDetailsPage(index),
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
                Text(_listaAnimes[index].correctBroadcastTime),
                Text("EncheLinguica"),
                Text("EncheLinguica"),
                Text("EncheLinguica"),
                ],
              ),
              
            
            // leading: FittedBox(
            //   fit: BoxFit.fill,
            //   child: CircleAvatar(
            //     radius: 100,
            //     backgroundColor: Colors.amber,
            //   ),
            // ),
            
            leading: Image(
              alignment: Alignment.center,
              height: 200,
              width: 200,
              fit: BoxFit.fill,
              image: NetworkImage(_listaAnimes[index].urlImagem)
            ),
            
            
            
          )

        );
    }else{
      return SizedBox.shrink();
    }
  }
}

