import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  static Database _database;
  static Future<Database> getInstance() async {
    if (_database == null) {
      _database = Database._();
    }
    return _database;
  }

  Database._();

  dynamic getCollection(String name) {
    if(!isConnected())return false;
    return FirebaseFirestore.instance.collection(name).snapshots();
  }

  dynamic getFieldOf(dynamic doc, int index, String fieldName) {
    return doc.data.docs[index][fieldName];
  }

  Future<bool> updateDoc(dynamic doc, Function updater) async  {
    if(!isConnected()) return false;
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnapshot = await transaction.get(doc.reference);
      transaction.update(freshSnapshot.reference, updater(freshSnapshot));
    });
    return true;
  }
  bool isConnected(){
    return true;
  }
}