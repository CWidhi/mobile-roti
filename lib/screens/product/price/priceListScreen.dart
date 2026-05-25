import 'package:flutter/material.dart';
import 'package:frontend_roti/models/productPrice.dart';
import 'package:frontend_roti/services/products/priceService.dart';
import 'package:frontend_roti/constants/helper.dart';
import 'package:frontend_roti/screens/product/price/priceCreateScreen.dart';
import 'package:frontend_roti/screens/product/price/priceUpdateScreen.dart';

class ProductPriceScreen extends StatefulWidget {
  final int productId;

  const ProductPriceScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductPriceScreen> createState() => _ProductPriceScreenState();
}

class _ProductPriceScreenState extends State<ProductPriceScreen> {
  static const primaryColor = Color(0xFFFF7643);

  late Future<List<ProductPrice>> _pricesFuture;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  void _loadPrices() {
    _pricesFuture = PriceService.getProductsPrice(widget.productId);
  }

  void _refreshPrices() {
    setState(() {
      _loadPrices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        title: const Text(
          "Daftar Harga",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<ProductPrice>>(
        future: _pricesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final prices = snapshot.data!;

          if (prices.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada harga",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshPrices(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: prices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final price = prices[index];
                return _PriceCard(
                  price: price,
                  productId: widget.productId,
                  onUpdated: _refreshPrices,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateProductPriceScreen(
                productId: widget.productId,
              ),
            ),
          );

          if (result == true) {
            _refreshPrices(); // 🔥 reload list harga
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// =======================================================
/// PRICE CARD
/// =======================================================
class _PriceCard extends StatelessWidget {
  final ProductPrice price;
  final int productId;
  final VoidCallback onUpdated;

  const _PriceCard({
    required this.price,
    required this.productId,
    required this.onUpdated,
  });

  static const primaryColor = Color(0xFFFF7643);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                priceTypeLabel(price.typePrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${price.qty} ${price.unit}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          /// RIGHT
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rp ${price.price}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: primaryColor,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateProductPriceScreen(
                        productId: productId,
                        priceId: price.id,
                      ),
                    ),
                  );

                  if (result == true) {
                    onUpdated(); // 🔥 trigger refresh di parent
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
