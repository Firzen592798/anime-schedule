import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toasts{
  static void mostrarToast(String conteudo){
    Fluttertoast.showToast(
      msg: conteudo,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }
}

