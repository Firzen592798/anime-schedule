import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../model/Anime.dart';

class AnimeListItem extends StatefulWidget {

  final int index;

  final Anime anime;

  final Function marcarAnime;

  final Function desmarcarAnime;

  final Function irParaDetalhes;

  

  const AnimeListItem({Key key, this.anime, this.marcarAnime, this.desmarcarAnime, this.irParaDetalhes, this.index}) : super(key: key);

  @override
  State<AnimeListItem> createState() => _AnimeListItemState();
}

class _AnimeListItemState extends State<AnimeListItem> {

  _marcar(){
    print("marcar");
    setState(() {
      widget.anime.marcado = true;
    });
    widget.marcarAnime(widget.anime);
  }

  _desmarcar(){
    print("desmarcar");
    setState(() {
      widget.anime.marcado = false;
    });
    widget.desmarcarAnime(widget.anime);
  }

  @override
  Widget build(BuildContext context) {
    return  Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image(
              alignment: Alignment.center,
              height: 80,
              width: 80,
              isAntiAlias: true,
              fit: BoxFit.cover,
              image: NetworkImage(widget.anime.urlImagem)
            ),
          ),
          Expanded(child: Text(widget.anime.titulo)),
          IconButton(
            icon: !widget.anime.marcado ? const Icon(Icons.star_outline) :  const Icon(Icons.star),
            tooltip: !widget.anime.marcado ? 'Marcar como Assistindo' : 'Remover marcação',
            onPressed: () {
              if(!widget.anime.marcado){
                _marcar();
              }else{
                _desmarcar();
              }
            },
          )
        ],
      );
  }
}