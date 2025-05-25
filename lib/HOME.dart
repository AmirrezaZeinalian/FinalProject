import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'categories/classic.dart';
import 'categories/edm.dart';
import 'categories/hiphop.dart';
import 'categories/jazz.dart';
import 'categories/rock.dart';
import 'categories/pop.dart';
import 'signup.dart';
import 'ThemeController2.dart';
import 'Payment.dart';
import 'categories/edm.dart';
import 'categories/jazz.dart';
import 'categories/pop.dart';
import 'login.dart';
import 'favourites_tab.dart';
import 'shop_tab.dart';
import 'Profile_tab.dart';
import 'totallist.dart';


class NavigationController extends GetxController {
  var selectedIndex = 0.obs;
  final ThemeController themeController = Get.find();

  void changePage(int index) {
    selectedIndex.value = index;
  }
}


class MusicHomePage extends StatelessWidget {
  final NavigationController navController = Get.put(NavigationController());

  MusicHomePage({super.key});

  final List<Widget> pages = [
    const HomeContent(),
    ShopPage(),
    ProfileTab(),
    totallist(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '🎵 SEPOTIFY',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple.withOpacity(0.8),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                ),
              ),
              accountName: const Text("Guest"),
              accountEmail: const Text("guest@example.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Get.to(LoginPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Sign Up'),
              onTap: () {
                Get.to(RegisterPage());
              },
            ),
          ],
        ),
      ),
      body: Stack(
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
          pages[navController.selectedIndex.value],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navController.selectedIndex.value,
        onTap: navController.changePage,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'), // New List button
        ],
      ),
    ));
  }
}


class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imgList = [
      'assets/images/1.jpg',
      'assets/images/2.jpg',
      'assets/images/3.jpg',
      'assets/images/4.jpg',
      'assets/images/5.jpg',
      'assets/images/6.jpg',
      'assets/images/7.jpg'
    ];


    return Column(
      children: [
        const SizedBox(height: 100),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                CarouselSlider.builder(
                  itemCount: imgList.length,
                  itemBuilder: (context, index, realIndex) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.asset(
                          imgList[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200.0,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  ),
                ),
                const SizedBox(height: 20),

                // Replace GridView with Column containing each category card
                Column(
                  children: [
                    _buildCategoryCard('Pop', Icons.music_note, Colors.pink, imagePath: "assets/images/categories/popCategory.jpg"),
                    const SizedBox(height: 16),
                    _buildCategoryCard('Rock', Icons.audiotrack, Colors.blue, imagePath: "assets/images/categories/rockCategory.jpg"),
                    const SizedBox(height: 16),
                    _buildCategoryCard('Jazz', Icons.library_music, Colors.orange, imagePath: "assets/images/categories/jazzCategory.jpg"),
                    const SizedBox(height: 16),
                    _buildCategoryCard('Hip Hop', Icons.headphones, Colors.green, imagePath: "assets/images/categories/hiphopCategory.jpg"),
                    const SizedBox(height: 16),
                    _buildCategoryCard('Classical', Icons.album, Colors.teal, imagePath: "assets/images/categories/classicalCategory.jpg"),
                    const SizedBox(height: 16),
                    _buildCategoryCard('EDM', Icons.graphic_eq, Colors.red, imagePath: "assets/images/categories/edmCategory.jpg"),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildCategoryCard(String title, IconData icon, Color color, {String? imagePath}) {
    return SizedBox(
      height: 120, // Adjust height as needed
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Background image if provided
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

            // Semi-transparent overlay to make text readable
            if (imagePath != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.3),
                ),
              ),

            // Your existing content with white background (now with conditional opacity)
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
                  // Your existing navigation code
                  if (title == "Pop") {
                    Get.to(() => PopCategoryPage());
                  }
                  else if(title == "Rock"){
                    Get.to(() => RockCategoryPage());
                  }
                  else if(title == "Jazz"){
                    Get.to(() => JazzCategoryPage());
                  }
                  else if(title == "Hip Hop"){
                    Get.to(() => HipHopCategoryPage());
                  }
                  else if(title == "Classical"){
                    Get.to(() =>  ClassicalCategoryPage());
                  }
                  else if(title == "EDM"){
                    Get.to(() => EDMCategoryPage());
                  }
                  else {
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
                      Icon(icon, color: imagePath != null ? Colors.white : color, size: 40),
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


class CategoryDetailPage extends StatelessWidget {
  final String title;
  final Color color;

  const CategoryDetailPage({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title Music'),
        backgroundColor: color,
      ),
      body: Center(
        child: Text(
          'This is the $title category page.\nMore content coming soon!',
          style: TextStyle(fontSize: 20, color: color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}