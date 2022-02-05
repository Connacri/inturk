import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';


class conbb extends StatefulWidget {
  const conbb({Key? key}) : super(key: key);

  @override
  _conbbState createState() => _conbbState();
}

class _conbbState extends State<conbb> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  PaginateFirestore(
        shrinkWrap: true,
        //physics: NeverScrollableScrollPhysics(),
        itemBuilderType: PaginateBuilderType.gridView,
        //isLive: true,
        query: FirebaseFirestore.instance
            .collection('Products')
            .orderBy('createdAt', descending: true),
        itemBuilder: (context, documentSnapshots, index) {
          final _data = documentSnapshots[index].data() as Map?;
          return _data == null ? const Text('Error in data') : Padding(
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
                      ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.darken,
                    child: CachedNetworkImage(
                      imageUrl: _data['themb'],
                      errorWidget: (context, url, error) => Icon(Icons.error),
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




    );
  }
}
