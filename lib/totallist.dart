import 'dart:io';
import 'dart:ui';
import 'package:amiran/subscription_controller.dart';
import 'package:amiran/wallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:amiran/Profile_tab.dart';

import 'AuthController.dart';
import 'login.dart';

class Song {
  final String title;
  final String artist;
  final String assetPath;
  final String imagePath;
  final bool isFree;
  final double price;
  File? customImage;
  late final RxDouble rating;
  late final RxBool isFavorite;

  Song({
    required this.title,
    required this.artist,
    required this.assetPath,
    required this.imagePath,
    this.isFree = true,
    this.customImage,
    this.price = 1.99,
    double rating = 3.0,
    bool isFavorite = false,
  }) {
    this.rating = rating.obs;
    this.isFavorite = isFavorite.obs;
  }
}

class totallist extends StatefulWidget {
  @override
  State<totallist> createState() => _totallistState();
}

class _totallistState extends State<totallist> {
  final AuthController authController = Get.put(AuthController());
  final RxString searchQuery = ''.obs;
  final RxList<Song> filteredSongs = <Song>[].obs;
  final WalletController2 walletController = Get.put(WalletController2());
  final SubscriptionController subController = Get.find<SubscriptionController>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isPlaying = false.obs;
  final RxDouble currentTime = 0.0.obs;
  final RxDouble totalDuration = 0.0.obs;
  double _startDragX = 0.0;
  final RxBool isShuffleModeEnabled = false.obs;
  final Rx<LoopMode> loopMode = LoopMode.off.obs;
  final RxBool isDownloaded = false.obs;
  final RxBool isPurchased = false.obs;
  final RxBool isFree = true.obs;
  final RxList<String> comments = <String>[].obs;
  final RxList<RxBool> commentLikes = <RxBool>[].obs;
  final RxList<RxBool> commentDislikes = <RxBool>[].obs;
  final RxString editableText = "".obs;
  final RxInt currentSongIndex = (-1).obs;
  bool _wasPlayingBeforeLoad = false;
  bool _isAutoPlayingNext = false;
  final TextEditingController commentController = TextEditingController();
  final TextEditingController editModalController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final RxBool allowPlayLockedSongs = false.obs;
  final RxBool showPlayer = false.obs;

  bool _isSongPlayable(int index) {
    return songs[index].isFree ||
        allowPlayLockedSongs.value ||
        isPurchased.value ||
        subController.isPremium.value;
  }

  void _handleLockedSongAttempt() {
    Get.snackbar(
      'Song Locked',
      'This song is not free. Purchase it to unlock.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _handleMusicPurchase() {
    // First check if user is logged in
    if (!authController.isLoggedIn.value) {
      Get.snackbar(
        'Login Required',
        'Please login first to purchase music',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      // You can navigate to login page here if you want
      Get.to(() => LoginPage());
      return;
    }

    final currentSong = songs[currentSongIndex.value];

    // Check if user is premium
    if (subController.isPremium.value) {
      // Premium users get the song for free
      isPurchased.value = true;
      Get.snackbar(
        'Purchase Complete',
        'As a premium user, you got ${currentSong.title} for free!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return;
    }

    // For non-premium users, proceed with payment
    final currentBalance = walletController.balance.value;

    if (currentBalance >= currentSong.price) {
      walletController.deductMoney(currentSong.price);
      isPurchased.value = true;
      Get.snackbar(
        'Purchase Successful!',
        'You can now play ${currentSong.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      final neededAmount = currentSong.price - currentBalance;
      Get.to(() => PaymentPage());
      Get.snackbar(
        'Insufficient Funds',
        'You need \$${neededAmount.toStringAsFixed(2)} more to purchase this song',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }



  final List<Song> songs = [
    Song(
      title: 'Moonlight Sonata',
      artist: 'Ludwig van Beethoven',
      assetPath: 'assets/audios/Classical/misicc1.mp3',
      imagePath: 'assets/images/Classic/moonlightsonata.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'Eine kleine Nachtmusik',
      artist: 'Wolfgang Amadeus Mozart',
      assetPath: 'assets/audios/Classical/musicc2.mp3',
      imagePath: 'assets/images/Classic/EinekleineNachtmusik.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 20,
    ),
    Song(
      title: 'Air on the G String',
      artist: 'Johann Sebastian Bach',
      assetPath: 'assets/audios/Classical/musicc3.mp3',
      imagePath: 'assets/images/Classic/AirontheGString.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 30,
    ),
    Song(
      title: 'Nocturne Op. 9 No. 2',
      artist: 'Frédéric Chopin',
      assetPath: 'assets/audios/Classical/musicc4.mp3',
      imagePath: 'assets/images/Classic/NocturneOp.9No.2.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 25,
    ),
    Song(
      title: 'Summer',
      artist: 'Calvin Harris',
      assetPath: 'assets/audios/EDM/musice1.mp3',
      imagePath: 'assets/images/EDM/summer.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'Wake Me Up',
      artist: 'Avicii',
      assetPath: 'assets/audios/EDM/musice2.mp3',
      imagePath: 'assets/images/EDM/wakemeup.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 10,
    ),
    Song(
      title: 'Animals',
      artist: 'Martin Garrix',
      assetPath: 'assets/audios/EDM/musice3.mp3',
      imagePath: 'assets/images/EDM/animal.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'Clarity',
      artist: 'Zedd',
      assetPath: 'assets/audios/EDM/musice4.mp3',
      imagePath: 'assets/images/EDM/clarity.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 18,
    ),
    Song(
      title: 'Changes',
      artist: 'Tupac',
      assetPath: 'assets/audios/Hip Hop/musich1.mp3',
      imagePath: 'assets/images/Hip Hop/changes.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 40,
    ),
    Song(
      title: 'Lose Yourself',
      artist: 'Eminem',
      assetPath: 'assets/audios/Hip Hop/musich2.mp3',
      imagePath: 'assets/images/Hip Hop/loseyourself.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'HUMBLE',
      artist: 'Kendrick Lamar',
      assetPath: 'assets/audios/Hip Hop/musich3.mp3',
      imagePath: 'assets/images/Hip Hop/humble.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 30,
    ),
    Song(
      title: 'Empire State of Mind',
      artist: 'Jay-Z',
      assetPath: 'assets/audios/Hip Hop/musichi4.mp3',
      imagePath: 'assets/images/Hip Hop/empirestateofmind.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'So What',
      artist: 'Miles Davis',
      assetPath: 'assets/audios/Jazz/musicj1.mp3',
      imagePath: 'assets/images/Jazz/sowhat.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'My Favorite Things',
      artist: 'John Coltrane',
      assetPath: 'assets/audios/Jazz/musicj2.mp3',
      imagePath: 'assets/images/Jazz/Myfavouritething.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 28,
    ),
    Song(
      title: 'Summertime',
      artist: 'Ella Fitzgerald',
      assetPath: 'assets/audios/Jazz/musicj3.mp3',
      imagePath: 'assets/images/Jazz/summertime.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'What a Wonderful World',
      artist: 'Louis Armstrong',
      assetPath: 'assets/audios/Jazz/musicj4.mp3',
      imagePath: 'assets/images/Jazz/whatawonderfulworld.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'perfect',
      artist: 'ED Sheeran',
      assetPath: 'assets/audios/Pop/musivp1.mp3',
      imagePath: 'assets/images/Pop/perfect.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 50,
    ),
    Song(
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      assetPath: 'assets/audios/Pop/musico2.mp3',
      imagePath: 'assets/images/Pop/blindinglights.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 20,
    ),
    Song(
      title: 'Lover',
      artist: 'Taylor Swift',
      assetPath: 'assets/audios/Pop/musicp3.mp3',
      imagePath: 'assets/images/Pop/lover.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'Levitating',
      artist: 'Dua Lipa',
      assetPath: 'assets/audios/Pop/musicp4.mp3',
      imagePath: 'assets/images/Pop/leviating.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'Smells Like Teen Spirit',
      artist: 'Nirvana',
      assetPath: 'assets/audios/Rock/musicr1.mp3',
      imagePath: 'assets/images/Rock/smellsLikeTeenSprit.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'Bohemian Rhapsody',
      artist: 'Queen',
      assetPath: 'assets/audios/Rock/musicr2.mp3',
      imagePath: 'assets/images/Rock/BohemianRhapsody.jpg',
      rating: 1,
      isFree: false,
      isFavorite: false,
      price : 28,
    ),
    Song(
      title: 'Numb',
      artist: 'Linkin Park',
      assetPath: 'assets/audios/Rock/musicr3.mp3',
      imagePath: 'assets/images/Rock/linkinpark.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
    Song(
      title: 'Back in Black',
      artist: 'AC/DC',
      assetPath: 'assets/audios/Rock/musicr4.mp3',
      imagePath: 'assets/images/Rock/backInBlack.jpg',
      rating: 0,
      isFree: true,
      isFavorite: false,
    ),
  ];


  
  //search
  void filterSongs(String query) {
    searchQuery.value = query.toLowerCase();
    if (query.isEmpty) {
      filteredSongs.assignAll(songs);
    } else {
      filteredSongs.assignAll(songs.where((song) =>
      song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query)
      ).toList());
    }
  }

  void sortSongsByTitle() {
    filteredSongs.sort((a, b) => a.title.compareTo(b.title));
    Get.snackbar(
      'Sorted',
      'Songs sorted by title',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );
  }

  void sortSongsByRating() {
    filteredSongs.sort((a, b) => b.rating.value.compareTo(a.rating.value));
    Get.snackbar(
      'Sorted',
      'Songs sorted by rating',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void initState() {
    super.initState();
    filteredSongs.assignAll(songs);
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      isShuffleModeEnabled.value = _audioPlayer.shuffleModeEnabled;
      loopMode.value = _audioPlayer.loopMode;

      _audioPlayer.playerStateStream.listen((state) async {
        isPlaying.value = state.playing;

        if (state.processingState == ProcessingState.completed) {
          if (!_isAutoPlayingNext) {
            _isAutoPlayingNext = true;
            await _playNextSong();
            _isAutoPlayingNext = false;
          }
        }
      });

      _audioPlayer.positionStream.listen((position) {
        currentTime.value = position.inSeconds.toDouble();
      });

    } catch (e) {
      print("Error initializing audio: $e");
      Get.snackbar('Error', 'Could not initialize player',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _loadSong(int index) async {
    try {
      _wasPlayingBeforeLoad = isPlaying.value;
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(songs[index].assetPath);
      final duration = await _audioPlayer.duration;
      totalDuration.value = duration?.inSeconds.toDouble() ?? 0.0;
      currentTime.value = 0.0;
      isFree.value = songs[index].isFree;

      if (_wasPlayingBeforeLoad) {
        await _audioPlayer.play();
      }
    } catch (e) {
      print("Error loading song: ${songs[index].assetPath} - $e");
      Get.snackbar('Error', 'Could not load song: ${songs[index].title}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _toggleShuffle() async {
    final newShuffleState = !_audioPlayer.shuffleModeEnabled;
    await _audioPlayer.setShuffleModeEnabled(newShuffleState);
    isShuffleModeEnabled.value = newShuffleState;

    Get.snackbar(
      'Shuffle',
      newShuffleState ? 'Shuffle enabled' : 'Shuffle disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );

    if (newShuffleState) {
      _shufflePlaylist();
    }
  }

  void _shufflePlaylist() {
    final currentIndex = currentSongIndex.value;
    final random = Random();
    int newIndex;

    do {
      newIndex = random.nextInt(songs.length);
    } while (newIndex == currentIndex && songs.length > 1);

    currentSongIndex.value = newIndex;
    _loadSong(newIndex);
    if (isPlaying.value) {
      _audioPlayer.play();
    }
  }

  Future<void> _toggleRepeat() async {
    final currentMode = _audioPlayer.loopMode;
    final nextMode = currentMode == LoopMode.off
        ? LoopMode.one
        : currentMode == LoopMode.one
        ? LoopMode.all
        : LoopMode.off;

    await _audioPlayer.setLoopMode(nextMode);
    loopMode.value = nextMode;

    String message;
    if (nextMode == LoopMode.off) {
      message = 'Repeat: Off';
    } else if (nextMode == LoopMode.one) {
      message = 'Repeat: Current Song';
    } else {
      message = 'Repeat: All Songs';
    }

    Get.snackbar(
      'Repeat Mode',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 1),
    );
  }

  Future<void> _togglePlayPause() async {
    try {
      if (!_isSongPlayable(currentSongIndex.value)) {
        _handleLockedSongAttempt();
        return;
      }

      if (isPlaying.value) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      print("Error toggling play/pause: $e");
      Get.snackbar('Error', 'Could not toggle play/pause',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  //play next song
  Future<void> _playNextSong() async {
    try {
      int newIndex;
      if (_audioPlayer.shuffleModeEnabled) {
        final random = Random();
        do {
          newIndex = random.nextInt(songs.length);
        } while (newIndex == currentSongIndex.value && songs.length > 1);
      } else {
        newIndex = (currentSongIndex.value + 1) % songs.length;
      }

      final wasPlaying = isPlaying.value;
      currentSongIndex.value = newIndex;
      await _loadSong(newIndex);

      if (wasPlaying && _isSongPlayable(newIndex)) {
        await _audioPlayer.play();
      }
    } catch (e) {
      print("Error playing next song: $e");
      Get.snackbar('Error', 'Failed to play next song',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _playPreviousSong() async {
    try {
      int newIndex;
      if (_audioPlayer.shuffleModeEnabled) {
        final random = Random();
        do {
          newIndex = random.nextInt(songs.length);
        } while (newIndex == currentSongIndex.value && songs.length > 1);
      } else {
        newIndex = (currentSongIndex.value - 1) % songs.length;
        if (newIndex < 0) newIndex = songs.length - 1;
      }

      final wasPlaying = isPlaying.value;
      currentSongIndex.value = newIndex;
      await _loadSong(newIndex);

      if (wasPlaying && _isSongPlayable(newIndex)) {
        await _audioPlayer.play();
      }
    } catch (e) {
      print("Error playing previous song: $e");
      Get.snackbar('Error', 'Failed to play previous song',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _formatTime(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  void showDownloadMessage() {
    Get.snackbar(
      'Download Complete',
      'The song has been downloaded successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void showLikeMessage(bool isLiked) {
    Get.snackbar(
      isLiked ? 'Liked' : 'Unliked',
      isLiked ? 'You liked ${songs[currentSongIndex.value].title}!'
          : 'You removed like from ${songs[currentSongIndex.value].title}.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: isLiked ? Colors.pinkAccent : Colors.grey,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _startDragX = details.globalPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    final double endDragX = details.primaryVelocity ?? 0;

    if (endDragX > 0) {
      await _playPreviousSong();
      _showSwipeAnimation(Get.context!, 'right');
    } else if (endDragX < 0) {
      await _playNextSong();
      _showSwipeAnimation(Get.context!, 'left');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          songs[currentSongIndex.value].customImage = imageFile;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not pick image: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showSwipeAnimation(BuildContext context, String direction) {
    final double offset = direction == 'left' ? 50.0 : -50.0;

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 50,
        left: MediaQuery.of(context).size.width / 2 - 50,
        child: IgnorePointer(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            transform: Matrix4.translationValues(offset, 0, 0),
            child: Icon(
              direction == 'left' ? Icons.skip_next : Icons.skip_previous,
              size: 50,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);

    Future.delayed(Duration(milliseconds: 300), () {
      overlayEntry.remove();
    });
  }

  void _showBlurOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 240,
            child: Column(
              children: [
                const Text("Change Cover Image",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconOption(Icons.photo_camera, "Camera", () => _pickImage(ImageSource.camera)),
                    _buildIconOption(Icons.photo_library, "Gallery", () => _pickImage(ImageSource.gallery)),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 30,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  void _showSongOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Color(0xFF2E2A47),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            Text(
              'Song Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: TextField(
                onChanged: filterSongs,
                decoration: InputDecoration(
                  hintText: 'Search songs...',
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: sortSongsByTitle, // فقط متد را فراخوانی کنید
                  child: Text('Sort by Title'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                  ),
                ),
                ElevatedButton(
                  onPressed: sortSongsByRating, // فقط متد را فراخوانی کنید
                  child: Text('Sort by Rating'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: filteredSongs.length,
                itemBuilder: (context, index) {
                  return Obx(() => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        filteredSongs[index].imagePath,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      filteredSongs[index].title,
                      style: TextStyle(
                        color: currentSongIndex.value == index
                            ? Colors.purpleAccent
                            : Colors.white,
                        fontWeight: currentSongIndex.value == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${filteredSongs[index].artist} • \$${filteredSongs[index].price}',
                      style: TextStyle(
                        color: currentSongIndex.value == index
                            ? Colors.purpleAccent
                            : Colors.white70,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        Text(
                          filteredSongs[index].rating.value.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                          ),
                        ),
                        if (currentSongIndex.value == index)
                          Icon(
                            Icons.music_note,
                            color: Colors.purpleAccent,
                          ),
                      ],
                    ),
                    onTap: () async {
                      final originalIndex = songs.indexWhere((s) => s.title == filteredSongs[index].title);
                      currentSongIndex.value = originalIndex;
                      await _loadSong(originalIndex);
                      if (isPlaying.value) {
                        await _audioPlayer.play();
                      }
                      Navigator.pop(context);
                    },
                  ));
                },
              )),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context) {
    editModalController.text = editableText.value;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF2E2A47),
        insetPadding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(25),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Song Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25),
              TextField(
                controller: editModalController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter new info...',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(30),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      editableText.value = editModalController.text;
                      editModalController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerView() {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    showPlayer.value = false;
                    _audioPlayer.pause();
                  },
                ),
                const Text('Now Playing',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () => _showSongOptions(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _showBlurOptions(context),
              child: Obx(() => ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: songs[currentSongIndex.value].customImage != null
                    ? Image.file(
                  songs[currentSongIndex.value].customImage!,
                  width: 330,
                  height: 330,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  songs[currentSongIndex.value].imagePath,
                  width: 330,
                  height: 330,
                  fit: BoxFit.cover,
                ),
              )),
            ),
            const SizedBox(height: 20),
            Text(
              songs[currentSongIndex.value].title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              songs[currentSongIndex.value].artist,
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
            Obx(() {
              if (!_isSongPlayable(currentSongIndex.value)) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Locked - Purchase to play',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            }),
            const SizedBox(height: 12),
            Obx(() => GestureDetector(
              onTap: () {
                songs[currentSongIndex.value].isFavorite.toggle();
                showLikeMessage(
                    songs[currentSongIndex.value].isFavorite.value);
              },
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Icon(
                  songs[currentSongIndex.value].isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  key: ValueKey<bool>(
                      songs[currentSongIndex.value].isFavorite.value),
                  color: songs[currentSongIndex.value].isFavorite.value
                      ? Colors.pinkAccent
                      : Colors.purpleAccent,
                  size: 30,
                ),
              ),
            )),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < songs[currentSongIndex.value].rating.value
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        songs[currentSongIndex.value].rating.value =
                            index + 1;
                      },
                    );
                  }),
                )),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showEditModal(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(() => Slider(
              value: currentTime.value.clamp(0, totalDuration.value),
              onChanged: (value) {
                currentTime.value = value;
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
              min: 0,
              max: totalDuration.value,
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
            )),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(currentTime.value),
                    style: TextStyle(color: Colors.white70)),
                Text(
                    _formatTime(totalDuration.value - currentTime.value),
                    style: TextStyle(color: Colors.white70)),
              ],
            )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Obx(() => IconButton(
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.shuffle,
                        color: isShuffleModeEnabled.value
                            ? Colors.purpleAccent
                            : Colors.white70,
                        size: 28,
                      ),
                      if (!isShuffleModeEnabled.value)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _toggleShuffle,
                  tooltip: 'Shuffle',
                )),
                IconButton(
                  icon: Icon(Icons.skip_previous,
                      color: Colors.white, size: 32),
                  onPressed: _playPreviousSong,
                  tooltip: 'Previous',
                ),
                Obx(() => GestureDetector(
                  onTap: _togglePlayPause,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      isPlaying.value ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 36,
                    ),
                  ),
                )),
                IconButton(
                  icon:
                  Icon(Icons.skip_next, color: Colors.white, size: 32),
                  onPressed: _playNextSong,
                  tooltip: 'Next',
                ),
                Obx(() => IconButton(
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        loopMode.value == LoopMode.one
                            ? Icons.repeat_one
                            : Icons.repeat,
                        color: loopMode.value == LoopMode.off
                            ? Colors.white70
                            : Colors.purpleAccent,
                        size: 28,
                      ),
                      if (loopMode.value == LoopMode.off)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _toggleRepeat,
                  tooltip: 'Repeat',
                )),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (isFree.value || isPurchased.value) {
                return GestureDetector(
                  onTap: () {
                    if (!authController.isLoggedIn.value) {
                      Get.snackbar(
                        'Login Required',
                        'Please login first to download music',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        duration: Duration(seconds: 2),
                      );
                      return;
                    }
                    isDownloaded.value = true;
                    showDownloadMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Download',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: _handleMusicPurchase,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Buy for \$${songs[currentSongIndex.value].price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              }
            }),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  comments.add(value.trim());
                  commentController.clear();
                  commentLikes.add(false.obs);
                  commentDislikes.add(false.obs);
                }
              },
            ),
            const SizedBox(height: 10),
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comments[index],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      Obx(() => Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final isLiked =
                                  commentLikes[index].value;
                              commentLikes[index].value = !isLiked;
                              if (!isLiked) {
                                commentDislikes[index].value = false;
                              }
                            },
                            child: Icon(
                              Icons.thumb_up,
                              color: commentLikes[index].value
                                  ? Colors.green
                                  : Colors.white70,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              final isDisliked =
                                  commentDislikes[index].value;
                              commentDislikes[index].value =
                              !isDisliked;
                              if (!isDisliked) {
                                commentLikes[index].value = false;
                              }
                            },
                            child: Icon(
                              Icons.thumb_down,
                              color: commentDislikes[index].value
                                  ? Colors.red
                                  : Colors.white70,
                              size: 20,
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSongListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Songs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.sort, color: Colors.white),
                    onPressed: sortSongsByTitle,
                    tooltip: 'Sort by Title',
                  ),
                  IconButton(
                    icon: Icon(Icons.star, color: Colors.white),
                    onPressed: sortSongsByRating,
                    tooltip: 'Sort by Rating',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    songs[index].imagePath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  songs[index].title,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  songs[index].artist,
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    Text(
                      songs[index].rating.value.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                      ),
                    ),
                    if (!songs[index].isFree)
                      Icon(
                        Icons.lock,
                        color: Colors.red,
                        size: 16,
                      ),
                  ],
                ),
                onTap: () async {
                  currentSongIndex.value = index;
                  await _loadSong(index);
                  showPlayer.value = true;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2A47),
      body: SafeArea(
        child: Obx(() {
          if (showPlayer.value && currentSongIndex.value != -1) {
            return _buildPlayerView();
          } else {
            return _buildSongListView();
          }
        }),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}