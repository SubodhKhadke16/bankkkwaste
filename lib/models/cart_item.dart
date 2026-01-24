import 'product.dart';

class CartItem {

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product(
          id: json['productId'] ?? '',
          name: json['productName'] ?? '',
          description: json['productDescription'] ?? '',
          price: (json['productPrice'] ?? 0).toDouble(),
          imageUrl: json['productImageUrl'] ?? '',
          category: json['productCategory'] ?? '',
          stock: json['productStock'] ?? 0,
        ),
        quantity: json['quantity'] ?? 1,
      );
  CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  int quantity;

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'productName': product.name,
        'productPrice': product.price,
        'productImageUrl': product.imageUrl,
        'productDescription': product.description,
        'productCategory': product.category,
        'productStock': product.stock,
        'quantity': quantity,
      };
}
