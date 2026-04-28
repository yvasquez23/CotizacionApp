class QuoteItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;

  QuoteItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
    'productId':   productId,
    'productName': productName,
    'price':       price,
    'quantity':    quantity,
  };

  factory QuoteItem.fromMap(Map<String, dynamic> map) => QuoteItem(
    productId:   map['productId']   ?? '',
    productName: map['productName'] ?? '',
    price:       (map['price']      ?? 0).toDouble(),
    quantity:    (map['quantity']   ?? 1).toInt(),
  );
}

class Quote {
  final String? id;
  final String clientId;
  final String clientName;
  final List<QuoteItem> items;
  final DateTime createdAt;
  final String status;

  Quote({
    this.id,
    required this.clientId,
    required this.clientName,
    required this.items,
    required this.createdAt,
    this.status = 'pendiente',
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  Map<String, dynamic> toMap() => {
    'clientId':   clientId,
    'clientName': clientName,
    'items':      items.map((i) => i.toMap()).toList(),
    'createdAt':  createdAt.toIso8601String(),
    'status':     status,
    'total':      total,
  };

  factory Quote.fromMap(String id, Map<String, dynamic> map) => Quote(
    id:         id,
    clientId:   map['clientId']   ?? '',
    clientName: map['clientName'] ?? '',
    items:      (map['items'] as List<dynamic>? ?? [])
        .map((i) => QuoteItem.fromMap(i as Map<String, dynamic>))
        .toList(),
    createdAt:  DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    status:     map['status'] ?? 'pendiente',
  );
}