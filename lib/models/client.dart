class Client {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String address;

  Client({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toMap() => {
    'name':    name,
    'email':   email,
    'phone':   phone,
    'address': address,
  };

  factory Client.fromMap(String id, Map<String, dynamic> map) => Client(
    id:      id,
    name:    map['name']    ?? '',
    email:   map['email']   ?? '',
    phone:   map['phone']   ?? '',
    address: map['address'] ?? '',
  );
}