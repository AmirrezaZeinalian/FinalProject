import "../services/socket_service.dart";

class Music {
  final int id;
  final String title;
  final String artist;
  final String image;
  final double price;
  final int downloads;
  final double rating;
  final String category;

  Music({
    required this.id,
    required this.title,
    required this.artist,
    required this.image,
    required this.price,
    required this.downloads,
    required this.rating,
    required this.category,
  });

  factory Music.fromJson(Map<String,dynamic> jsonMap){
    return Music(
      id: jsonMap['id'],
      title: jsonMap['title'],
      artist: jsonMap['artist'],
      image: jsonMap['image'],
      price: jsonMap['price'],
      downloads: jsonMap['downloads'],
      rating: jsonMap['rating'],
      category: jsonMap['category'],);
  }



  bool get isFree => price <= 0;
}

class MusicData {


  static Future<List<Music>> getMusicByCategory(String category) async {
    final SocketService _socketService = SocketService(host: '10.0.2.2', port: 8081);
    try {
      final response = await _socketService.send(
        action: 'getMusicByCategory',
        data: {'category': category},
      );

      List<dynamic> musicData = response['data'] ?? [];
      List<Music> musicList = musicData.map(
              (music) => Music.fromJson(music as Map<String, dynamic>)
      ).toList();

      return musicList;
    } catch (e) {
      return [];
    }

  }



  static Future<Music?> getMusicByTitle(String title) async {
    final SocketService _socketService = SocketService(host: '10.0.2.2', port: 8081);
    try {

      final response = await _socketService.send(
        action: 'getMusicByTitle',
        data: {'title': title},
      );

      if (response['status'] == 'success' && response['data'] != null) {

        final musicData = response['data'] as Map<String, dynamic>;



        final music = Music.fromJson(musicData);


        return music;

      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }






}
