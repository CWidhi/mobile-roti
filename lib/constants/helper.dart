String priceTypeLabel(String value) {
  switch (value) {
    case "pabrik":
      return "Harga Pabrik";
    // case "dist_pasar":
    //   return "Harga ke Pasar";
    case "ritel":
      return "Harga Ritel";
    case "saller_toko":
      return "Harga di Toko";
    case "saller_pasar":
      return "Harga di Pasar";
    case "dist_saller_pasar":
      return "Harga ke Pasar";
    case "dist_saller_toko":
      return "Harga ke Toko";
    case "bs_toko":
      return "BS Toko";
    case "bs_pasar":
      return "BS Pasar";
    default:
      return value;
  }
}

enum UserRole {
  admin,
  salles,
}

String priceTypeLabelInput(String value) {
  switch (value) {
    case "pabrik":
      return "Harga Pabrik";
    case "ritel":
      return "Harga Ritel";
    case "saller_toko":
      return "Harga di Toko";
    case "saller_pasar":
      return "Harga di Pasar";
    case "dist_saller_pasar":
      return "Harga ke Pasar";
    case "dist_saller_toko":
      return "Harga ke Toko";
    case "bs_toko":
      return "BS Toko";
    case "bs_pasar":
      return "BS Pasar";
    default:
      return value;
  }
}

const List<String> PRICE_TYPE = [
  "pabrik",
  "ritel",
  "saller_toko",
  "saller_pasar",
  "dist_saller_pasar",
  "dist_saller_toko",
  "bs_toko",
  "bs_pasar",
];


const List<String> PRODUCT_TYPE = [
  "Ball",
  "Untai",
  "Karton",
  "Tali",
  "Plastik",
  "Satuan",
];

const List<String> STORE_TYPE = [
  "Toko",
  "Pasar",
];

const List<String> ITEM_TYPE = [
  "bs",
  "retur",
];
