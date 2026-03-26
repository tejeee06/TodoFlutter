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
  final TextEditingController _controlador = TextEditingController();

  void _mostrarDialegAfegirTasca() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nova Tasca',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controlador,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Què necessites fer?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onSubmitted: (value) => _guardarTasca(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _guardarTasca,
              child: const Text('Afegir Tasca', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _guardarTasca() {
    if (_controlador.text.trim().isNotEmpty) {
      _firestore.afegirTasca(_controlador.text.trim());
      _controlador.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuari = FirebaseAuth.instance.currentUser!;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Les meves tasques',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary, 
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              usuari.email ?? '',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.primary),
            onPressed: () => _auth.logout(),
            tooltip: 'Tancar sessió',
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.obtenirTasques(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No tens cap tasca pendent',
                    style: TextStyle(color: Colors.grey[500], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final tasques = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
            itemCount: tasques.length,
            itemBuilder: (context, index) {
              final doc = tasques[index];
              final completada = doc['estaCompletada'] as bool;
              
              return Card(
                elevation: completada ? 0 : 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: completada ? Colors.grey.shade300 : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      shape: const CircleBorder(), 
                      value: completada,
                      onChanged: (_) => _firestore.canviarEstat(doc.id, completada),
                    ),
                  ),
                  title: Text(
                    doc['titol'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: completada ? FontWeight.normal : FontWeight.w500,
                      color: completada ? Colors.grey : Colors.black87,
                      decoration: completada ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _firestore.esborrarTasca(doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialegAfegirTasca,
        icon: const Icon(Icons.add),
        label: const Text('Nova Tasca', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}