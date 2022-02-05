import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../home.dart';

class Carrouselllll extends StatefulWidget {
  const Carrouselllll({Key? key}) : super(key: key);

  @override
  _CarrouselllllState createState() => _CarrouselllllState();
}

class _CarrouselllllState extends State<Carrouselllll> {

  @override
  void initState() {
    getSliderImageFromDb();
    super.initState();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getSliderImageFromDb() async {
    final QuerySnapshot<Map<String, dynamic>> _sliderShot =
        await FirebaseFirestore.instance
            .collection('Products')
            .where('item', isEqualTo: 'Autres')
            .get();
    if (mounted) {
      /*setState(() {
        _dataLength = _sliderShot.docs.length;
        print(_dataLength);
      });*/
    }
    return _sliderShot.docs;
  }

  final Future<QuerySnapshot> _TopHotelFuture = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Hotel')
      .limit(3)
      .get();

  final Future<QuerySnapshot> _GridListTotal = FirebaseFirestore.instance
      .collection('Products')
      .orderBy('createdAt', descending: true)
      .get();

  int _index = 0;
  int _dataLength = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                                  Map<String, dynamic> _data =
                                      document.data()! as Map<String, dynamic>;
                                  return SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width,
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width,
                    child: FutureBuilder<QuerySnapshot>(
                      future: _TopHotelFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
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
            ),
            Container(
              // height: 250,
              color: Colors.white,
              child: Column(
                children: [
                  if (_dataLength != 0)
                    FutureBuilder(
                      future: getSliderImageFromDb(),
                      builder:
                          (BuildContext context,AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>> snapShot) {
                        return snapShot.data == null
                            ? Center(
                          child: CircularProgressIndicator(),
                        )
                            : Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: CarouselSlider.builder(
                              itemCount: snapShot.data!.length,
                              itemBuilder:(BuildContext context, index, int) {
                                DocumentSnapshot<Map<String, dynamic>>
                                sliderImage = snapShot.data![index];

                                Map<String, dynamic>? getImage =
                                sliderImage.data()
                                as Map<String, dynamic>;

                                return SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width,
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black
                                        ],
                                      ).createShader(Rect.fromLTRB(0, 0,
                                          rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.darken,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: getImage['themb'],
                                      /*placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),*/
                                      errorWidget:
                                          (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),

                                  /*Image.network(
                                              getImage['themb'],
                                              fit: BoxFit.cover,
                                            )*/
                                );
                              },
                              options: CarouselOptions(
                                  viewportFraction: 1,
                                  initialPage: 0,
                                  autoPlay: true,
                                  height: 170,
                                  onPageChanged: (int i,
                                      carouselPageChangedReason) {
                                    setState(() {
                                      _index = i;
                                    });
                                  })),
                        );
                      },
                    ),
                ],
              ),
            ), //Firestore Slider
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

                            /* final List<String> images =
                              List.from(document['urls']);

                              List<GridTile> newGridTile = [];

                              images.forEach((image) {
                                newGridTile.add(GridTile(
                                  child: Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                  ),
                                ));
                              });*/

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
            ),
          ],
        ),
      ),
    );
  }
}
