import 'package:flutter/material.dart';
import 'package:frontend_roti/models/product.dart';
import 'package:frontend_roti/services/products/productServices.dart';
import 'package:frontend_roti/constants/helper.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/screens/product/updateProductScreen.dart';
import 'package:frontend_roti/screens/product/price/priceListScreen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isAdmin = false;
  bool loadingUser = true;
  Product? product;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final me = await UserService.getMe();

    if (!mounted) return;

    setState(() {
      isAdmin = me?["is_staff"] == true;
      loadingUser = false;
    });
  }

  // Fungsi refresh product
  Future<void> _refreshProduct() async {
    setState(() {
      product = null; // sementara loading
    });

    try {
      final updatedProduct = await ProductService.getProductDetail(
        widget.productId,
      );
      if (!mounted) return;
      setState(() {
        product = updatedProduct;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat produk: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Fungsi build content
  Widget _buildContent(Product product) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      body: ListView(
        children: [_ProductImage(product.image), _ProductInfo(product)],
      ),
      bottomNavigationBar: isAdmin
          ? _BottomBar(
              isAdmin: isAdmin,
              productId: widget.productId,
              productName: product.name,
              productImageId: product.image,
              onUpdate: _refreshProduct, // callback untuk refresh
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: product == null
          ? FutureBuilder<Product>(
              future: ProductService.getProductDetail(widget.productId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    loadingUser) {
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

                // Simpan ke state
                product = snapshot.data!;

                return _buildContent(product!);
              },
            )
          : _buildContent(product!),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String image;

  const _ProductImage(this.image);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(image, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final Product product;

  const _ProductInfo(this.product);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Stock ${product.productStock.stock} ${product.productType}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7643),
            ),
          ),
          const Divider(height: 32),
          const Text(
            "Daftar Harga",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          ...product.prices.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    priceTypeLabel(p.typePrice),
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    "Rp ${p.price}/${p.qty} ${p.unit}",
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isAdmin;
  final int productId;
  final String productName;
  final String productImageId;
  final VoidCallback onUpdate; // callback untuk refresh

  const _BottomBar({
    required this.isAdmin,
    required this.productId,
    required this.productName,
    required this.productImageId,
    required this.onUpdate,
  });

  static const primaryColor = Color(0xFFFF7643);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: isAdmin ? _adminActions(context) : _userAction(context),
      ),
    );
  }

  /// ================= USER =================
  Widget _userAction(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFECDF),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      onPressed: () {},
      child: const Text(
        "Add To Cart",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF7643),
        ),
      ),
    );
  }

  /// ================= ADMIN =================
  Widget _adminActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFECDF),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateProductScreen(
                        productId: productId,
                        name: productName,
                        imageId: productImageId,
                      ),
                    ),
                  );

                  if (result == true) {
                    onUpdate(); // refresh product setelah update
                  }
                },
                icon: const Icon(Icons.edit, color: Color(0xFFFF7643)),
                label: const Text(
                  "Edit Produk",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7643),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: const BorderSide(color: primaryColor),
                  foregroundColor: const Color(0xFFFFECDF),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductPriceScreen(productId: productId),
                    ),
                  );
                },
                icon: const Icon(Icons.price_change, color: Color(0xFFFF7643)),
                label: const Text(
                  "Kelola Harga",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7643),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFECDF),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _showAdjustStockModal(context, productId: productId),
            icon: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFFFF7643),
            ),
            label: const Text(
              "Adjust Stock",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7643),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFECDF)),
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.delete_outline, color: Color(0xFFFF7643)),
          label: const Text(
            "Hapus Produk",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF7643),
            ),
          ),
        ),
      ],
    );
  }

  /// ================= CONFIRM DELETE =================
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Hapus Produk",
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          "Produk akan dihapus permanen.\nTindakan ini tidak dapat dibatalkan.",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);

              try {
                await ProductService.deleteProduct(productId);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Produk berhasil dihapus"),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context, true); // kembalikan ke screen sebelumnya
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAdjustStockModal(
    BuildContext context, {
    required int productId,
  }) async {
    final qtyController = TextEditingController();
    String selectedUnit = "Ball";
    bool isLoading = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Adjust Stock",
                style: TextStyle(color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Qty",
                      hintText: "Masukkan jumlah stock",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    style: const TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: "Unit",
                      labelStyle: const TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    items: PRODUCT_TYPE.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(
                          unit,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                selectedUnit = value;
                              });
                            }
                          },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(dialogContext, false);
                        },
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.black),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7643),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final qty = int.tryParse(qtyController.text);

                          if (qty == null || qty <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Qty harus berupa angka lebih dari 0",
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            await ProductService.adjustStock(
                              productId: productId,
                              stock: qty,
                              unit: selectedUnit,
                            );

                            if (context.mounted) {
                              Navigator.pop(dialogContext, true);
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      "Exception: ",
                                      "",
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    qtyController.dispose();

    if (result == true) {
      onUpdate();
    }
  }
}
