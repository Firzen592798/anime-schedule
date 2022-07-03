import 'package:flutter/material.dart';
import '../domain/AnimeLocal.dart';
import '../themes/AppTheme.dart';

class AnimeListItem extends StatefulWidget {
  final int index;

  final AnimeLocal anime;

  final Function marcarAnime;

  final Function desmarcarAnime;

  final Function irParaDetalhes;

  const AnimeListItem(
      {Key key,
      this.anime,
      this.marcarAnime,
      this.desmarcarAnime,
      this.irParaDetalhes,
      this.index})
      : super(key: key);

  @override
  State<AnimeListItem> createState() => _AnimeListItemState();
}

class _AnimeListItemState extends State<AnimeListItem> {
  _marcar() {
    print("marcar");
    setState(() {
      widget.anime.marcado = true;
    });
    widget.marcarAnime(widget.anime);
  }

  _desmarcar() {
    print("desmarcar");
    setState(() {
      widget.anime.marcado = false;
    });
    widget.desmarcarAnime(widget.anime);
  }

  @override
  Widget build(BuildContext context) {
    return 
    Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                  ),
                ),
                child: Image(
                    alignment: Alignment.center,
                    height: 80,
                    width: 80,
                    isAntiAlias: true,
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.anime.urlImagem)),
              ),
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.anime.titulo),
                  Text(
                    widget.anime.correctBroadcastTime,
                    style: AppTheme().themedata.textTheme.bodySmall,
                  ),
                  Text(
                    "Transmissão: ${widget.anime.transmissionRange}",
                    style: AppTheme().themedata.textTheme.bodySmall.copyWith(fontSize: 14),
                  ),
                ],
              ),
            )),
            IconButton(
              icon: !widget.anime.marcado
                  ? const Icon(Icons.star_outline)
                  : const Icon(Icons.star),
              tooltip: !widget.anime.marcado
                  ? 'Marcar como Assistindo'
                  : 'Remover marcação',
              onPressed: () {
                if (!widget.anime.marcado) {
                  _marcar();
                } else {
                  _desmarcar();
                }
              },
            )
          ],
        ),
        Divider(
          indent: 0,
          height: 0,
        )   
      ],
    );
  }
}
