import 'dart:async';
import 'dart:convert';
import 'likeprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create:  (context) => likeprovider(),
    child:MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.chakraPetchTextTheme(),
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<User> users = <User>[
  ];

  int indext=0;

  loadJsonData() async {
    String jsonData = await rootBundle.loadString('Assets/user.json');
    setState(() {
      users = json
          .decode(jsonData)
          .map<User>((dataPoint) => User.fromJson(dataPoint))
          .toList();
    });
  }

  initState() {
    super.initState();
    loadJsonData();
  }

  @override
  Widget build(BuildContext context) {
    var h= MediaQuery.of(context).size.height;
    var w= MediaQuery.of(context).size.width;
    return FutureBuilder(future:loadJsonData(),builder:(context, snapshot){
    if (snapshot.connectionState!=ConnectionState.done){
    }
        return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text("GalacTinder", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 50)),
            ),
          body:Container(
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("Assets/background.gif"), fit: BoxFit.fill)
              ),
              height: h,
              width: w,
            child: Column(
              children: [
                SizedBox(height: 56,),
                Spacer(),
                Cards(users:users),
                Spacer(),
              ],
            )
          )
        );
  });}
}

class Cards extends StatefulWidget {
  const Cards({super.key, required this.users});
  final List<User> users;
  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  double _opacity=0.0;
  int index=0;
  double dx=0.0;
  double sx=0.0;
  bool isliked=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var h= MediaQuery.of(context).size.height;
    var w= MediaQuery.of(context).size.width;
    return Stack(children: [
        Center(child:
        Listener(onPointerDown: (e){setState(() {
          setState(() {
            sx= e.position.dx;
          });
          print(sx);
              });},
            child:Draggable(
                child:CardDetail(users: widget.users, index:index), feedback: CardDetail(users: widget.users, index: index),
                  childWhenDragging:CardDetail(users: widget.users, index:index+1),
                  onDragUpdate: (details){
                    if (dx>sx){
                    setState(() {
                    dx= details.localPosition.dx;
                    context.read<likeprovider>().setliked(true);});
                    isliked=true;
                    }else{
                    setState(() {
                    dx= details.localPosition.dx;
                    context.read<likeprovider>().setliked(false);});
                    isliked=false;
                    }
                    },
              onDragEnd: (details){
                  setState(() {
                    index++;
                    changeopacity();
                  });
                  print(index);
              },
          ))),
     AnimatedOpacity(opacity: _opacity, duration: Duration(milliseconds: 500),
      child:Center(child: Column(children: [
        SizedBox(height: 80,),
        Container(
          child: Text((isliked)?"LIKED":"DISLIKED",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 45)),
      ),
      ],) ))
    ],);
  }

  void changeopacity() {
    setState(() {
      _opacity=1.0;
    });
    Future.delayed(Duration(milliseconds: 500),(){
    setState(() {
      _opacity=0.0;
    });});
  }
}

class CardDetail extends StatefulWidget {
  const CardDetail({super.key, required this.users, required this.index});
  final List<User> users;
  final int index;
  @override
  State<CardDetail> createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  var timer;
  bool? isliked=null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(isliked);
    timer = Timer.periodic(Duration(milliseconds:500 ), (Timer t) => liked());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  liked(){
    setState(() {
      isliked=context.read<likeprovider>().isliked;
    });
    print(isliked);
  }

  @override
  Widget build(BuildContext context) {

    var h= MediaQuery.of(context).size.height;
    var w= MediaQuery.of(context).size.width;
        return
          Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),),
              child: Container(
                height: h*0.70,
                width: w*0.70,
                decoration:BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    image: DecorationImage(image: AssetImage(widget.users[widget.index].image), fit: BoxFit.fill)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacer(),
                    SizedBox(height: 75,),
                    Center(
                      child:
                      Container(
                        width: w*0.25,
                        height: w*0.25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(45),
                            color:(isliked!=null)? Colors.grey.withOpacity(0.75):Colors.transparent
                        ),
                        child: Column(children: [
                          Spacer(),
                          Container(
                            height: h*0.1,
                            decoration: BoxDecoration(
                                image: DecorationImage(image: AssetImage((isliked==null)? "": isliked!? "Assets/heart.webp":"Assets/broken.webp" ))
                            ),),
                          Spacer(),
                        ],),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(20),
                      height: h*0.17,
                      width: w*0.70,
                      decoration:BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.blue.shade900.withOpacity(0.55)
                      ),
                      child: Column(
                        children: [
                          Text("${widget.users[widget.index].name} ${widget.users[widget.index].age}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),),
                          Text("${widget.users[widget.index].desc}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }
}

class User{
  final String id;
  final String name;
  final int age;
  final String desc;
  final String image;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.desc,
    required this.image,
});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      desc: json['desc'],
      image: json['image'],
    );
  }

}
