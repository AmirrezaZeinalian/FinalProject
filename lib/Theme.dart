import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'ThemeController2.dart';



class Theme extends StatelessWidget {
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Theme Switch")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => themeController.toggleTheme(),
          child: Text("Toggle Theme"),
        ),
      ),
    );
  }
}
