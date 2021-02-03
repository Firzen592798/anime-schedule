import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service/ApiService.dart';
import 'package:animeschedule/util/ApiResponse.dart';
import 'package:flutter/material.dart';

class MeusAnimesView extends StatefulWidget {
  @override
  _MeusAnimesViewState createState() => _MeusAnimesViewState();
}

class _MeusAnimesViewState extends State<MeusAnimesView> {

  List<Anime> _listaAnimes = [];
  ApiService _apiService = ApiService();
  @override
  void initState() {
    _carregarAnimes();
    super.initState();
  }

  _carregarAnimes() async{
    ApiResponse response = await _apiService.listarAnimes();
    //print("Response: "+response.data[0].titulo);
    if(!response.isError){
      setState(() {
        _listaAnimes = response.data;
      });
    }
  }


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
            ListTile(
              title: Text(_listaAnimes[index].titulo),
              subtitle: Row(
                children: [
                  Text(_listaAnimes[index].diaSemana),
                  Text("Episódios: "+_listaAnimes[index].episodios.toString()),
                ],
              ),
              trailing: Image.network(_listaAnimes[index].urlImagem)

            )
            
          ],
        )

    );
  }
}

