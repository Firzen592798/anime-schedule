import 'package:animeschedule/core/ApiResponse.dart';
import 'package:animeschedule/core/Globals.dart';
import 'package:animeschedule/core/Toasts.dart';
import 'package:animeschedule/service-impl/JikanApiService.dart';
import 'package:animeschedule/service-impl/LocalStorageService.dart';
import 'package:animeschedule/service-impl/MALService.dart';
import 'package:animeschedule/service-impl/NotificationService.dart';
import 'package:animeschedule/service/IAnimeApiService.dart';
import 'package:animeschedule/service/ILocalStorageService.dart';
import 'package:animeschedule/widget/MenuLateral.dart';
import 'package:flutter/material.dart';

import '../core/Consts.dart';
import '../domain/AnimeLocal.dart';
import '../widget/AnimeListItem.dart';
import 'DetalheAnimeView.dart';

class MeusAnimesView extends StatefulWidget {
  @override
  _MeusAnimesViewState createState() => _MeusAnimesViewState();
}

class _MeusAnimesViewState extends State<MeusAnimesView> {

  List<AnimeLocal> _listaAnimes = [];
  IAnimeAPiService _apiService = JikanApiService();
  MALService _malService = MALService();

  int selectedDay = 0;

  bool showOnlyMarkedAnimes = false;

  ILocalStorageService localService = LocalStorageService();

  NotificationService notificationService = NotificationService();

  @override
  initState() {
    
    super.initState();
    selectedDay = (DateTime.now().weekday - 1) % 7;
    _carregarAnimes();
  }

  _carregarAnimes() async{
    print("carregarAnimes");
    if(GlobalVar().isFirstMalLogin == true){
      print("FirstMalLogin");
      GlobalVar().firstMalLogin = false;
      await syncWithMyAnimeList();
    }else{
      List<AnimeLocal> dailyAnimeList = await _apiService.findAllByDay(selectedDay);
      List<AnimeLocal> favoriteAnimeList = await localService.getMarkedAnimes();
      syncAnimeMarks(dailyAnimeList, favoriteAnimeList);
      setState(() {
        _listaAnimes = dailyAnimeList;
      });
    }
  }

  syncWithMyAnimeList(){
    List<AnimeLocal> animesMarcadosMAL = [];
    _apiService.findAll().then((animeLocalList) {
      _malService.getUserWatchingAnimeList(GlobalVar().token).then((favoriteAnimeList) async {
        animeLocalList.where((element) => element.id > 0).forEach((element) {
          if(favoriteAnimeList.any((favorite) => favorite.id == element.id)){
            element.marcado = true;
            animesMarcadosMAL.add(element);
          }
        });
        List<AnimeLocal> dailyAnimeList = await _apiService.findAllByDay(selectedDay);
        syncAnimeMarks(dailyAnimeList, animesMarcadosMAL);
        localService.atualizarMarcacoes(animesMarcadosMAL);
        setState(() {
          _listaAnimes = dailyAnimeList;
        });
      });
    });
  }

  syncAnimeMarks(List<AnimeLocal>  dailyAnimeList, List<AnimeLocal> favoriteAnimeList){
    dailyAnimeList.where((element) => element.id > 0).forEach((element) {
      if(favoriteAnimeList.any((favorite) => favorite.id == element.id)){
        element.marcado = true;
      }
    });
  }

  //Como raios eu vou sincronizar os animes locais de modo a setar a data e hora de broadcast de cada um?
  _updateFavoriteAnimes() async {
    syncWithMyAnimeList();
    // List<AnimeLocal> userAnimeList = await _malService.getUserWatchingAnimeList(GlobalVar().token);
    // localService.atualizarMarcacoes(userAnimeList);
    // syncAnimeMarks(_listaAnimes, userAnimeList);
    Toasts.mostrarToast("Animes sincronizados com sucesso");
  }

  _marcar(AnimeLocal anime){
    localService.adicionarMarcacaoAnime(anime);
  }

  _desmarcar(AnimeLocal anime){
    localService.removerMarcacaoAnime(anime.id);
  }

  _showDetailsPage(index) async {
    print("showDetailsPage ${_listaAnimes[index].titulo}");
    bool isChanged = await Navigator.push(context,  MaterialPageRoute(builder: (context) => DetalheAnimeView(anime: _listaAnimes[index])));
    if(isChanged){
      setState(() {

      });
    }
  }


  @override
  Widget build(BuildContext context) {
    print("Build");
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de animes"),
        actions: [
           Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: _updateFavoriteAnimes,
              child: Icon(
                Icons.refresh,
                size: 26.0,
              ),
            )
          ),
        ],
      ),
      drawer: MenuLateral(context),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.teal[100],
              border: Border.all(
                color: Colors.black,
                width: 1,
              )
            ),
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DropdownButton<String>(
                    underline: SizedBox.shrink(),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    items: Consts.listaDias.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(
                          value,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      );
                    }).toList(),
                    value: Consts.listaDias[selectedDay],
                    onChanged: (newVal) {
                      this.setState(() {
                        selectedDay = Consts.listaDias.indexOf(newVal);
                        _carregarAnimes();
                      });
                    },
                  ),
                Spacer(),
                Text(
                  "Apenas favoritos"
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
            child: ListView.builder(
              itemCount: _listaAnimes.length,
              itemBuilder: (BuildContext context, int index) {
                return (_listaAnimes[index].marcado || !showOnlyMarkedAnimes) ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showDetailsPage(index),
                  child: AnimeListItem(
                    index: index,
                    anime: _listaAnimes[index],
                    desmarcarAnime: _desmarcar,
                    marcarAnime: _marcar,
                  ),
                ): SizedBox.shrink();
              },

            ),
          ),
        ],
      ),
    );
  }
}

