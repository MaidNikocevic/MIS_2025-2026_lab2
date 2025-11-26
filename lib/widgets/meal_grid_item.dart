import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal_model.dart';

class MealGridItem extends StatelessWidget {
  final MealShort meal;
  final VoidCallback onTap;

  const MealGridItem({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.grey.shade200,
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: meal.thumbnail,
                placeholder: (ctx, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (ctx, url, err) => const Icon(Icons.image_not_supported),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}