import 'package:animeschedule/core/CustomColors.dart';
import 'package:animeschedule/model/AnimeApi.dart';
import 'package:animeschedule/service-impl/JikanApiService.dart';
import 'package:animeschedule/service/IAnimeApiService.dart';
import 'package:animeschedule/service/ILocalStorageService.dart';
import 'package:animeschedule/widget/MenuLateral.dart';
import 'package:flutter/material.dart';

import '../domain/AnimeLocal.dart';
import '../service-impl/LocalStorageService.dart';

class DetalheAnimeView extends StatefulWidget {

  final AnimeLocal anime;

  const DetalheAnimeView({Key key, AnimeLocal this.anime}) : super(key: key);

  @override
  State<DetalheAnimeView> createState() => _DetalheAnimeViewState();
}

class _DetalheAnimeViewState extends State<DetalheAnimeView> {

  IAnimeAPiService jikanApiService = JikanApiService();

  ILocalStorageService localService = LocalStorageService();

  AnimeLocal anime;

  bool isChanged = false;

  bool isLoading = true;

  @override
  Future<void> initState() {
    anime = widget.anime;
    jikanApiService.loadAnimeDetails(widget.anime.id).then((value) {
      setState(() {
        isLoading = false;
         anime.animeDetails = value;
      });
     
    });
    super.initState();
  }

  voltar(){
    Navigator.pop(context, isChanged);
  }

  _marcar(){
    isChanged = !isChanged;
    anime.marcado = true;
    localService.adicionarMarcacaoAnime(anime);
  }

  _desmarcar(){
    isChanged = !isChanged;
    anime.marcado = false;
    localService.removerMarcacaoAnime(anime.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do anime"),
      ),
      drawer: MenuLateral(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(
                anime.titulo,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5,
                  fontSize: 20,
                ),
              ),
              trailing: IconButton(
                  icon: !anime.marcado ? const Icon(Icons.star_outline) :  const Icon(Icons.star),
                  tooltip: !anime.marcado ? 'Marcar como Assistindo' : 'Remover marcação',
                  onPressed: () {
                    setState(() {
                      if(!anime.marcado){
                        _marcar();
                      }else{
                        _desmarcar();
                      }
                    });
                  },
                ),
            ),
            SizedBox(
              //alignment: Alignment.center,
              width: double.infinity,
              
              height: 300,
              child:  Image(
                image: NetworkImage(anime.urlImagem),
              ) 
            ),
            
            ListTile(
              leading: Icon(Icons.access_alarm_outlined),
              title: Text(
                "Transmissão nas ${anime.correctBroadcastDay} às ${anime.correctBroadcastTime}"
              ),
            ),
            
            !isLoading ? Column(
              children: [
                anime.animeDetails != null ? ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(
                    anime?.animeDetails?.synopsis,
                    textAlign: TextAlign.justify,
                  ),
                ) :SizedBox.shrink() ,
                anime.animeDetails != null ? ListTile(
                  leading: Icon(Icons.extension_outlined),
                  title: Text(
                    "Gêneros: "+anime.animeDetails.genres.join(", ")
                  ),
                ) : SizedBox.shrink(),
                anime.animeDetails != null ? ListTile(
                  leading: Icon(Icons.business_outlined),
                  title: Text(
                    "Estúdios: "+anime.animeDetails.studios.join(", ")
                  ),
                ) : SizedBox.shrink(),

                anime.animeDetails != null ? ListTile(
                  leading: Icon(Icons.music_video_outlined),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Aberturas"),
                      Text(
                        anime.animeDetails.openings.join("\n"),
                        style: TextStyle(
                          height: 1.7,
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ) : SizedBox.shrink(),

                anime.animeDetails != null ? ListTile(
                  leading: Icon(Icons.music_note_outlined),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Encerramentos"),
                      Text(
                        anime.animeDetails.endings.join("\n"),
                        style: TextStyle(
                          height: 1.7,
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ) : SizedBox.shrink(),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(onPressed: voltar, 
                    child: Text("Voltar")
                  ),
                )
              ],
            ):Container(
              child: Column(children: [
                Container(
                  color: CustomColors.skeletonColor,
                  width: double.infinity,
                  height: 20,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25)
                ),
                Container(
                  color: CustomColors.skeletonColor,
                  width: double.infinity,
                  height: 20,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25)
                ),
                Container(
                  color: CustomColors.skeletonColor,
                  width: double.infinity,
                  height: 20,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25)
                ),
                Container(
                  color: CustomColors.skeletonColor,
                  width: double.infinity,
                  height: 80,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25)
                )
                
              ]),
            )
          ]
      
        ),
      )
    );
  }
}