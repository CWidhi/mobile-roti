import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_roti/models/product.dart';
import 'package:frontend_roti/services/products/productServices.dart';
import 'package:frontend_roti/screens/product/detailProductScreen.dart';
import 'package:frontend_roti/screens/product/productCard.dart';
import 'package:frontend_roti/screens/product/addProductScreen.dart';
import 'package:frontend_roti/services/auth/userService.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool isAdmin = false;
  bool isLoadingUser = true;

  final searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  List<Product> products = [];
  String? nextPageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    fetchProducts();

    // Scroll listener untuk pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          nextPageUrl != null) {
        fetchProducts(url: nextPageUrl);
      }
    });
  }

  // Cek apakah user admin
  Future<void> fetchUserRole() async {
    try {
      final user = await UserService.getMe();
      setState(() {
        isAdmin = user?["is_staff"] == true;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  // Search dengan debounce
  void _onSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        products.clear();
        nextPageUrl = null;
        fetchProducts(search: value);
      });
    });
  }

  // Fetch products dari BE
  Future<void> fetchProducts({String? search, String? url}) async {
    setState(() => isLoading = true);

    try {
      final response =
          await ProductService.getProducts(search: search, url: url);

      setState(() {
        nextPageUrl = response['next'];
        final List<Product> newProducts = (response['results'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
        products.addAll(newProducts);
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _refresh() {
    setState(() {
      products.clear();
      nextPageUrl = null;
      fetchProducts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("All Products"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        ),

      // FAB hanya untuk admin
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              heroTag: null,
              backgroundColor: const Color(0xFFFF7643),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
                if (result == true) _refresh();
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: "Cari produk...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product Grid
              Expanded(
                child: products.isEmpty && isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        controller: _scrollController,
                        itemCount: products.length + 1, // +1 untuk loader
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 0.7,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          if (index < products.length) {
                            return ProductCard(
                              product: products[index],
                              onPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailsScreen(
                                        productId: products[index].id),
                                  ),
                                ).then((_) => _refresh());
                              },
                            );
                          } else {
                            return Visibility(
                              visible: isLoading,
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
