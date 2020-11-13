import 'package:cat_it/models/ItemAttribute.dart';

class Item {
  int id;
  String name;
  String description;
  String category;
  List<ItemAttribute> attributes;

  Item({this.id, this.name, this.description, this.category, this.attributes});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    category = json['category'];
    attributes = json['attributes'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'attributes': attributes
    };
  }
}
