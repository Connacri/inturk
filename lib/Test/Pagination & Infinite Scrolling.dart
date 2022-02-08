import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

import '../home.dart';

class Pagination_Infinite_Scrolling extends StatefulWidget {
  const Pagination_Infinite_Scrolling({Key? key}) : super(key: key);

  @override
  _Pagination_Infinite_ScrollingState createState() =>
      _Pagination_Infinite_ScrollingState();
}

class _Pagination_Infinite_ScrollingState
    extends State<Pagination_Infinite_Scrolling> {
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
        body: FirestoreQueryBuilder(
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
            })
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
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              // Expanded(
              //     child: Image.network(
              //   post.themb,
              //   fit: BoxFit.cover,
              //   width: double.infinity,
              // )),
              //

              Card(
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
                            post.category.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              fontFamily: 'Oswald',
                            ),
                          ),
                          subtitle: Text(
                            post.code,
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
              ),
              SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            post.item.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'Oswald',
                            ),
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          post.price.toUpperCase() + '.00 DZD',
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
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          post.likes.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            fontFamily: 'Oswald',
                          ),
                        ),
                      ),
                    ),
                    //Icon(Icons.accessibility),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
