import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category_model.dart';
import '../widgets/category_card.dart';
import 'meals_by_category_screen.dart';
import 'meal_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<CategoryModel>> _futureCategories;
  List<CategoryModel> _all = [];
  List<CategoryModel> _filtered = [];
  final TextEditingController _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureCategories = ApiService.fetchCategories();
    _futureCategories.then((list) {
      setState(() {
        _all = list;
        _filtered = list;
      });
    }).catchError((e){
    });
  }

  void _onSearchChanged(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all.where((c) => c.name.toLowerCase().contains(query)).toList();
      }
    });
  }

  void _openRandom() async {
    try {
      final meal = await ApiService.fetchRandomMeal();
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        MealDetailScreen.routeName,
        arguments: meal.id,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Meal Categories',
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 64,
                maxWidth: 88,
                minHeight: 36,
                maxHeight: 42,
              ),
              child: ElevatedButton(
                onPressed: _openRandom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade200,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  minimumSize: const Size(64, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Recipe\nof the day',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      height: 1.05,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: _futureCategories,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchCtl,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search categories...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(child: Text('No results'))
                    : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final cat = _filtered[i];
                    return CategoryCard(
                      category: cat,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          MealsByCategoryScreen.routeName,
                          arguments: cat.name,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}