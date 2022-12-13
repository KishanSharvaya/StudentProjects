class ProductCartModel {
  int id;
  int ProductID;
  double Quantity, Amount, NetAmount;
  String ProductName, ProductImage;

  ProductCartModel(this.ProductID, this.Quantity, this.Amount, this.NetAmount,
      this.ProductName, this.ProductImage,
      {this.id});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProductID'] = this.ProductID;
    data['Quantity'] = this.Quantity;
    data['Amount'] = this.Amount;
    data['NetAmount'] = this.NetAmount;
    data['ProductName'] = this.ProductName;
    data['ProductImage'] = this.ProductImage;

    return data;
  }

  @override
  String toString() {
    return 'InWardProductModel{id: $id, ProductID: $ProductID, Quantity: $Quantity, Amount: $Amount, NetAmount: $NetAmount, ProductName: $ProductName, ProductImage: $ProductImage}';
  }
}
