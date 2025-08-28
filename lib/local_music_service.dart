// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:path_provider/path_provider.dart'; // Import this
//
// class LocalMusicService extends GetxController {
//   final RxList<String> localAudioFiles = <String>[].obs;
//   final RxBool hasPermission = false.obs;
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
//   @override
//   void onInit() {
//     super.onInit();
//     _requestPermissionAndScan();
//   }
//
//   // Request storage permission from the user
//   Future<void> _requestPermissionAndScan() async {
//     // You may need to use this permission on newer Android versions
//     final status = await Permission.manageExternalStorage.request();
//     if (status.isGranted) {
//       hasPermission.value = true;
//       await _scanForMusic();
//     } else {
//       hasPermission.value = false;
//       Get.snackbar(
//         'Permission Denied',
//         'Please grant storage permission to access local music files.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
//
//   // Scan the device's storage for audio files
//   Future<void> _scanForMusic() async {
//     final List<String> paths = [];
//     final Directory directory = (await getExternalStorageDirectory())!; // Use getExternalStorageDirectory()
//
//     await for (final fileSystemEntity in directory.list(recursive: true)) {
//       if (fileSystemEntity is File) {
//         final String path = fileSystemEntity.path;
//         if (path.endsWith('.mp3') || path.endsWith('.m4a') || path.endsWith('.aac')) {
//           paths.add(path);
//         }
//       }
//     }
//     localAudioFiles.assignAll(paths);
//   }
//
//   // Play a local audio file
//   Future<void> playAudio(String filePath) async {
//     try {
//       await _audioPlayer.setFilePath(filePath);
//       _audioPlayer.play();
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Could not play the audio file: $e',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
//
//   // Pause the current audio
//   Future<void> pauseAudio() async {
//     await _audioPlayer.pause();
//   }
//
//   // Stop the current audio
//   Future<void> stopAudio() async {
//     await _audioPlayer.stop();
//   }
// }