import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service/JikanApiService.dart';
import 'package:animeschedule/themes/AppTheme.dart';
import 'package:animeschedule/widget/MenuLateral.dart';
import 'package:flutter/material.dart';

import '../service/LocalStorageService.dart';

class DetalheAnimeView extends StatefulWidget {

  final Anime anime;

  const DetalheAnimeView({Key key, Anime this.anime}) : super(key: key);

  @override
  State<DetalheAnimeView> createState() => _DetalheAnimeViewState();
}

class _DetalheAnimeViewState extends State<DetalheAnimeView> {

  JikanApiService jikanApiService = JikanApiService();

  LocalStorageService localService = LocalStorageService();

  Anime anime;

  @override
  Future<void> initState() {
    anime = widget.anime;
    
    jikanApiService.loadAnimeDetails(anime).then((value) {
      setState(() {
         anime = value;
         print("sinopse ${anime.animeDetails.synopsis}");
      });
     
    });
    super.initState();
  }

  voltar(){
    Navigator.pop(context);
  }

  _marcar(){
    anime.marcado = true;
    localService.adicionarMarcacaoAnime(anime);
  }

  _desmarcar(){
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
              child: anime.animeDetails != null ? Image(
                image: NetworkImage(anime.urlImagem),
              ) : SizedBox.shrink(),
            ),
            
            1 == 1 ? SizedBox.shrink(): ListTile(
              leading: Icon(Icons.tv_outlined),
              title: Text(
                "Número de episódios: "+ anime.episodios.toString()
              ),
            ),

            ListTile(
              leading: Icon(Icons.access_alarm_outlined),
              title: Text(
                "Transmissão nas ${anime.correctBroadcastDay} às ${anime.correctBroadcastTime}"
              ),
            ),
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
          ]
      
        ),
      )
    );
  }
}