import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini E-Commerce',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ProductListScreen(),
    const CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}

// Cart item model
class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem(this.product, {this.quantity = 1});
}

// Global cart (simple in-memory for demo)
List<CartItem> cartItems = [];

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/products/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> productList = data is List ? data : data['results'] ?? [];

        setState(() {
          products = productList;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception: $e';
        isLoading = false;
      });
    }
  }

  void addToCart(Map<String, dynamic> product) {
    final existing = cartItems.firstWhere(
      (item) => item.product['id'] == product['id'],
      orElse: () => CartItem(product, quantity: 0),
    );

    if (existing.quantity == 0) {
      cartItems.add(existing);
    }
    existing.quantity++;

    setState(() {}); // refresh UI

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${product['name'] ?? 'item'} to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: product['image'] != null && product['image'].isNotEmpty
                                ? Image.network(product['image'], width: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                                : const Icon(Icons.image_not_supported, size: 50),
                            title: Text(product['name'] ?? 'Unnamed'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Price: \$${product['price'] ?? '0.00'}'),
                                Text('Stock: ${product['stock'] ?? 0}'),
                                Text('Category: ${product['category']?['name'] ?? 'None'}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                              onPressed: () => addToCart(product),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchProducts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get total => cartItems.fold(0.0, (sum, item) {
        final price = double.tryParse(item.product['price'].toString()) ?? 0.0;
        return sum + (item.quantity * price);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final price = double.tryParse(item.product['price'].toString()) ?? 0.0;

                      return ListTile(
                        leading: const Icon(Icons.shopping_bag),
                        title: Text(item.product['name'] ?? 'Item'),
                        subtitle: Text('Qty: ${item.quantity} × \$${price.toStringAsFixed(2)}'),
                        trailing: Text('Total: \$${ (item.quantity * price).toStringAsFixed(2) }'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grand Total: \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                     class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  String message = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void placeOrder() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => message = 'Please enter your full name');
      return;
    }

    // Dummy order creation (just clear cart for demo)
    setState(() {
      cartItems.clear();
      message = 'Order placed successfully as guest: ${_nameController.text}';
    });

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guest Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: placeOrder,
              child: const Text('Place Order'),
            ),
            const SizedBox(height: 20),
            if (message.isNotEmpty)
              Text(message, style: TextStyle(color: message.contains('success') ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}
  }
}