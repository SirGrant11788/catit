class ItemAttribute {
  String name;
  dynamic value;

  ItemAttribute({this.name, this.value});

  ItemAttribute.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value
    };
  }
}