import 'package:cotizacion_app/models/produc.dart';
import 'package:cotizacion_app/models/qoute.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class QuoteFormScreen extends StatefulWidget {
  const QuoteFormScreen({super.key});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  Client? _selectedClient;
  final List<QuoteItem> _items = [];
  bool _isSaving = false;

  double get _total => _items.fold(0, (s, i) => s + i.subtotal);

  Future<void> _selectClient() async {
    final clients = await FirebaseFirestore.instance
        .collection('clients')
        .orderBy('name')
        .get();

    if (!mounted) return;

    final selected = await showDialog<Client>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccionar cliente'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: clients.docs.map((doc) {
              final c = Client.fromMap(doc.id, doc.data());
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: Text(
                    c.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                title: Text(c.name),
                subtitle: Text(c.email),
                onTap: () => Navigator.pop(ctx, c),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() => _selectedClient = selected);
    }
  }

  Future<void> _addProduct() async {
    final products = await FirebaseFirestore.instance
        .collection('products')
        .orderBy('name')
        .get();

    if (!mounted) return;

    final selected = await showDialog<Product>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccionar producto'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: products.docs.map((doc) {
              final p = Product.fromMap(doc.id, doc.data());
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined,
                    color: Colors.blue),
                title: Text(p.name),
                subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
                onTap: () => Navigator.pop(ctx, p),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        final exists =
            _items.indexWhere((i) => i.productId == selected.id);
        if (exists >= 0) {
          _items[exists].quantity++;
        } else {
          _items.add(QuoteItem(
            productId:   selected.id!,
            productName: selected.name,
            price:       selected.price,
            quantity:    1,
          ));
        }
      });
    }
  }

  Future<void> _saveQuote() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un cliente')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un producto')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final quote = Quote(
      clientId:   _selectedClient!.id!,
      clientName: _selectedClient!.name,
      items:      _items,
      createdAt:  DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('quotes')
        .add(quote.toMap());

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cotización guardada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva cotización'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      // ← Botones fijos abajo sin chocar con la barra del celular
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add),
                label: const Text('Agregar producto'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveQuote,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // Selector de cliente
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              onTap: _selectClient,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedClient?.name ??
                            'Toca para seleccionar cliente',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedClient != null
                              ? Colors.black
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          // Lista de productos agregados
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'Sin productos aún',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca "Agregar producto" para comenzar',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)} c/u',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              // Controles de cantidad
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle_outline),
                                color: Colors.orange,
                                onPressed: () => setState(() {
                                  if (item.quantity > 1) {
                                    item.quantity--;
                                  } else {
                                    _items.removeAt(index);
                                  }
                                }),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.add_circle_outline),
                                color: Colors.orange,
                                onPressed: () =>
                                    setState(() => item.quantity++),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Total
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                  top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}