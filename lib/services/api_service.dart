import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/meal_model.dart';

class ApiService {
  static const String base = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<CategoryModel>> fetchCategories() async {
    final url = Uri.parse('$base/categories.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List categories = data['categories'] ?? [];
      return categories.map((c) => CategoryModel.fromJson(c)).toList();
    } else {
      throw Exception('Error loading categories');
    }
  }

  static Future<List<MealShort>> fetchMealsByCategory(String category) async {
    final url = Uri.parse('$base/filter.php?c=${Uri.encodeComponent(category)}');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List meals = data['meals'] ?? [];
      return meals.map((m) => MealShort.fromJson(m)).toList();
    } else {
      throw Exception('Error loading meals');
    }
  }

  static Future<List<MealDetail>> searchMeals(String query) async {
    final url = Uri.parse('$base/search.php?s=${Uri.encodeComponent(query)}');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List? meals = data['meals'];
      if (meals == null) return [];
      return meals.map((m) => MealDetail.fromJson(m)).toList();
    } else {
      throw Exception('Error loading');
    }
  }

  static Future<List<MealShort>> searchMealsInCategory(String query, String category) async {
    final results = await searchMeals(query);
    final filtered = results.where((m) => m.category.toLowerCase() == category.toLowerCase()).toList();
    return filtered.map((d) => MealShort(id: d.id, name: d.name, thumbnail: d.thumbnail)).toList();
  }

  static Future<MealDetail> fetchMealById(String id) async {
    final url = Uri.parse('$base/lookup.php?i=$id');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List? meals = data['meals'];
      if (meals == null || meals.isEmpty) {
        throw Exception('Recipe not found.');
      }
      return MealDetail.fromJson(meals[0]);
    } else {
      throw Exception('Error loading recipe');
    }
  }

  static Future<MealDetail> fetchRandomMeal() async {
    final url = Uri.parse('$base/random.php');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List meals = data['meals'] ?? [];
      return MealDetail.fromJson(meals[0]);
    } else {
      throw Exception('Error loading random recipe');
    }
  }
}