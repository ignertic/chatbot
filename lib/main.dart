import 'dart:convert';

import 'package:bubble/bubble.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<String> _data = [];
  static const String BOT_URL = "http://192.168.1.241:8001/bot"; // replace with server address
  TextEditingController _queryController = TextEditingController();



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Flutter & Python"),
      ),
      body: Stack(
        children: <Widget>[
          AnimatedList(
            // key to call remove and insert from aanywhere
            key: _listKey,
            initialItemCount: _data.length,
            itemBuilder: (BuildContext context, int index, Animation animation){
              return _buildItem(_data[index], animation, index);
            }
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.message, color: Colors.greenAccent,),
                hintText: "Hello",
              ),
              controller: _queryController,
              textInputAction: TextInputAction.send,
              onSubmitted: (msg){

                this._getResponse();
              },

            ),
          )
        ],
      )
      ,
    );
  }

  http.Client _getClient(){
    return http.Client();
  }

  void _getResponse(){
    if (_queryController.text.length>0){
      this._insertSingleItem(_queryController.text);
      var client = _getClient();
      try{
        client.post(BOT_URL, body: {"query" : _queryController.text},)
        ..then((response){
          Map<String, dynamic> data = jsonDecode(response.body);
          _insertSingleItem(data['response']+"<bot>"); 

        });
      }catch(e){
        print("Failed -> $e");
      }finally{
        client.close();
        _queryController.clear();
      }
    }
  }

  void _insertSingleItem(String message){

    _data.add(message); //insert(_data.length-1, message);
    _listKey.currentState.insertItem(_data.length-1);
  }
  Widget _buildItem(String item, Animation animation,int index){
    bool mine = item.endsWith("<bot>");
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(padding: EdgeInsets.only(top: 10),
      child: Container(
        alignment: mine ?  Alignment.topLeft : Alignment.topRight,

        child : Bubble(
        child: Text(item.replaceAll("<bot>", "")),
        color: mine ? Colors.blue : Colors.indigo,
        padding: BubbleEdges.all(10),

      )),
    )

    );
  }
}
