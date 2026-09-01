class OrderFormItem {
  int? productId;
  String? unit;
  int qty;
  bool marketStore;
  bool retail;

  OrderFormItem({
    this.productId,
    this.unit,
    this.qty = 1,
    this.marketStore = false,
    this.retail = false,
  });

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "unit": unit,
        "qty": qty,
        "market_store": marketStore,
        "retail": retail,
      };
}
