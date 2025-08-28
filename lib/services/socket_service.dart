import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

/// A service to handle socket communication with a server.
/// It sends JSON-encoded messages and receives JSON responses.
class SocketService {
  final String host;
  final int port;

  /// Creates a SocketService instance.
  ///
  /// [host]: The IP address or hostname of the server.
  /// [port]: The port number to connect to.
  SocketService({required this.host, required this.port});

  /// Sends a request to the server and returns the response.
  ///
  /// The request is a JSON object with 'action' and 'data' fields.
  ///
  /// [action]: A string identifying the type of request (e.g., 'getMusicByCategory').
  /// [data]: A map containing the data for the request.
  ///
  /// Returns a Future<Map<String, dynamic>> representing the server's response.
  /// Throws an exception if the connection fails or the response is invalid.
  Future<Map<String, dynamic>> send({
    required String action,
    required Map<String, dynamic> data,
  }) async {
    Socket? socket;
    try {
      // 1. Establish the connection to the server.
      // We set a timeout to prevent the app from hanging indefinitely.
      socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));

      // 2. Prepare the request payload as a Map.
      final Map<String, dynamic> request = {
        'action': action,
        'data': data,
      };

      // 3. Encode the request Map into a JSON string.
      final String jsonRequest = jsonEncode(request);
      final List<int> bytes = utf8.encode(jsonRequest + '\n'); // Add a newline to delimit the message.

      // 4. Send the encoded data to the server.
      socket.add(bytes);
      await socket.flush();

      // 5. Read the response from the server.
      // We listen for the first message (assuming the server sends a single response).
      final Uint8List responseBytes = await socket.first.timeout(const Duration(seconds: 5));

      // 6. Decode the response bytes back into a JSON string.
      final String jsonResponse = utf8.decode(responseBytes);

      // 7. Parse the JSON string into a Dart Map.
      final Map<String, dynamic> responseMap = jsonDecode(jsonResponse);

      // 8. Close the socket connection.
      await socket.close();
      await socket.done;

      return responseMap;
    } on SocketException catch (e) {
      // Handle network-related errors (e.g., connection refused, host not found).
      throw Exception('Socket connection failed: ${e.message}');
    } on FormatException catch (e) {
      // Handle errors from invalid JSON format in the server response.
      throw Exception('Invalid JSON response from server: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors.
      throw Exception('An unknown error occurred: $e');
    } finally {
      // Ensure the socket is closed even if an error occurs.
      try {
        if (socket != null) {
          await socket.close();
        }
      } catch (e) {
        // Ignore errors during close, as the main error is already being handled.
      }
    }
  }
}
