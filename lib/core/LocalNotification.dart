import 'package:flutter/material.dart';

import '../model/Anime.dart';

class LocalNotification {
  LocalNotification(Map<dynamic, Object> map, {
    this.id,
    this.title,
    this.body,
    this.payload,
    this.timeOfDay,
  });

  LocalNotification.from(List<Anime> animes){
    DateTime now = DateTime.now();
    String idStr ="${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    String texto = "";
    if(animes != null)
      animes.forEach((element) {
        texto+="\n"+element.titulo +" - "+element.correctBroadcastTime;
      });
    
    id = int.parse(idStr);
    title = "Segue a lista dos episódios do dia";
    body = texto;
  }

  int id;
  String title;
  String body;
  String payload;
  TimeOfDay timeOfDay;
}
