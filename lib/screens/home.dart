import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_roti/screens/report/stockReportScreen.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/services/products/productServices.dart';
import 'package:frontend_roti/constants/svgs.dart';
import 'package:frontend_roti/screens/product/detailProductScreen.dart';
import 'package:frontend_roti/screens/product/productCard.dart';
import 'package:frontend_roti/models/product.dart';
import 'package:frontend_roti/screens/product/productScreen.dart';
import 'package:frontend_roti/screens/rute/ruteListScreen.dart';
import 'package:frontend_roti/screens/supplier/supplierListScreen.dart';
import 'package:frontend_roti/services/rute/ruteService.dart';
import 'package:frontend_roti/models/rute.dart';
import 'package:frontend_roti/screens/rute/ruteDetailScreen.dart';
import 'package:frontend_roti/screens/payment/paymentScreen.dart';
import 'package:frontend_roti/screens/report/cashflowReportScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await UserService.getMe();
      setState(() {
        isAdmin = user?["is_staff"] == true;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const HomeHeader(),
              if (isAdmin) Categories(isAdmin: isAdmin),
              TrackLine(isAdmin: isAdmin),
              const SizedBox(height: 20),
              const PopularProducts(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: SearchField()),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        onChanged: (value) {},
        decoration: InputDecoration(
          filled: true,
          hintStyle: const TextStyle(color: Color(0xFF757575)),
          fillColor: const Color(0xFF979797).withOpacity(0.1),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          hintText: "Search product",
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class IconBtnWithCounter extends StatelessWidget {
  const IconBtnWithCounter({
    Key? key,
    required this.svgSrc,
    this.numOfitem = 0,
    required this.press,
  }) : super(key: key);

  final String svgSrc;
  final int numOfitem;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF979797).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.string(svgSrc),
          ),
          if (numOfitem != 0)
            Positioned(
              top: -3,
              right: 0,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4848),
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colors.white),
                ),
                child: Center(
                  child: Text(
                    "$numOfitem",
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class Categories extends StatelessWidget {
  final bool isAdmin;
  const Categories({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final allCategories = [
      {
        "icon": boxTruckIcon,
        "text": "Supplier",
        "adminOnly": true,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SupplierListScreen(),
            ),
          );
        }
      },
      {
        "icon": dollarIcon,
        "text": "Pembayaran",
        "adminOnly": false,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PaymentListScreen(),
            ),
          );
        }
      },
      {
        "icon": stockReportIcon,
        "text": "Laporan Stok",
        "adminOnly": false,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StockMovementScreen(),
            ),
          );
        },
      },
      {
        "icon": financeReportIcon,
        "text": "Laporan Keuntungan",
        "adminOnly": false,
        "onTap": () {
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CashflowScreen(),
            ),
          );
        },
      },
    ];

    final categories = allCategories.where((c) {
      if (c["adminOnly"] == true && !isAdmin) return false;
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // jumlah kolom (HP biasanya 4)
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return CategoryCard(
            icon: categories[index]["icon"] as String,
            text: categories[index]["text"] as String,
            press: categories[index]["onTap"] as VoidCallback,
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.press,
  }) : super(key: key);

  final String icon, text;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECDF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.string(icon),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2, 
            overflow: TextOverflow.ellipsis, 
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TrackLine extends StatelessWidget {
  final bool isAdmin;

  const TrackLine({
    Key? key,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Tracking Line",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RouteLineListScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        /// CONTENT
        FutureBuilder<List<RouteLine>>(
          future: RouteLineService.getRouteLinesHome(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final routes = snapshot.data!;

            if (routes.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Belum ada tracking line",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...routes.map(
                    (route) => SpecialOfferCard(
                      image: "assets/img/maps.png",
                      category: route.name, // 🔥 nama route
                      numOfBrands: route.stores.length, // 🔥 jumlah store
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RouteLineDetailScreen(
                                route: route, isAdmin: isAdmin),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class SpecialOfferCard extends StatelessWidget {
  const SpecialOfferCard({
    Key? key,
    required this.category,
    required this.image,
    required this.numOfBrands,
    required this.press,
  }) : super(key: key);

  final String category, image;
  final int numOfBrands;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: GestureDetector(
        onTap: press,
        child: SizedBox(
          width: 150,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.black38,
                        Colors.black26,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: "$category\n",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: "$numOfBrands Store")
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.title,
    required this.press,
  }) : super(key: key);

  final String title;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: press,
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text("See more"),
        ),
      ],
    );
  }
}

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = ProductService.getProductsHome();
  }

  void _refreshProducts() {
    setState(() {
      _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Products",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductsScreen(),
                ),
              );
            },
          ),
        ),
        FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Produk belum tersedia"),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...products.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ProductCard(
                        product: product,
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                productId: product.id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Tambahkan tombol refresh di paling kanan
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, size: 30),
                      onPressed: _refreshProducts,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
