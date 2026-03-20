class OrderFormItem {
  int? productId;
  String? unit;
  int qty;
  bool marketStore;

  OrderFormItem({
    this.productId,
    this.unit,
    this.qty = 1,
    this.marketStore = false,
  });

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "unit": unit,
        "qty": qty,
        "market_store": marketStore,
      };
}
