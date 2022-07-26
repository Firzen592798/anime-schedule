import 'package:animeschedule/core/CustomColors.dart';
import 'package:animeschedule/service/ILocalStorageService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/Globals.dart';
import '../domain/AnimeLocal.dart';
import '../service-impl/LocalStorageService.dart';
import '../service-impl/SchedulerService.dart';
import 'MeusAnimesView.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  bool DEBUG_ACTIONS = true;

  int selectedDay = 0;

  ILocalStorageService localStorageService = LocalStorageService();

  void debugActions(){
    if(DEBUG_ACTIONS){
      localStorageService.printStorage();
      SchedulerService schedulerService = SchedulerService();
      DateTime now = DateTime.now();
      int hour = now.hour;
      int minutes = now.minute + 1;
      String timeOfDay ="${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
      schedulerService.scheduleFixedTimeOfDay(timeOfDay, now);
    }
  }

  @override
  initState() {
    super.initState();
      debugActions();
      localStorageService.getToken().then((token) async {
      if(token != null){
        print("Token not null");
        GlobalVar().token = token;
        await localStorageService.getUser().then((user) async {
           print("User not null");
           GlobalVar().user = user;
        });
      }
      Navigator.pushReplacementNamed(context, "/meusanimes");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomColors.skeletonColor,
    );
  }
}