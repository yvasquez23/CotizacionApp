import 'package:cotizacion_app/screens/clients_screes.dart';
import 'package:cotizacion_app/screens/products_screens.dart';
import 'package:cotizacion_app/screens/qoute_screes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_MenuItem> _menuItems = [
    _MenuItem(icon: Icons.dashboard_outlined, label: 'Inicio', index: 0),
    _MenuItem(icon: Icons.inventory_2_outlined, label: 'Productos', index: 1),
    _MenuItem(icon: Icons.people_outline, label: 'Clientes', index: 2),
    _MenuItem(
      icon: Icons.request_quote_outlined,
      label: 'Cotización',
      index: 3,
    ),
  ];

  List<Widget> get _screens => [
    _DashboardPage(
      onNavigate: (index) {
        setState(() => _selectedIndex = index);
      },
    ),
    const ProductsScreen(),
    const ClientsScreen(),
    const QuoteScreen(),
  ];

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_menuItems[_selectedIndex].label),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                accountName: const Text(
                  'Cotización App',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.receipt_long, color: Colors.blue, size: 32),
                ),
              ),

              // Items del menú
              ..._menuItems.map((item) {
                final isSelected = _selectedIndex == item.index;
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      item.icon,
                      color: isSelected ? Colors.blue : Colors.grey[600],
                      size: 22,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.grey[800],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedIndex = item.index);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),

              const Expanded(child: SizedBox()),

              const Divider(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 22,
                  ),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  onTap: _logout,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final int index;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class _DashboardPage extends StatelessWidget {
  final Function(int) onNavigate;
  const _DashboardPage({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona una opción del menú para comenzar.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _QuickCard(
                icon: Icons.inventory_2_outlined,
                label: 'Productos',
                color: Colors.blue,
                onTap: () => onNavigate(1),
              ),
              _QuickCard(
                icon: Icons.people_outline,
                label: 'Clientes',
                color: Colors.green,
                onTap: () => onNavigate(2),
              ),
              _QuickCard(
                icon: Icons.request_quote_outlined,
                label: 'Cotización',
                color: Colors.orange,
                onTap: () => onNavigate(3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
