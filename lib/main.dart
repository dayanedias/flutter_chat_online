import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_online/ui/chat_screen.dart';

void main() async {
  runApp(MyApp());
  
/* Atualização em tempo real

Firestore.instance.collection("mensagens").snapshots().listen((dado) {
    dado.documents.forEach((doc) {
      print(doc.data);
    });
  });*/

 /* Chamada do state sem atualização 
 
 QuerySnapshot snapshot = await Firestore.instance.collection("mensagens").getDocuments();

  snapshot.documents.forEach((d){
    d.reference.updateData({"lido" : false});
  });*/
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.blue
        )
      ),
      home: ChatScreen(),
    );
  }
}