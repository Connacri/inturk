import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import 'home.dart';

class conbb extends StatefulWidget {
  const conbb({Key? key}) : super(key: key);

  @override
  _conbbState createState() => _conbbState();
}

class _conbbState extends State<conbb> {
  Future<QuerySnapshot> _TopAgenceFuture = FirebaseFirestore.instance
      .collection('Products')
      .where('category', isEqualTo: 'Agence')
      .limit(3)
      .get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
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
            ),
            PaginateFirestore(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilderType: PaginateBuilderType.gridView,
              //isLive: true,
              query: FirebaseFirestore.instance
                  .collection('Products')
                  .orderBy('createdAt', descending: true),
              itemBuilder: (context, documentSnapshots, index) {
                final _data = documentSnapshots[index].data() as Map?;
                return _data == null
                    ? const Text('Error in data')
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: InkWell(
                            child: GridTile(
                              footer: Container(
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
                                    colors: [Colors.transparent, Colors.black],
                                  ).createShader(Rect.fromLTRB(
                                      0, 0, rect.width, rect.height));
                                },
                                blendMode: BlendMode.darken,
                                child: CachedNetworkImage(
                                  imageUrl: _data['themb'],
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
