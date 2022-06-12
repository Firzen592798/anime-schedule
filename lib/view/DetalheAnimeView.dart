import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service/JikanApiService.dart';
import 'package:animeschedule/widget/MenuLateral.dart';
import 'package:flutter/material.dart';

class DetalheAnimeView extends StatefulWidget {

  final Anime anime;

  const DetalheAnimeView({Key key, Anime this.anime}) : super(key: key);

  @override
  State<DetalheAnimeView> createState() => _DetalheAnimeViewState();
}

class _DetalheAnimeViewState extends State<DetalheAnimeView> {

  JikanApiService jikanApiService = JikanApiService();

  Anime anime;

  _carregarDetalhes() async {
    anime = await jikanApiService.loadAnimeDetails(widget.anime.id);
  }

  @override
  Future<void> initState() {
    anime = widget.anime;
    _carregarDetalhes();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Anime anime = widget.anime;
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do anime"),
      ),
      drawer: MenuLateral(context),
      body: Card(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Image(
                image: NetworkImage(anime.urlImagem),
              ),
            ),
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
            ),
            
            ListTile(
              title: Text(
                anime.episodios ?? "Indefinido"
              ),
            ),
            ListTile(
              title: Text(
                "Transmissão de 24/02/2022 a 24/05/2022 (Terças às 10:00)"
              ),
            ),
            ListTile(
              title: Text(
                anime?.animeDetails?.synopsis
              ),
            ),
            ListTile(
              title: Text(
                "Gêneros: Drama, Slice of Life, Romance"
              ),
            ),
            ListTile(
              title: Text(
                "Estúdio: MAPPA"
              ),
            ),
      
          ]
      
        ),
      )
    );
  }
}