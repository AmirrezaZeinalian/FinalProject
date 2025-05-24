import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, size: 50, color: Colors.pink),
                const SizedBox(height: 20),
                Text(
                  'Your Favorite Songs',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      "Favorites",
                      "Feature coming soon!",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: const Text('Explore Favorites'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}