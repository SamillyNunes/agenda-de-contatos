import 'package:contatos/ui/contact_page.dart';
import 'package:contatos/ui/home_page.dart';
import 'package:flutter/material.dart';


void main(){
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false , //tira a fitinha de debug da tela do simulador
  ),
  );
}