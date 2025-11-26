import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MealDetailScreen extends StatefulWidget {
  static const routeName = '/meal-detail';
  const MealDetailScreen({super.key});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late Future<MealDetail> _futureMeal;
  String _mealId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is String) {
      _mealId = arg;
      _futureMeal = ApiService.fetchMealById(_mealId);
    }
  }

  void _openYoutube(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Can not open YouTube')));
    }
  }

  void _openRandom() async {
    try {
      final meal = await ApiService.fetchRandomMeal();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
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
        title: const Text('Recipe'),
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
      body: FutureBuilder<MealDetail>(
        future: _futureMeal,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final meal = snap.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CachedNetworkImage(
                  imageUrl: meal.thumbnail,
                  placeholder: (ctx, url) => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                  errorWidget: (ctx, url, err) => const SizedBox(height: 200, child: Icon(Icons.image_not_supported)),
                  height: 240,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(meal.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Category: ${meal.category}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.blueGrey,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: const Text('Ingredients:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meal.ingredients.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text('${e.key} — ${e.value}'),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: const Text('Instructions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(meal.instructions),
                ),
                const SizedBox(height: 12),
                if (meal.youtube.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _openYoutube(meal.youtube),
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Open YouTube'),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}