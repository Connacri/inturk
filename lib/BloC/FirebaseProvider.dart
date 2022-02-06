import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseProvider {
  Future<List<DocumentSnapshot>> fetchFirstList() async {
    return (await FirebaseFirestore.instance
        .collection("movies")
        .orderBy("rank")
        .limit(10)
        .get())
        .docs;
  }

  Future<List<DocumentSnapshot>> fetchNextList(
      List<DocumentSnapshot> documentList) async {
    return (await FirebaseFirestore.instance
        .collection("movies")
        .orderBy("rank")
        .startAfterDocument(documentList[documentList.length - 1])
        .limit(10)
        .get())
        .docs;
  }
}