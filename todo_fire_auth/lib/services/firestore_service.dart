import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _colleccio {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db
      .collection('usuaris')
      .doc(uid)
      .collection('tasques');
  }

  Stream<QuerySnapshot> obtenirTasques() {
    return _colleccio
      .orderBy('dataCreacio', descending: true)
      .snapshots();
  }

  Future<void> afegirTasca(String titol) async {
    await _colleccio.add({
      'titol': titol,
      'estaCompletada': false,
      'dataCreacio': FieldValue.serverTimestamp(),
    });
  }

  Future<void> canviarEstat(
    String idDoc, bool estatActual) async {
    await _colleccio.doc(idDoc).update({
      'estaCompletada': !estatActual,
    });
  }

  Future<void> esborrarTasca(String idDoc) async {
    await _colleccio.doc(idDoc).delete();
  }
}