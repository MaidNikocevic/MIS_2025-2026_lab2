import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade200,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 64,
          height: 64,
          child: CachedNetworkImage(
            imageUrl: category.thumbnail,
            placeholder: (ctx, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (ctx, url, err) => const Icon(Icons.image_not_supported),
            fit: BoxFit.cover,
          ),
        ),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          category.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}