import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _controlador =
    TextEditingController();

  @override
  Widget build(BuildContext context) {
    final usuari = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasques de ${usuari.email}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.logout(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controlador,
                    decoration: const InputDecoration(
                      hintText: 'Nova tasca...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_controlador.text.isNotEmpty) {
                      _firestore.afegirTasca(_controlador.text);
                      _controlador.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.obtenirTasques(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final tasques = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tasques.length,
                  itemBuilder: (context, index) {
                    final doc = tasques[index];
                    final completada =
                      doc['estaCompletada'] as bool;
                    return ListTile(
                      title: Text(
                        doc['titol'],
                        style: TextStyle(
                          decoration: completada
                            ? TextDecoration.lineThrough
                            : null,
                        ),
                      ),
                      leading: Checkbox(
                        value: completada,
                        onChanged: (_) =>
                          _firestore.canviarEstat(
                            doc.id, completada),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                          color: Colors.red),
                        onPressed: () =>
                          _firestore.esborrarTasca(doc.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}