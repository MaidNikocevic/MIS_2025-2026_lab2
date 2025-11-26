class MealShort {
  final String id;
  final String name;
  final String thumbnail;

  MealShort({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  factory MealShort.fromJson(Map<String, dynamic> json) {
    return MealShort(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      thumbnail: json['strMealThumb'] ?? '',
    );
  }
}

class MealDetail {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final String youtube;
  final Map<String, String> ingredients;

  MealDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    required this.youtube,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    // extract up to 20 ingredients
    final Map<String, String> ingredients = {};
    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ing != null && (ing as String).trim().isNotEmpty) {
        ingredients[ing.toString()] = measure?.toString() ?? '';
      }
    }

    return MealDetail(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      thumbnail: json['strMealThumb'] ?? '',
      youtube: json['strYoutube'] ?? '',
      ingredients: ingredients,
    );
  }
}