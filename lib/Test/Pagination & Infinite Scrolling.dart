import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'dart:math';

import '../home.dart';

class Pagination_Infinite_Scrolling extends StatefulWidget {
  const Pagination_Infinite_Scrolling({Key? key}) : super(key: key);

  @override
  _Pagination_Infinite_ScrollingState createState() =>
      _Pagination_Infinite_ScrollingState();
}

class _Pagination_Infinite_ScrollingState
    extends State<Pagination_Infinite_Scrolling> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

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
      .where('category', isEqualTo: 'Autres')
      .limit(3)
      .get();

  int _dataLength = 1;

  final queryPost = FirebaseFirestore.instance
      .collection('Products')
      .orderBy('createdAt', descending: true)
      .withConverter<Post>(
        fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!),
        toFirestore: (post, _) => post.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pagination_Infinite_Scrolling'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Slider(dataLength: _dataLength, TopHotelFuture: _TopHotelFuture),
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      uploadRandom();
                    });
                  },
                  child: Text('Stepper'),
                ),
              ), //adding database

              Top_Residence(TopResidenceFuture: _TopResidenceFuture),
              Top_Agence(TopAgenceFuture: _TopAgenceFuture),
              Top_Product(TopSponsorFuture: _TopSponsorFuture),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FirestoreQueryBuilder(
                    query: queryPost,
                    pageSize: 20,
                    builder: (BuildContext context,
                        FirestoreQueryBuilderSnapshot<dynamic> snapshot,
                        Widget? child) {
                      if (snapshot.isFetching) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Somethink as wrong! ${snapshot.hasError}');
                      } else {
                        return GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: snapshot.docs.length,
                            itemBuilder: (context, index) {
                              final hasEndReached = snapshot.hasMore &&
                                  index + 1 == snapshot.docs.length &&
                                  !snapshot.isFetchingMore;
                              if (hasEndReached) {
                                snapshot.fetchMore();
                              }
                              final post = snapshot.docs[index].data();
                              return buildPost(post);
                            });
                      }
                    }),
              ),
            ],
          ),
        )

        // FirestoreListView<Post>(
        //   itemBuilder:
        //       (BuildContext context, QueryDocumentSnapshot<dynamic> doc) {
        //     final post = doc.data();
        //     return ListTile(
        //       leading: CircleAvatar(
        //         backgroundImage: NetworkImage(post.themb),
        //       ),
        //       title: Text(post.item),
        //       subtitle: Text('${post.likes} Jaime'),
        //     );
        //   },
        //   query: queryPost,
        // ),
        );
  }

  Widget buildPost(Post post) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black],
                        ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.darken,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: post.themb,
                        /*placeholder: (context, url) => Center(
                                              child: CircularProgressIndicator(),
                                            ),*/
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                      alignment: Alignment.topLeft,
                      child: post.category == 'Hotel'
                          ? Text(
                              post.category.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                backgroundColor: Colors.blue,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                fontFamily: 'Oswald',
                              ),
                            )
                          : Text(
                              post.category.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                backgroundColor: Colors.red,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                fontFamily: 'Oswald',
                              ),
                            ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: ListTile(
                        title: Text(
                          post.item.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                            fontFamily: 'Oswald',
                          ),
                        ),
                        subtitle: Text(
                          post.code.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Oswald',
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(4, 12, 0, 0),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        post.decription.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          fontFamily: 'Oswald',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(6),
              //   ),
              //   clipBehavior: Clip.antiAliasWithSaveLayer,
              //   elevation: 2,
              //   semanticContainer: true,
              //   color: Colors.white70,
              //   child: Container(
              //     height: MediaQuery.of(context).size.width * 0.15,
              //     width: MediaQuery.of(context).size.width * 0.30,
              //     child: Stack(
              //       fit: StackFit.expand,
              //       children: [
              //         Container(
              //           child: ShaderMask(
              //             shaderCallback: (rect) {
              //               return LinearGradient(
              //                 begin: Alignment.topCenter,
              //                 end: Alignment.bottomCenter,
              //                 colors: [Colors.transparent, Colors.black],
              //               ).createShader(
              //                   Rect.fromLTRB(0, 0, rect.width, rect.height));
              //             },
              //             blendMode: BlendMode.darken,
              //             child: CachedNetworkImage(
              //               fit: BoxFit.cover,
              //               imageUrl: post.themb,
              //               /*placeholder: (context, url) => Center(
              //                                 child: CircularProgressIndicator(),
              //                               ),*/
              //               errorWidget: (context, url, error) =>
              //                   Icon(Icons.error),
              //             ),
              //           ),
              //         ),
              //         Container(
              //           alignment: Alignment.bottomCenter,
              //           //height: 60,
              //           //color: Colors.black45,
              //
              //           child: ListTile(
              //             title: Text(
              //               post.category.toUpperCase(),
              //               overflow: TextOverflow.ellipsis,
              //               style: TextStyle(
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.normal,
              //                 fontSize: 12,
              //                 fontFamily: 'Oswald',
              //               ),
              //             ),
              //             subtitle: Text(
              //               post.code,
              //               overflow: TextOverflow.ellipsis,
              //               style: TextStyle(
              //                 color: Colors.redAccent,
              //                 fontWeight: FontWeight.bold,
              //                 fontSize: 12,
              //                 fontFamily: 'Oswald',
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          post.price.toUpperCase() + '.00 DZD',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Oswald',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          post.likes.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            fontFamily: 'Oswald',
                          ),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.favorite,
                      color: Colors.blue,
                      size: 14.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

void uploadRandom() async {
  final postCollection =
  FirebaseFirestore.instance.collection('Products').withConverter<Post>(
    fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!),
    toFirestore: (post, _) => post.toJson(),
  );
  final numbers = List.generate(300, (index) => index + 1);
  for (final number in numbers) {

    List<String> listCat = [
      'Hotel',
      'Residence',
      'Agence',
      'Autres',
      'Sponsors',
    ];
    List<String> listItem = [
      'Adams',
      'Bakerti',
      'Clark',
      'Davisco',
      'Evanessance',
      'Frank',
      'Ghoshock',
      'Hills',
      'Irwintaro',
      'Jones',
      'Kleinez',
      'Lopez',
      'Mufasa',
      'Sarabi',
      'Simba',
      'Nala',
      'Kiara',
      'Kov',
      'Timon',
      'Pumbaama',
      'Rafora',
      'Shenzi',
      'Masoulna',
      'Naltyp',
      'Ochoa',
      'Patelroota',
      'Quinncom',
      'Reilyse',
      'Smith',
      'Trott',
      'Usman',
      'Valdorcomité',
      'White',
      'Xiangshemzhen',
      'Yakub',
      'Zafarta',
    ];

    List<String> listDesc = [
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
      "Le président français Emmanuel Macron a assuré mardi avoir «obtenu» lors de ses discussions avec Vladimir Poutine «qu'il n'y ait pas de dégradation ni d'escalade» dans la crise russo-occidentale liée à l'Ukraine.",
      "L'organisation du Traité de l'Atlantique Nord (OTAN) est une alliance politique et militaire créée en 1949 dans le contexte de la guerre froide. Elle continue à jouer un rôle de premier plan dans le système de sécurité en Europe, même depuis la chute de l'URSS en 1991 et le délitement du Pacte de Varsovie (la contre-alliance du bloc soviétique). Ses extensions et sa relation privilégiée avec l'Ukraine sont au cœur des tensions actuelles avec la Russie. Explications en cartes.",
      "Quentin Fillon-Maillet : «Avec deux fautes au tir, je n'imaginais pas pouvoir jouer la victoire»",
      "ENQUÊTE - Faute d’avoir pu s’acquitter d’une traite faramineuse, le promoteur immobilier le plus fantasque de Los Angeles a perdu le contrôle de la gigantesque villa qu’il avait fait construire et dont il espérait tirer 500 millions de dollars. Son concepteur, ruiné, s’est exilé à Zurich.",
    ];

    var randomCat = (listCat..shuffle()).first;
    var randomDesc = (listDesc..shuffle()).first;
    var randomItem = (listItem..shuffle()).first;

    var prix = Random().nextInt(5000);
    var catego = listCat[0];
    var items = listItem[0];
    var desc = listDesc[0];


    final post = Post(
        item: '$randomItem',
        code: 'invoice$number',
        category: '$randomCat',
        price: '$prix',
        likes: '$number', //Random().nextInt(1000),
        createdAt: DateTime.now(),
        decription: '$randomDesc',
        imageUrl: 'https://source.unsplash.com/random?sig=$number',
        themb: 'https://source.unsplash.com/random?sig=$number');
    postCollection.add(post);
  }
}

class Slider extends StatelessWidget {
  const Slider({
    Key? key,
    required int dataLength,
    required Future<QuerySnapshot<Object?>> TopHotelFuture,
  })  : _dataLength = dataLength,
        _TopHotelFuture = TopHotelFuture,
        super(key: key);

  final int _dataLength;
  final Future<QuerySnapshot<Object?>> _TopHotelFuture;

  @override
  Widget build(BuildContext context) {
    return Container(
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

                if (snapshot.connectionState == ConnectionState.waiting) {
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
                                Map<String, dynamic> _data =
                                    document.data()! as Map<String, dynamic>;
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width,
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
    );
  }
}

class Top_Product extends StatelessWidget {
  const Top_Product({
    Key? key,
    required Future<QuerySnapshot<Object?>> TopSponsorFuture,
  })  : _TopSponsorFuture = TopSponsorFuture,
        super(key: key);

  final Future<QuerySnapshot<Object?>> _TopSponsorFuture;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        style: const TextStyle(
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
                            FlickerAnimatedText('Flicker Ramzy',
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
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              return ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> _data =
                      document.data()! as Map<String, dynamic>;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 5,
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(_data['themb']),
                          ),
                          /*Icon(Icons.add_a_photo_rounded),*/
                          title: Text(
                            _data['item'].toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              fontFamily: 'Oswald',
                            ),
                          ),
                          subtitle: Text(
                            _data['price'] + '.00 DZD',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Oswald',
                            ),
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
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
                                style: const TextStyle(
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
                                style: const TextStyle(
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
    );
  }
}

class Top_Agence extends StatelessWidget {
  const Top_Agence({
    Key? key,
    required Future<QuerySnapshot<Object?>> TopAgenceFuture,
  })  : _TopAgenceFuture = TopAgenceFuture,
        super(key: key);

  final Future<QuerySnapshot<Object?>> _TopAgenceFuture;

  @override
  Widget build(BuildContext context) {
    return Padding(
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

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return ListView(
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
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
    );
  }
}

class Top_Residence extends StatelessWidget {
  const Top_Residence({
    Key? key,
    required Future<QuerySnapshot<Object?>> TopResidenceFuture,
  })  : _TopResidenceFuture = TopResidenceFuture,
        super(key: key);

  final Future<QuerySnapshot<Object?>> _TopResidenceFuture;

  @override
  Widget build(BuildContext context) {
    return Padding(
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

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return ListView(
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
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
    );
  }
}
