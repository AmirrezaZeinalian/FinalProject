import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../song_model.dart';
import '../song_service.dart';

class SongListPage extends StatefulWidget {
  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  final SongService _songService = SongService();
  final RxBool _isLoading = true.obs;
  final RxList<Song> songs = <Song>[].obs;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool showPlayer = false.obs;
  final RxInt currentSongIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final Rx<Duration> currentTime = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _commentController = TextEditingController(); // Controller for comments

  @override
  void initState() {
    super.initState();
    _fetchSongs();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchSongs() async {
    try {
      _isLoading.value = true;
      final fetchedSongs = await _songService.getSongs();
      songs.assignAll(fetchedSongs);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      _isLoading.value = false;
    }
  }

  void _initAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _playNextSong();
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      currentTime.value = pos;
    });

    _audioPlayer.durationStream.listen((dur) {
      totalDuration.value = dur ?? Duration.zero;
    });
  }

  // lib/pages/song_list_page.dart

  Future<void> _loadAndPlaySong(int index) async {
    if (index < 0 || index >= songs.length) return;

    final song = songs[index]; // ابتدا اطلاعات آهنگ را می‌گیریم

    // بررسی می‌کنیم که آیا آهنگ رایگان است یا نه
    if (!song.isFree) {
      // اگر رایگان نبود، یک پیام نمایش می‌دهیم و از تابع خارج می‌شویم
      Get.snackbar(
        'Song Locked', // عنوان پیام
        'This song is premium and cannot be played.', // متن پیام
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: const Icon(Icons.lock, color: Colors.white),
      );
    }

    currentSongIndex.value = index;

    try {
      await _audioPlayer.setUrl(song.url);
      await _audioPlayer.play();
      showPlayer.value = true;
    } catch (e) {
      Get.snackbar('Playback Error', 'Could not play song. Please check the URL.');
    }
  }
  Future<void> _togglePlayPause() async {
    isPlaying.value ? await _audioPlayer.pause() : await _audioPlayer.play();
  }

  // lib/pages/song_list_page.dart

  void _playNextSong() {
    if (songs.isEmpty) return;

    // از آهنگ فعلی شروع به گشتن برای آهنگ آزاد بعدی می‌کنیم
    int nextIndex = currentSongIndex.value;
    final int startIndex = nextIndex; // برای جلوگیری از حلقه بی‌نهایت

    do {
      nextIndex = (nextIndex + 1) % songs.length;
      // اگر آهنگ بعدی آزاد بود، آن را پخش کن و از حلقه خارج شو
      if (songs[nextIndex].isFree) {
        _loadAndPlaySong(nextIndex);
        return;
      }
    } while (nextIndex != startIndex); // تا زمانی که به نقطه شروع برنگشتیم، بگرد

    // اگر هیچ آهنگ آزاد دیگری پیدا نشد، می‌توان پخش را متوقف کرد
    Get.snackbar('End of Playlist', 'No more free songs available.');
  }

  void _playPreviousSong() {
    if (songs.isEmpty) return;

    // از آهنگ فعلی شروع به گشتن برای آهنگ آزاد قبلی می‌کنیم
    int prevIndex = currentSongIndex.value;
    final int startIndex = prevIndex; // برای جلوگیری از حلقه بی‌نهایت

    do {
      prevIndex = (prevIndex - 1 + songs.length) % songs.length;
      // اگر آهنگ قبلی آزاد بود، آن را پخش کن و از حلقه خارج شو
      if (songs[prevIndex].isFree) {
        _loadAndPlaySong(prevIndex);
        return;
      }
    } while (prevIndex != startIndex); // تا زمانی که به نقطه شروع برنگشتیم، بگرد

    // اگر هیچ آهنگ آزاد دیگری پیدا نشد
    Get.snackbar('End of Playlist', 'No more free songs available.');
  }

  void _handleBackButton() {
    if (showPlayer.value) {
      showPlayer.value = false;
      _audioPlayer.stop();
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && currentSongIndex.value != -1) {
        songs[currentSongIndex.value].customImage = File(pickedFile.path);
        songs.refresh();
      }
    } catch (e) {
      Get.snackbar('Image Picker Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showPlayer.value) {
          _handleBackButton();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF311B92),
        body: SafeArea(
          child: Obx(() {
            if (_isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }
            if (showPlayer.value && currentSongIndex.value != -1) {
              return _buildPlayerView();
            } else {
              return _buildSongListView();
            }
          }),
        ),
      ),
    );
  }

  Widget _buildSongListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'All Songs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.music_note, color: Colors.grey),
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  song.artist,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: !song.isFree
                    ? const Icon(Icons.lock, color: Colors.red, size: 18)
                    : Obx(() => Icon(
                  song.isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: song.isFavorite.value
                      ? Colors.red
                      : Colors.white70,
                  size: 20,
                )),
                onTap: () => _loadAndPlaySong(index),
              );
            },
          )),
        ),
      ],
    );
  }

  Widget _buildPlayerView() {
    final song = songs[currentSongIndex.value];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 30),
                  onPressed: _handleBackButton),
              const Text('NOW PLAYING',
                  style: TextStyle(color: Colors.white70, letterSpacing: 1)),
              IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 26),
                  onPressed: () {}),
            ],
          ),
          const SizedBox(height: 30),

          // Rating Stars
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.star,
                  color: index < song.rating.value.round()
                      ? Colors.amber
                      : Colors.white54,
                  size: 28,
                ),
                onPressed: () {
                  song.rating.value = index + 1.0;
                },
              );
            }),
          )),
          const SizedBox(height: 20),

          // Album Art with Favorite Button
          GestureDetector(
            onTap: () => _showImageSourceDialog(context),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    song.customImage != null
                        ? Image.file(song.customImage!, fit: BoxFit.cover)
                        : Image.network(
                      song.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Obx(() => IconButton(
                        icon: Icon(
                          song.isFavorite.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: song.isFavorite.value ? Colors.red : Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          song.isFavorite.toggle();
                        },
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Song Info
          Text(
            song.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            song.artist,
            style: const TextStyle(color: Colors.white60, fontSize: 16),
          ),
          const SizedBox(height: 30),

          // Seekbar
          Obx(() {
            double current = currentTime.value.inSeconds.toDouble();
            double total = totalDuration.value.inSeconds.toDouble();
            if (total < 1) total = 1;

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: current.clamp(0.0, total),
                    min: 0.0,
                    max: total,
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(currentTime.value),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatDuration(totalDuration.value),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),

          // Main Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                onPressed: _playPreviousSong,
              ),
              Obx(() => GestureDetector(
                onTap: _togglePlayPause,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isPlaying.value ? 70 : 65,
                  height: isPlaying.value ? 70 : 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: isPlaying.value
                        ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      )
                    ]
                        : null,
                  ),
                  child: Icon(
                    isPlaying.value ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFF311B92), // Icon color to match purple theme
                    size: 40,
                  ),
                ),
              )),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                onPressed: _playNextSong,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Secondary Controls (Shuffle, Repeat, Comment)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.shuffle, color: Colors.white70, size: 28),
                onPressed: () => _audioPlayer.setShuffleModeEnabled(
                    !_audioPlayer.shuffleModeEnabled),
              ),
              // دکمه جدید برای باز کردن صفحه کامنت‌ها
              IconButton(
                icon: const Icon(Icons.comment, color: Colors.white, size: 28),
                onPressed: () => _showCommentsBottomSheet(context),
              ),
              IconButton(
                icon: const Icon(Icons.repeat, color: Colors.white70, size: 28),
                onPressed: () => _audioPlayer.setLoopMode(LoopMode.values[
                (_audioPlayer.loopMode.index + 1) % LoopMode.values.length]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF4527A0), // <-- رنگ دیالوگ تغییر کرد
          title: const Text("Change Cover", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white70),
                title: const Text("Choose from Gallery",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white70),
                title: const Text("Take a Photo",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // متد جدید برای نمایش صفحه کامنت‌ها
  void _showCommentsBottomSheet(BuildContext context) {
    final song = songs[currentSongIndex.value];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            // ارتفاع صفحه کامنت را بیشتر می‌کنیم
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16, left: 16, right: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF4527A0).withOpacity(0.95), // <-- رنگ پس‌زمینه بنفش‌تر شد
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // یک دستگیره کوچک برای زیبایی
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Comments", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(() {
                    if (song.comments.isEmpty) {
                      return const Center(child: Text("Be the first to comment!", style: TextStyle(color: Colors.white70, fontSize: 16)));
                    }
                    return ListView.builder(
                      itemCount: song.comments.length,
                      itemBuilder: (ctx, index) {
                        return Card(
                          color: const Color(0xFF512DA8), // <-- رنگ کارت کامنت بنفش‌تر شد
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(song.comments[index], style: const TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF311B92), // <-- رنگ فیلد متن
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // دکمه ارسال با استایل بهتر
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF311B92)),
                          onPressed: () {
                            if (_commentController.text.trim().isNotEmpty) {
                              song.comments.add(_commentController.text.trim());
                              _commentController.clear();
                              FocusScope.of(context).unfocus(); // بستن کیبورد
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}