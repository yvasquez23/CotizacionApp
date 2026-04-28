import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clients')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar clientes'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = snapshot.data!.docs
              .map((doc) => Client.fromMap(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  ))
              .toList();

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No hay clientes aún',
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final c = clients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(c.name,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (c.email.isNotEmpty)
                        Row(children: [
                          const Icon(Icons.email_outlined,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(c.email,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),
                        ]),
                      if (c.phone.isNotEmpty)
                        Row(children: [
                          const Icon(Icons.phone_outlined,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(c.phone,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),
                        ]),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _showClientDialog(context, client: c),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClientDialog(context),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Nuevo cliente'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showClientDialog(BuildContext context, {Client? client}) {
    final nameCtrl    = TextEditingController(text: client?.name    ?? '');
    final emailCtrl   = TextEditingController(text: client?.email   ?? '');
    final phoneCtrl   = TextEditingController(text: client?.phone   ?? '');
    final addressCtrl = TextEditingController(text: client?.address ?? '');
    final formKey     = GlobalKey<FormState>();
    final isEditing   = client != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Editar cliente' : 'Nuevo cliente'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(nameCtrl,    'Nombre',    Icons.person_outline),
                const SizedBox(height: 12),
                _buildField(emailCtrl,   'Correo',    Icons.email_outlined,
                    isEmail: true),
                const SizedBox(height: 12),
                _buildField(phoneCtrl,   'Teléfono',  Icons.phone_outlined,
                    isPhone: true),
                const SizedBox(height: 12),
                _buildField(addressCtrl, 'Dirección', Icons.location_on_outlined,
                    required: false),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          if (isEditing)
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('clients')
                    .doc(client.id)
                    .delete();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Eliminar',
                  style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = Client(
                name:    nameCtrl.text.trim(),
                email:   emailCtrl.text.trim(),
                phone:   phoneCtrl.text.trim(),
                address: addressCtrl.text.trim(),
              );
              final col =
                  FirebaseFirestore.instance.collection('clients');
              if (isEditing) {
                await col.doc(client.id).update(data.toMap());
              } else {
                await col.add(data.toMap());
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              isEditing ? 'Guardar' : 'Crear',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isEmail   = false,
    bool isPhone   = false,
    bool required  = true,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
              ? TextInputType.phone
              : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (required && (v == null || v.isEmpty)) return 'Campo requerido';
        if (isEmail && v!.isNotEmpty && !v.contains('@'))
          return 'Correo inválido';
        return null;
      },
    );
  }
}