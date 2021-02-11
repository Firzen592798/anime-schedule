import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service/ApiService.dart';
import 'package:animeschedule/util/ApiResponse.dart';
import 'package:animeschedule/widget/MenuLateral.dart';
import 'package:flutter/material.dart';

class MeusAnimesView extends StatefulWidget {
  @override
  _MeusAnimesViewState createState() => _MeusAnimesViewState();
}

class _MeusAnimesViewState extends State<MeusAnimesView> {

  List<Anime> _listaAnimes = [];
  ApiService _apiService = ApiService();

  int diaSelecionado = 0;

  List<String> listaDias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

  @override
  void initState() {
    _carregarAnimes();
    super.initState();
  }

  _carregarAnimes() async{
    ApiResponse response = await _apiService.listarAnimes(diaSelecionado);
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
        actions: [
          new DropdownButton<String>(
            items: listaDias.map((String value) {
              return new DropdownMenuItem<String>(
                value: value,
                child: new Text(value),
              );
            }).toList(),
            hint: Text("Please choose a location"),
            value: listaDias[diaSelecionado],
            onChanged: (newVal) {
              this.setState(() {
                diaSelecionado = listaDias.indexOf(newVal);
                _carregarAnimes();
              });
            },
          ),
          //Icon(Icons.more_vert),
        ],
      ),
      drawer: MenuLateral(),
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
        child: ListTile(
          title: Text(_listaAnimes[index].titulo),
          subtitle: Row(
            children: [
              Text(this.diaSelecionado.toString()),
              Text(_listaAnimes[index].diaSemana),
              //_listaAnimes[index].episodios.toString() != null ? Text("Episódios: "+_listaAnimes[index].episodios.toString()) : Text("Episódios: Não especificado"),
            ],
          ),
          trailing: Image.network(_listaAnimes[index].urlImagem)

        )

    );
  }
}

