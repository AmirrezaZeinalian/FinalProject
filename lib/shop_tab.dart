import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Profile_tab.dart';
import 'AuthController.dart';
import 'categories/classic.dart';
import 'categories/edm.dart';
import 'categories/hiphop.dart';
import 'categories/jazz.dart';
import 'categories/pop.dart';
import 'categories/rock.dart';
import 'login.dart';

class ShopPage extends StatelessWidget {
  ShopPage({super.key});

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Pop',
      'icon': Icons.music_note,
      'color': Colors.pink,
      'imagePath': "assets/images/categories/popCategory.jpg"
    },
    {
      'title': 'Rock',
      'icon': Icons.audiotrack,
      'color': Colors.blue,
      'imagePath': "assets/images/categories/rockCategory.jpg"
    },
    {
      'title': 'Jazz',
      'icon': Icons.library_music,
      'color': Colors.orange,
      'imagePath': "assets/images/categories/jazzCategory.jpg"
    },
    {
      'title': 'Hip Hop',
      'icon': Icons.headphones,
      'color': Colors.green,
      'imagePath': "assets/images/categories/hiphopCategory.jpg"
    },
    {
      'title': 'Classical',
      'icon': Icons.album,
      'color': Colors.teal,
      'imagePath': "assets/images/categories/classicalCategory.jpg"
    },
    {
      'title': 'EDM',
      'icon': Icons.graphic_eq,
      'color': Colors.red,
      'imagePath': "assets/images/categories/edmCategory.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Shop"),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => ProfileTab());
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.person, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Obx(() {
        if (!AuthController.to.isLoggedIn.value) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.deepPurple, Colors.black87],
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Discover Amazing Music',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Login to explore our vast collection of music across all genres',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login, size: 24),
                        label: const Text(
                          'Login Now',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Get.to(() => LoginPage()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // User is logged in, show categories
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.deepPurple, Colors.black87],
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search music...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      for (var category in categories)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCategoryCard(
                            category['title'],
                            category['icon'],
                            category['color'],
                            imagePath: category['imagePath'],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, {String? imagePath}) {
    return SizedBox(
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            if (imagePath != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
              ),

            Container(
              decoration: BoxDecoration(
                color: imagePath != null
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.9),
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  switch (title) {
                    case "Pop":
                      Get.to(() =>  PopCategoryPage());
                      break;
                    case "Rock":
                      Get.to(() =>  RockCategoryPage());
                      break;
                    case "Jazz":
                      Get.to(() =>  JazzCategoryPage());
                      break;
                    case "Hip Hop":
                      Get.to(() =>  HipHopCategoryPage());
                      break;
                    case "Classical":
                      Get.to(() => ClassicalCategoryPage());
                      break;
                    case "EDM":
                      Get.to(() => EDMCategoryPage());
                      break;
                    default:
                      Get.snackbar(
                        "Coming Soon",
                        "$title category is under construction.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: color.withOpacity(0.9),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(12),
                        borderRadius: 12,
                      );
                  }
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon,
                          color: imagePath != null ? Colors.white : color,
                          size: 40),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: imagePath != null ? Colors.white : color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}