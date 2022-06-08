import 'package:flutter/material.dart';

import 'Anime.dart';

class LocalNotification {
  LocalNotification(Map<dynamic, Object> map, {
    this.id,
    this.title,
    this.body,
    this.payload,
    this.timeOfDay,
  });

  LocalNotification.from(int weekday, List<Anime> animes){
    String texto = "";
    if(animes != null)
      animes.forEach((element) {
        texto+="\n"+element.titulo +" - "+element.correctBroadcastTime;
      });
    id = weekday;
    title = "Segue a lista dos episódios do dia";
    body = texto;
  }

  int id;
  String title;
  String body;
  String payload;
  TimeOfDay timeOfDay;
}
