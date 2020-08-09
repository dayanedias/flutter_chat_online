import 'dart:io';

import 'package:chat_online/ui/components/chat_message.dart';
import 'package:chat_online/ui/components/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user){
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if(_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
      await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final AuthResult authResult =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async{
    final FirebaseUser user = await _getUser();

    if(user == null){
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possível fazer o login, tente novamente!"),
          backgroundColor: Colors.red,
        )
      );
    }

    Map<String, dynamic> data = {
      "uid" : user.uid,
      "senderName" : user.displayName,
      "senderPhotoUrl" : user.photoUrl,
      "sendTime" : Timestamp.now(),
    };

    if(imgFile != null){
      StorageUploadTask task = FirebaseStorage.instance.ref().child(
        user.uid + DateTime.now().millisecondsSinceEpoch.toString()
      ).putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) data["text"] = text;
      Firestore.instance.collection("messages").document().setData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: _currentUser != null ?
        Text("Olá, ${_currentUser.displayName}", style: TextStyle(color: Colors.white),) :
        Text("Chat App", style: TextStyle(color: Colors.white),),
        elevation: 0,
        actions: [
          _currentUser != null ? IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  googleSignIn.signOut();
                  _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text("Você deslogou com sucesso!"),
                        backgroundColor: Colors.blue,
                      )
                  );
                }
              ) : Container()
        ],
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("messages").orderBy("sendTime").snapshots(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                        child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList();

                    return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                            return ChatMessage(documents[index].data,
                                documents[index].data["uid"] == _currentUser?.uid);
                        }
                    );
                }
              },
            ),
      ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
