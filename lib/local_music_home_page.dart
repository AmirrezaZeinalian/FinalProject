// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'local_music_service.dart'; // Import your service
//
// class LocalMusicHomePage extends StatelessWidget {
//   LocalMusicHomePage({Key? key}) : super(key: key);
//
//   // Get your service instance
//   final LocalMusicService controller = Get.put(LocalMusicService());
//
//   @override

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Local Music Player'),
//       ),
//       body: Obx(() {
//         if (controller.hasPermission.isFalse) {
//           return const Center(child: Text('Permission denied. Please enable storage permission.'));
//         }
//         if (controller.localAudioFiles.isEmpty) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return ListView.builder(
//           itemCount: controller.localAudioFiles.length,
//           itemBuilder: (context, index) {
//             final filePath = controller.localAudioFiles[index];
//             final fileName = filePath.split('/').last;
//             return ListTile(
//               title: Text(fileName),
//               onTap: () {
//                 controller.playAudio(filePath);
//               },
//             );
//           },
//         );
//       }),
//     );
//   }
// }