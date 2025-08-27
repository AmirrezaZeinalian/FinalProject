import 'dart:convert';
import 'package:http/http.dart' as http;
import 'song_model.dart';

class SongService {
  final String baseUrl = "http://10.183.186.120:8080/api/songs";

  Future<List<Song>> getSongs() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load songs (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<void> deleteSong(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete song');
    }
  }
}