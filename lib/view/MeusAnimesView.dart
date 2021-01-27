import 'package:flutter/material.dart';

class MeusAnimesView extends StatefulWidget {
  @override
  _MeusAnimesViewState createState() => _MeusAnimesViewState();
}

class _MeusAnimesViewState extends State<MeusAnimesView> {

  List _listaAnimes = ['Naruto', 'Bleach', 'One Piece'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de animes"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listaAnimes.length,
              itemBuilder: criarItem
            ),
          )
        ],
      ),
    );
  }

  Widget criarItem(context, index){
    //final item = _listaTarefas[index]["titulo"];
    return  Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(_listaAnimes[index]),
          ],
        )

    );
  }
}

