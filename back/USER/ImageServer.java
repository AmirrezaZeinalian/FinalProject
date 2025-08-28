package com.example.backendtest1.USER;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;

public class ImageServer implements Runnable {
    // IMPORTANT: Make sure this path is correct on your system.
    private static final String PROFILE_PICTURE_UPLOAD_DIR = "E:\\FinalProject\\profile_pictures";
    private static final int IMAGE_SERVER_PORT = 8080;

    @Override
    public void run() {
        try (ServerSocket serverSocket = new ServerSocket(IMAGE_SERVER_PORT)) {
            System.out.println("Image Server started on port " + IMAGE_SERVER_PORT + "...");
            while (true) {
                try {
                    Socket clientSocket = serverSocket.accept();
                    new Thread(() -> handleImageRequest(clientSocket)).start();
                } catch (IOException e) {
                    System.err.println("Error accepting client connection: " + e.getMessage());
                }
            }
        } catch (IOException e) {
            System.err.println("Image Server failed to start: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void handleImageRequest(Socket clientSocket) {
        try (InputStream in = clientSocket.getInputStream();
             OutputStream out = clientSocket.getOutputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(in))) {

            String requestLine = reader.readLine();
            if (requestLine == null || !requestLine.startsWith("GET")) {
                sendErrorResponse(out, 400, "Bad Request");
                return;
            }

            String path = requestLine.split(" ")[1];
            String filename = path.replace("/profile-pictures/", "");

            System.out.println("Image Server received request for: " + filename);

            // Basic security check to prevent directory traversal attacks
            if (filename.isEmpty() || Stream.of(filename.split("/")).anyMatch(part -> part.equals(".."))) {
                sendErrorResponse(out, 400, "Bad Request");
                return;
            }

            Path imagePath = Paths.get(PROFILE_PICTURE_UPLOAD_DIR, filename);

            if (Files.exists(imagePath)) {
                sendSuccessResponse(out, imagePath, filename);
                System.out.println("Sent image file: " + filename);
            } else {
                sendErrorResponse(out, 404, "Not Found");
                System.err.println("Image file not found: " + imagePath);
            }

        } catch (IOException e) {
            System.err.println("Error handling image request: " + e.getMessage());
        } finally {
            try {
                if (clientSocket != null) {
                    clientSocket.close();
                }
            } catch (IOException e) {
                System.err.println("Error closing socket: " + e.getMessage());
            }
        }
    }

    private void sendSuccessResponse(OutputStream out, Path filePath, String filename) throws IOException {
        long fileLength = Files.size(filePath);
        String fileExtension = getFileExtension(filename);

        out.write("HTTP/1.1 200 OK\r\n".getBytes());
        out.write(("Content-Type: image/" + fileExtension + "\r\n").getBytes());
        out.write(("Content-Length: " + fileLength + "\r\n").getBytes());
        out.write("Connection: close\r\n".getBytes());
        out.write("\r\n".getBytes());

        Files.copy(filePath, out);
        out.flush();
    }

    private void sendErrorResponse(OutputStream out, int statusCode, String message) throws IOException {
        out.write(("HTTP/1.1 " + statusCode + " " + message + "\r\n").getBytes());
        out.write("Content-Type: text/plain\r\n".getBytes());
        out.write("Connection: close\r\n".getBytes());
        out.write("\r\n".getBytes());
        out.write(message.getBytes());
        out.flush();
    }

    private String getFileExtension(String filename) {
        int dotIndex = filename.lastIndexOf('.');
        if (dotIndex > 0 && dotIndex < filename.length() - 1) {
            return filename.substring(dotIndex + 1).toLowerCase();
        }
        return "jpeg"; // Default to jpeg if no extension found
    }
}
