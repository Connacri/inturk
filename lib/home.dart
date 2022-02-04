import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Fav.dart';
import 'main.dart';

class datafire extends StatefulWidget {
  const datafire({Key? key}) : super(key: key);

  @override
  _datafireState createState() => _datafireState();
}

class _datafireState extends State<datafire> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return _imageURLs();
  }
}

class _imageURLs extends StatefulWidget {
  @override
  _imageURLsState createState() => _imageURLsState();
}

class _imageURLsState extends State<_imageURLs> {
  Future<QuerySnapshot> _TopAgenceFuture = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Agence')
      .limit(3)
      .get();

  Future<QuerySnapshot> _TopHotelFuture = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Hotel')
      .limit(3)
      .get();

  Future<QuerySnapshot> _TopResidenceFuture = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Residence')
      .limit(3)
      .get();

  Future<QuerySnapshot> _TopSponsorFuture = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Others')
      .limit(5)
      .get();

  /*
final Stream<QuerySnapshot> _GridListStream = FirebaseFirestore.instance
      .collection('Products')
      .orderBy('time', descending: true)
      .snapshots(includeMetadataChanges: true);


  final Stream<QuerySnapshot> _TopHotelData = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Hotel')
      .limit(3)
      .snapshots(includeMetadataChanges: true);

  final Stream<QuerySnapshot> _TopResidenceData = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Residence')
      .limit(4)
      .snapshots(includeMetadataChanges: true);

  final Stream<QuerySnapshot> _TopAgenceData = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Agence')
      .limit(3)
      .snapshots(includeMetadataChanges: true);

  final Stream<QuerySnapshot> _TopSponsorData = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Others')
      .limit(5)
      .snapshots(includeMetadataChanges: true);
*/

/*  final Future<QuerySnapshot<Map<String, dynamic>>> _sliderShot = FirebaseFirestore
      .instance
      .collection('Products')
      .where('item', isEqualTo: 'ramzi')
      .get();*/

  // int _index = 0;

  int _dataLength = 1;

  Future<void> _refreshAll(BuildContext context) async {
    return fetchGlobalListe();
  }

  Future<Null> fetchGlobalListe() async {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (a, b, c) => MyStatefulWidget(),
            transitionDuration: Duration(seconds: 0)));
  }

  getProducts() async {
    Future<QuerySnapshot> _GridListTotal = FirebaseFirestore.instance
        .collection('Products')
        .orderBy('time', descending: true)
        .limit(6)
        .get();
  }

  Future<QuerySnapshot> _GridListTotal = FirebaseFirestore.instance
      .collection('Products')
      .orderBy('time', descending: true)
      .limit(6)
      .get();

  List<DocumentSnapshot> products = []; // stores fetched products
  bool isLoading = false; // track if products fetching
  bool hasMore = true; // flag for more products available or not
  int documentLimit = 10; // documents to be fetched per request
  late DocumentSnapshot lastDocument;
  ScrollController _scrollController = ScrollController();

  getProductsGlobal() async {
    if (!hasMore) {
      print('No More Products');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get();
      print(1);
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    products.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }


  _scrollController


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refreshAll(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                // height: 250,
                color: Colors.white,
                child: Column(
                  children: [
                    if (_dataLength != 0)
                      FutureBuilder(
                        future: _TopHotelFuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading");
                          }
                          return snapshot.data == null
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: CarouselSlider(
                                      items: snapshot.data!.docs.map(
                                        (DocumentSnapshot document) {
                                          Map<String, dynamic> _data = document
                                              .data()! as Map<String, dynamic>;
                                          return SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: ShaderMask(
                                              shaderCallback: (rect) {
                                                return LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black
                                                  ],
                                                ).createShader(Rect.fromLTRB(
                                                    0,
                                                    0,
                                                    rect.width,
                                                    rect.height));
                                              },
                                              blendMode: BlendMode.darken,
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: _data['themb'],
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                      options: CarouselOptions(
                                        viewportFraction: 1,
                                        initialPage: 0,
                                        autoPlay: true,
                                        height: 170,
                                        /*   onPageChanged: (int i,
                                        carouselPageChangedReason) {
                                      setState(() {
                                        _index = i;
                                      });
                                    }*/
                                      )),
                                );
                        },
                      ),
                  ],
                ),
              ), //Firestore Slider
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Top Hôtel',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Oswald'),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                                alignment: Alignment.bottomRight,
                                child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: const <TextSpan>[
                                      TextSpan(
                                          text: 'Super',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Oswald',
                                              fontSize: 18,
                                              color: Colors.red)),
                                      TextSpan(
                                          text: 'Deals',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Oswald',
                                              fontSize: 18,
                                              color: Colors.blue)),
                                    ],
                                    //text: 'Aujourd\'Hui ',
                                  ),
                                )),
                          ),
                          Icon(Icons.arrow_forward_ios_sharp),
                          /*add_to_photos_rounded
                            arrow_forward_ios_sharp
                            arrow_right_sharp*/
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width,
                      child: FutureBuilder<QuerySnapshot>(
                        future: _TopHotelFuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading");
                          }

                          return ListView(
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> _data =
                                  document.data()! as Map<String, dynamic>;
                              return CardR(data: _data);
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ), // ListView Horizontal Filtered Top Hotel
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Top Résidence',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Oswald'),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                                alignment: Alignment.bottomRight,
                                child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: const <TextSpan>[
                                      TextSpan(
                                          text: 'Flash',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Oswald',
                                              fontSize: 18,
                                              color: Colors.green)),
                                      TextSpan(
                                          text: 'Vente',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Oswald',
                                              fontSize: 18,
                                              color: Colors.black)),
                                    ],
                                    //text: 'Aujourd\'Hui ',
                                  ),
                                )),
                          ),
                          Icon(Icons.arrow_forward_ios_sharp),
                          /*add_to_photos_rounded
                            arrow_forward_ios_sharp
                            arrow_right_sharp*/
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width,
                      child: FutureBuilder<QuerySnapshot>(
                        future: _TopResidenceFuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading");
                          }

                          return ListView(
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> _data =
                                  document.data()! as Map<String, dynamic>;
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                elevation: 2,
                                semanticContainer: true,
                                color: Colors.white70,
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.15,
                                  width:
                                      MediaQuery.of(context).size.width * 0.30,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Container(
                                        child: ShaderMask(
                                          shaderCallback: (rect) {
                                            return LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black
                                              ],
                                            ).createShader(Rect.fromLTRB(
                                                0, 0, rect.width, rect.height));
                                          },
                                          blendMode: BlendMode.darken,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: _data['themb'],
                                            /*placeholder: (context, url) => Center(
                                              child: CircularProgressIndicator(),
                                            ),*/
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        //height: 60,
                                        //color: Colors.black45,

                                        child: ListTile(
                                          title: Text(
                                            _data['item'].toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                              fontFamily: 'Oswald',
                                            ),
                                          ),
                                          subtitle: Text(
                                            _data['price'] + '.00 DZD',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              fontFamily: 'Oswald',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      /*ListView.builder(
                              itemCount: 20,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Container(
                                    height: 100,
                                    width: 100,
                                    margin: EdgeInsets.all(10),
                                    child: Center(
                                      child: Text('Cardrat $index'),
                                    ),
                                    color: Colors.green,
                                  )),*/
                    ),
                  ],
                ),
              ), // ListView Horizontal Filtered Top Résidence
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Top Agence',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Oswald'),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                                alignment: Alignment.bottomRight,
                                child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: const <TextSpan>[
                                      TextSpan(
                                          text: 'Best',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Oswald',
                                              fontSize: 18,
                                              color: Colors.deepPurple)),
                                      TextSpan(
                                          text: 'Choice',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Oswald',
                                              fontSize: 18,
                                              color: Colors.red)),
                                    ],
                                    //text: 'Aujourd\'Hui ',
                                  ),
                                )),
                          ),
                          Icon(Icons.arrow_forward_ios_sharp),
                          /*add_to_photos_rounded
                            arrow_forward_ios_sharp
                            arrow_right_sharp*/
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width,
                      child: FutureBuilder<QuerySnapshot>(
                        future: _TopAgenceFuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading");
                          }

                          return ListView(
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> _data =
                                  document.data()! as Map<String, dynamic>;
                              return CardR(data: _data);
                            }).toList(),
                          );
                        },
                      ),

                      /*ListView.builder(
                              itemCount: 20,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Container(
                                    height: 100,
                                    width: 100,
                                    margin: EdgeInsets.all(10),
                                    child: Center(
                                      child: Text('Cardrat $index'),
                                    ),
                                    color: Colors.green,
                                  )),*/
                    ),
                  ],
                ),
              ), // ListView Horizontal Filtered Top Agence
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: SizedBox(
                                //width: 200.0,
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.red,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 7.0,
                                        color: Colors.white,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    animatedTexts: [
                                      FlickerAnimatedText('Flicker Frenzy',
                                          textStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: 'Oswald')),
                                      FlickerAnimatedText('Night Vibes On',
                                          textStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: 'Oswald')),
                                      FlickerAnimatedText("C'est La Vie !",
                                          textStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: 'Oswald')),
                                    ],
                                    onTap: () {
                                      print("Tap Event");
                                    },
                                  ),
                                ),
                              ),

                              /*Text(
                                  'Sponsorisé',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Oswald'),
                                ),*/
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 30,
                              color: Colors.black,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: const <TextSpan>[
                                        TextSpan(
                                            text: 'Top ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Oswald',
                                                fontSize: 18,
                                                color: Colors.blue)),
                                        TextSpan(
                                            text: 'Product',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Oswald',
                                                fontSize: 18,
                                                color: Colors.yellowAccent)),
                                      ],
                                      //text: 'Aujourd\'Hui ',
                                    ),
                                  )),
                            ),
                          ),
                          /*Icon(Icons.arrow_forward_ios_sharp),*/
                          /*add_to_photos_rounded
                            arrow_forward_ios_sharp
                            arrow_right_sharp*/
                        ],
                      ),
                    ),
                    FutureBuilder<QuerySnapshot>(
                      future: _TopSponsorFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("KLoading");
                        }

                        return ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> _data =
                                document.data()! as Map<String, dynamic>;
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              elevation: 5,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(_data['themb']),
                                    ),
                                    /*Icon(Icons.add_a_photo_rounded),*/
                                    title: Text(
                                      _data['item'].toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        fontFamily: 'Oswald',
                                      ),
                                    ),
                                    subtitle: Text(
                                      _data['price'] + '.00 DZD',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        fontFamily: 'Oswald',
                                      ),
                                    ),
                                  ),
                                  ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black
                                        ],
                                      ).createShader(Rect.fromLTRB(
                                          0, 0, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.darken,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: _data['themb'],
                                      /*placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),
                                ),*/
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Greyhound divisively hello coldly wonderfully marginally far upon excluding.'
                                          .toUpperCase(),
                                      //overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        fontFamily: 'Oswald',
                                      ),
                                    ),
                                  ),
                                  ButtonBar(
                                    alignment: MainAxisAlignment.start,
                                    children: [
                                      FlatButton(
                                        textColor: const Color(0xFF005DFF),
                                        onPressed: () {
                                          // Perform some action
                                        },
                                        child: Text(
                                          'ACTION 1'.toUpperCase(),
                                          //overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            //color: Colors.black.withOpacity(0.6),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            fontFamily: 'Oswald',
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                        textColor: const Color(0xFFFF0000),
                                        onPressed: () {
                                          // Perform some action
                                        },
                                        child: Text(
                                          'ACTION 2'.toUpperCase(),
                                          //overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            //color: Colors.black.withOpacity(0.6),
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                            fontFamily: 'Oswald',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  /* Image.network('https://images.unsplash.com/photo-1481349518771-20055b2a7b24?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=939&q=80'),*/
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ), // ListView Horizontal Filtered Top Product
              SizedBox(
                child: FutureBuilder<QuerySnapshot>(
                    future: _GridListTotal,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      //print(snapshot.connectionState);
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (snapshot.hasError) {
                          return const Text('Error');
                        } else if (snapshot.hasData) {
                          return GridView.count(
                            controller: _scrollController, //************************controller
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            //mainAxisSpacing: 0.5,
                            //crossAxisSpacing: 0.5,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> _data =
                                  document.data()! as Map<String, dynamic>;

                              final List<String> images =
                                  List.from(document['urls']);

                              List<GridTile> newGridTile = [];

                              images.forEach((image) {
                                newGridTile.add(GridTile(
                                  child: Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                  ),
                                ));
                              });

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  //color: Colors.lightBlue,
                                  child: InkWell(
                                    child: GridTile(
                                      footer: Container(
                                        // height: 60,
                                        //color: Colors.black45,
                                        child: ListTile(
                                          title: Text(
                                            _data['item'].toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 15,
                                              fontFamily: 'Oswald',
                                            ),
                                          ),
                                          subtitle: Text(
                                            _data['price'] + '.00 DZD',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.indigoAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              fontFamily: 'Oswald',
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: ShaderMask(
                                        shaderCallback: (rect) {
                                          return LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black
                                            ],
                                          ).createShader(Rect.fromLTRB(
                                              0, 0, rect.width, rect.height));
                                        },
                                        blendMode: BlendMode.darken,
                                        child: CachedNetworkImage(
                                          imageUrl: _data['themb'],
                                          /*placeholder: (context, url) => Center(
                                              child: CircularProgressIndicator(),
                                            ),*/
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      /*Image.network(
                                            _data['themb'],
                                            fit: BoxFit.cover,
                                          ),*/
                                    ),
                                    // focusColor: Colors.deepPurple ,
                                    onTap: () {},
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          return const Text('Empty data');
                        }
                      } else {
                        return Text('State: ${snapshot.connectionState}');
                      }
                    }),
              ), // GridView Vertical Global
            ],
          ),
        ),
      ),
    );
  }
}

class CardR extends StatelessWidget {
  const CardR({
    Key? key,
    required Map<String, dynamic> data,
  })  : _data = data,
        super(key: key);

  final Map<String, dynamic> _data;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      semanticContainer: true,
      color: Colors.white70,
      child: Container(
        height: MediaQuery.of(context).size.width * 0.15,
        width: MediaQuery.of(context).size.width * 0.30,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.darken,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: _data['themb'],
                  /*placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),*/
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              //height: 60,
              //color: Colors.black45,

              child: ListTile(
                title: Text(
                  _data['item'].toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    fontFamily: 'Oswald',
                  ),
                ),
                subtitle: Text(
                  _data['price'] + '.00 DZD',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Oswald',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
