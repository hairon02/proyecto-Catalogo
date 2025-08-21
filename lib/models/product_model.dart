class ProductModel {
  int id;
  String title;
  String description;
  double price;
  String category;
  String image;
  int rating;

  //constructor
  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory ProductModel.fromJSON(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      category: json['category'],
      image: json['image'],
      rating:
          json['rating'] is Map
              ? (json['rating']['rate'] ?? 0).round()
              : (json['rating'] ?? 0),
    );
  }

  // conversor a JSON
  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'rating': rating,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, title: $title, price: $price, category: $category)';
  }
}
