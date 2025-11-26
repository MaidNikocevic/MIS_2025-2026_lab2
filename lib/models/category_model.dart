class CategoryModel {
  final String id;
  final String name;
  final String thumbnail;
  final String description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? '',
      thumbnail: json['strCategoryThumb'] ?? '',
      description: json['strCategoryDescription'] ?? '',
    );
  }
}