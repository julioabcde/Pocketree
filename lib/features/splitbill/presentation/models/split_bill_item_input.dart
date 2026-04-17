class SplitBillItemInput {
  String name;
  double price;
  int qty;
  bool isFromOCR;

  SplitBillItemInput({
    required this.name,
    required this.price,
    this.qty = 1,
    this.isFromOCR = false,
  });
}
