import 'dart:io';
import 'package:get/get.dart';

class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String url;
  final String imageUrl;
  final bool isFree;
  final double price;

  File? customImage;
  late final RxDouble rating;
  late final RxBool isFavorite;

  late final RxList<String> comments;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.url,
    required this.imageUrl,
    this.isFree = true,
    this.price = 0.0,
    double initialRating = 3.0,
    bool initialIsFavorite = false,
  }) {
    rating = initialRating.obs;
    isFavorite = initialIsFavorite.obs;
    comments = <String>[].obs;
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'] ?? 'Unknown Album',
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isFree: json['isFree'] ?? true,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'url': url,
      'imageUrl': imageUrl,
      'isFree': isFree,
      'price': price,
    };
  }
}