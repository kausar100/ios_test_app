import 'package:isar/isar.dart';

part 'cart_item.g.dart';

@collection
class CartItem {
  Id id = Isar.autoIncrement;

  late int productId;
  late String title;
  late double price;
  late String image;
  late int quantity;

  CartItem();

  CartItem.create({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  });
}
