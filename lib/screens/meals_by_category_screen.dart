import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';
import '../widgets/meal_grid_item.dart';
import 'meal_detail_screen.dart';

class MealsByCategoryScreen extends StatefulWidget {
  static const routeName = '/meals-by-category';
  const MealsByCategoryScreen({super.key});

  @override
  State<MealsByCategoryScreen> createState() => _MealsByCategoryScreenState();
}

class _MealsByCategoryScreenState extends State<MealsByCategoryScreen> {
  String _category = '';
  late Future<List<MealShort>> _futureMeals;
  List<MealShort> _all = [];
  List<MealShort> _display = [];
  final TextEditingController _searchCtl = TextEditingController();
  bool _isSearching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is String) {
      _category = arg;
      _loadMeals();
    }
  }

  void _loadMeals() {
    _futureMeals = ApiService.fetchMealsByCategory(_category);
    _futureMeals.then((list) {
      setState(() {
        _all = list;
        _display = list;
      });
    }).catchError((e){
    });
  }

  void _onSearchChanged(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _display = _all;
      });
    } else {
      setState(() { _isSearching = true; });
      try {
        final results = await ApiService.searchMealsInCategory(query, _category);
        setState(() {
          _display = results;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while searching: $e')));
      } finally {
        setState(() { _isSearching = false; });
      }
    }
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
        title: Text('$_category'),
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
      body: FutureBuilder<List<MealShort>>(
        future: _futureMeals,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting && _all.isEmpty) {
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
                    hintText: 'Search meals in this category...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              if (_isSearching) const LinearProgressIndicator(),
              Expanded(
                child: _display.isEmpty
                    ? const Center(child: Text('No results'))
                    : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _display.length,
                  itemBuilder: (ctx, i) {
                    final meal = _display[i];
                    return MealGridItem(
                      meal: meal,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          MealDetailScreen.routeName,
                          arguments: meal.id,
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