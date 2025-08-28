package com.example.backendtest1.USER;


import java.net.ServerSocket;
import java.net.Socket;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.Base64;
import java.util.Objects;
import java.io.*;
import java.nio.file.*;
import java.util.*;

import org.json.JSONObject;

public class USER {
    private static final String USER_DATABASE = "C:\\Users\\ASUS\\total6\\USER.txt";
    private static final String SUPPORT_DB_PATH = "C:\\Users\\ASUS\\total6\\SUPPORT_TICKETS.txt";
    private static final String PROFILE_PICTURE_UPLOAD_DIR = "C:\\Users\\ASUS\\total6\\profile_pictures";
    private static final String DELIMITER = "$";
    private static final String TICKET_DELIMITER = "#";

    private String username;
    private String email;
    private String password;
    private int birthDay;
    private int birthMonth;
    private int birthYear;
    private String city;
    private long wallet;
    private boolean darkTheme;
    private boolean hasSubscription;
    private LocalDate subscriptionEndDate;
    private boolean isLoggedIn;
    private String wallpaperPath;

    private USER(){}
    private USER(String username, String email, String password,
                 int day, int month, int year, String city) {
        setUsername(username);
        setEmail(email);
        setPassword(password);
        setBirthDate(day, month, year);
        setCity(city);
        this.wallet = 0;
        this.darkTheme = false;
        this.hasSubscription = false;
        this.isLoggedIn = false;
        this.wallpaperPath = "default_avatar.png";
    }

    private USER(String username, String email, String password,
                 int day, int month, int year, String city, long wallet,
                 boolean darkTheme, boolean hasSubscription, LocalDate subscriptionEndDate,
                 String wallpaperPath, boolean isLoggedIn) {
        this.username = username;
        this.email = email;
        this.password = password;
        this.birthDay = day;
        this.birthMonth = month;
        this.birthYear = year;
        this.city = city;
        this.wallet = wallet;
        this.darkTheme = darkTheme;
        this.hasSubscription = hasSubscription;
        this.subscriptionEndDate = subscriptionEndDate;
        this.wallpaperPath = wallpaperPath;
        this.isLoggedIn = isLoggedIn;
    }

    public static class SupportTicket {
        private String ticketId;
        private String userEmail;
        private String message;
        private String timestamp;
        private String status;
        private String agentResponse;

        public SupportTicket(String userEmail, String message) {
            this.ticketId = UUID.randomUUID().toString();
            this.userEmail = userEmail;
            this.message = message;
            this.timestamp = LocalDateTime.now().toString();
            this.status = "OPEN";
            this.agentResponse = "";
        }

        public SupportTicket(String ticketId, String userEmail, String message, String timestamp, String status, String agentResponse) {
            this.ticketId = ticketId;
            this.userEmail = userEmail;
            this.message = message;
            this.timestamp = timestamp;
            this.status = status;
            this.agentResponse = agentResponse;
        }

        public String getTicketId() { return ticketId; }
        public String getUserEmail() { return userEmail; }
        public String getMessage() { return message; }
        public String getTimestamp() { return timestamp; }
        public String getStatus() { return status; }
        public String getAgentResponse() { return agentResponse; }

        public void setStatus(String status) { this.status = status; }
        public void setAgentResponse(String agentResponse) { this.agentResponse = agentResponse; }

        public String toFileString() {
            String cleanMessage = message.replace("\n", "\\n").replace(TICKET_DELIMITER, "\\#");
            String cleanResponse = agentResponse.replace("\n", "\\n").replace(TICKET_DELIMITER, "\\#");

            return String.join(TICKET_DELIMITER,
                    ticketId,
                    userEmail,
                    cleanMessage,
                    timestamp,
                    status,
                    cleanResponse
            );
        }

        public static SupportTicket fromFileString(String line) {
            String[] parts = line.split("\\" + TICKET_DELIMITER, -1);
            if (parts.length >= 6) {
                String restoredMessage = parts[2].replace("\\n", "\n").replace("\\#", TICKET_DELIMITER);
                String restoredResponse = parts[5].replace("\\n", "\n").replace("\\#", TICKET_DELIMITER);

                return new SupportTicket(
                        parts[0],
                        parts[1],
                        restoredMessage,
                        parts[3],
                        parts[4],
                        restoredResponse
                );
            }
            return null;
        }

        @Override
        public String toString() {
            return "Ticket ID: " + ticketId + "\n" +
                    "User Email: " + userEmail + "\n" +
                    "Message: " + message + "\n" +
                    "Timestamp: " + timestamp + "\n" +
                    "Status: " + status + "\n" +
                    "Agent Response: " + (agentResponse.isEmpty() ? "N/A" : agentResponse);
        }
    }

    private static void writeSupportTicketToFile(SupportTicket ticket) throws IOException {
        Path path = Paths.get(SUPPORT_DB_PATH);
        if (Files.notExists(path.getParent())) {
            Files.createDirectories(path.getParent());
        }
        try (BufferedWriter writer = Files.newBufferedWriter(path,
                StandardOpenOption.CREATE, StandardOpenOption.APPEND)) {
            writer.write(ticket.toFileString());
            writer.newLine();
        }
    }

    private static List<SupportTicket> readAllSupportTickets() throws IOException {
        List<SupportTicket> tickets = new ArrayList<>();
        Path path = Paths.get(SUPPORT_DB_PATH);
        if (Files.notExists(path)) {
            return tickets;
        }
        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                SupportTicket ticket = SupportTicket.fromFileString(line);
                if (ticket != null) {
                    tickets.add(ticket);
                } else {
                    System.err.println("Skipping malformed support ticket line: " + line);
                }
            }
        }
        return tickets;
    }

    private static void updateSupportTicketInFile(SupportTicket updatedTicket) throws IOException {
        Path path = Paths.get(SUPPORT_DB_PATH);
        if (Files.notExists(path)) {
            throw new IOException("Support ticket database not found: " + SUPPORT_DB_PATH);
        }

        List<String> lines = Files.readAllLines(path);
        boolean found = false;
        for (int i = 0; i < lines.size(); i++) {
            String[] parts = lines.get(i).split("\\" + TICKET_DELIMITER, -1);
            if (parts.length > 0 && parts[0].equals(updatedTicket.getTicketId())) {
                lines.set(i, updatedTicket.toFileString());
                found = true;
                break;
            }
        }
        if (!found) {
            throw new IOException("Ticket to update not found in database: " + updatedTicket.getTicketId());
        }
        Files.write(path, lines, StandardOpenOption.TRUNCATE_EXISTING);
    }

    public static SupportTicket getSupportTicketById(String ticketId) throws IOException {
        List<SupportTicket> allTickets = readAllSupportTickets();
        for (SupportTicket ticket : allTickets) {
            if (ticket.getTicketId().equals(ticketId)) {
                return ticket;
            }
        }
        return null;
    }


    private static void saveUserToDatabase(USER user) throws IOException {
        String userData = String.join(DELIMITER,
                user.getUsername(),
                user.getEmail(),
                user.password,
                String.valueOf(user.getBirthDay()),
                String.valueOf(user.getBirthMonth()),
                String.valueOf(user.getBirthYear()),
                user.getCity(),
                String.valueOf(user.getWallet()),
                String.valueOf(user.isDarkTheme()),
                user.getWallpaperPath(),
                user.subscriptionEndDate != null ? user.subscriptionEndDate.toString() : "null",
                String.valueOf(user.hasSubscription())
        );

        Path path = Paths.get(USER_DATABASE);
        if (Files.notExists(path.getParent())) {
            Files.createDirectories(path.getParent());
        }

        try (BufferedWriter writer = Files.newBufferedWriter(path,
                StandardOpenOption.CREATE, StandardOpenOption.APPEND)) {
            writer.write(userData);
            writer.newLine();
        }
    }

    private static USER createUserFromLineParts(String[] parts) {
        if (parts.length < 12) {
            throw new IllegalArgumentException("Malformed user data line: not enough parts. Line length: " + parts.length + " - " + Arrays.toString(parts));
        }

        String username = parts[0];
        String email = parts[1];
        String password = parts[2];
        int day = Integer.parseInt(parts[3]);
        int month = Integer.parseInt(parts[4]);
        int year = Integer.parseInt(parts[5]);
        String city = parts[6];
        long wallet = Long.parseLong(parts[7]);
        boolean darkTheme = Boolean.parseBoolean(parts[8]);
        String wallpaperPath = parts[9];
        LocalDate subscriptionEndDate = parts[10].equals("null") ? null : LocalDate.parse(parts[10]);
        boolean hasSubscription = Boolean.parseBoolean(parts[11]);

        return new USER(username, email, password, day, month, year, city,
                wallet, darkTheme, hasSubscription, subscriptionEndDate, wallpaperPath, false);
    }

    private static USER readUserFromFile(String email, String password) throws IOException {
        Path path = Paths.get(USER_DATABASE);
        if (Files.notExists(path)) {
            return null;
        }

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\" + DELIMITER, -1);
                try {
                    if (parts.length >= 12 && parts[1].equals(email)) {
                        if (parts[2].equals(password)) {
                            return createUserFromLineParts(parts);
                        }
                        return null;
                    }
                } catch (NumberFormatException | ArrayIndexOutOfBoundsException e) {
                    System.err.println("Skipping corrupted user data line: " + line + " - " + e.getMessage());
                }
            }
        }
        return null;
    }

    public static USER findUserByEmail(String email) throws IOException {
        Path path = Paths.get(USER_DATABASE);
        if (Files.notExists(path)) {
            return null;
        }

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\" + DELIMITER, -1);
                try {
                    if (parts.length >= 12 && parts[1].equals(email)) {
                        return createUserFromLineParts(parts);
                    }
                } catch (NumberFormatException | ArrayIndexOutOfBoundsException e) {
                    System.err.println("Skipping corrupted user data line: " + line + " - " + e.getMessage());
                }
            }
        }
        return null;
    }

    private static USER findUserByPersonalDetails(String city, int day, int month, int year) throws IOException {
        Path path = Paths.get(USER_DATABASE);
        if (Files.notExists(path)) {
            return null;
        }

        try (BufferedReader reader = Files.newBufferedReader(path)) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\" + DELIMITER, -1);
                if (parts.length >= 12) {
                    try {
                        String storedCity = parts[6];
                        int storedDay = Integer.parseInt(parts[3]);
                        int storedMonth = Integer.parseInt(parts[4]);
                        int storedYear = Integer.parseInt(parts[5]);

                        if (storedCity.equalsIgnoreCase(city) && storedDay == day && storedMonth == month && storedYear == year) {
                            return createUserFromLineParts(parts);
                        }
                    } catch (NumberFormatException | ArrayIndexOutOfBoundsException e) {
                        System.err.println("Skipping corrupted line in USER.txt: " + line + " - " + e.getMessage());
                    }
                }
            }
        }
        return null;
    }

    private static boolean DeleteUSerFromFile(String username, String email, String password) throws IOException {
        Path path = Paths.get(USER_DATABASE);
        if (Files.notExists(path)) {
            System.out.println("DeleteUSerFromFile DEBUG: USER_DATABASE file does not exist at " + USER_DATABASE);
            return false;
        }

        List<String> lines = Files.readAllLines(path);
        List<String> updatedLines = new ArrayList<>();
        boolean userFoundAndDeleted = false;

        System.out.println("DeleteUSerFromFile DEBUG: Attempting to delete user with username='" + username + "', email='" + email + "', password='" + password + "'");

        for (String line : lines) {
            String[] parts = line.split("\\" + DELIMITER, -1);
            if (parts.length >= 12) {
                String storedUsername = parts[0];
                String storedEmail = parts[1];
                String storedPassword = parts[2];

                System.out.println("DeleteUSerFromFile DEBUG: Comparing with line: Stored Username='" + storedUsername + "', Stored Email='" + storedEmail + "', Stored Password='" + storedPassword + "'");

                if (storedUsername.trim().equals(username.trim()) &&
                        storedEmail.trim().equals(email.trim()) &&
                        storedPassword.trim().equals(password.trim())) {
                    userFoundAndDeleted = true;
                    System.out.println("DeleteUSerFromFile DEBUG: MATCH FOUND! User '" + email + "' will be deleted.");
                } else {
                    updatedLines.add(line);
                }
            } else {
                System.err.println("DeleteUSerFromFile DEBUG: Skipping malformed line (less than 12 parts): " + line + ". Keeping it.");
                updatedLines.add(line);
            }
        }

        if (userFoundAndDeleted) {
            Files.write(path, updatedLines, StandardOpenOption.TRUNCATE_EXISTING);
            System.out.println("DeleteUSerFromFile DEBUG: User successfully removed from file. Remaining lines written: " + updatedLines.size());
            return true;
        }
        System.out.println("DeleteUSerFromFile DEBUG: User not found with provided credentials. No deletion occurred.");
        return false;
    }

    private static void updateUserInFile(USER user) throws IOException {
        Path path = Paths.get(USER_DATABASE);
        if (Files.notExists(path)) {
            throw new IOException("User database not found: " + USER_DATABASE);
        }

        List<String> lines = Files.readAllLines(path);
        boolean userFound = false;
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);
            String[] parts = line.split("\\" + DELIMITER, -1);
            if (parts.length >= 2 && parts[1].equals(user.getEmail())) {
                lines.set(i, String.join(DELIMITER,
                        user.getUsername(),
                        user.getEmail(),
                        user.password,
                        String.valueOf(user.getBirthDay()),
                        String.valueOf(user.getBirthMonth()),
                        String.valueOf(user.getBirthYear()),
                        user.getCity(),
                        String.valueOf(user.getWallet()),
                        String.valueOf(user.isDarkTheme()),
                        user.getWallpaperPath(),
                        user.subscriptionEndDate != null ? user.subscriptionEndDate.toString() : "null",
                        String.valueOf(user.hasSubscription())
                ));
                userFound = true;
                break;
            }
        }

        if (!userFound) {
            throw new IOException("User to update not found in database: " + user.getEmail());
        }

        Files.write(path, lines, StandardOpenOption.TRUNCATE_EXISTING);
    }


    private static final int SIGNUP_PORT = 12345;
    private static final int LOGIN_PORT = 12346;
    private static final int RESET_PASSWORD_PORT = 12347;
    private static final int PROFILE = 13579;
    private static final int REFRESH_USER_PORT = 13580;

    public static USER signUp(String username, String email, String password, int day, int month, int year, String city) throws IOException {
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("Username cannot be empty.");
        }
        if (email == null || !email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            throw new IllegalArgumentException("Invalid email format.");
        }
        if (password.length() < 8) {
            throw new IllegalArgumentException("Password must be at least 8 characters.");
        }
        if (findUserByEmail(email) != null) {
            throw new IllegalArgumentException("Email already registered.");
        }
        USER newUser = new USER(username, email, password,
                day, month, year, city);
        saveUserToDatabase(newUser);
        return newUser;
    }

    public static USER login(String email, String password) throws IOException {
        USER user = readUserFromFile(email, password);
        if (user == null) {
            throw new SecurityException("Invalid email or password.");
        }
        if (user.hasSubscription && user.subscriptionEndDate != null && LocalDate.now().isAfter(user.subscriptionEndDate)) {
            System.out.println("DEBUG: User " + user.email + "'s subscription expired on login. Resetting status.");
            user.hasSubscription = false;
            user.subscriptionEndDate = null;
            updateUserInFile(user);
        }
        user.isLoggedIn = true;
        return user;
    }

    private static class ClientHandler implements Runnable {
        private Socket clientSocket;
        public ClientHandler(Socket socket) { this.clientSocket = socket; }
        @Override
        public void run() {
            try (BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                 PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {
                String jsonRequest = in.readLine();
                System.out.println("Received JSON from Signup Client: " + jsonRequest);
                JSONObject responseJson = new JSONObject();
                try {
                    JSONObject userData = new JSONObject(jsonRequest);
                    String username = userData.getString("username");
                    String email = userData.getString("email");
                    String password = userData.getString("password");
                    int day = userData.getInt("birthDay");
                    int month = userData.getInt("birthMonth");
                    int year = userData.getInt("birthYear");
                    String city = userData.getString("city");
                    USER newUser = USER.signUp(username, email, password, day, month, year, city);
                    responseJson.put("status", "success");
                    responseJson.put("message", "User '" + newUser.getUsername() + "' signed up successfully!");
                    System.out.println("User signed up successfully: " + newUser.getUsername());
                    JSONObject userDetails = new JSONObject();
                    userDetails.put("username", newUser.getUsername());
                    userDetails.put("email", newUser.getEmail());
                    userDetails.put("city", newUser.getCity());
                    userDetails.put("wallet", newUser.getWallet());
                    userDetails.put("darkTheme", newUser.isDarkTheme());
                    userDetails.put("hasSubscription", newUser.hasSubscription());
                    userDetails.put("subscriptionEndDate", newUser.subscriptionEndDate != null ? newUser.subscriptionEndDate.toString() : JSONObject.NULL);
                    userDetails.put("wallpaperPath", newUser.getWallpaperPath());
                    userDetails.put("isLoggedIn", newUser.isLoggedIn());
                    responseJson.put("user", userDetails);
                } catch (IllegalArgumentException | SecurityException e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", e.getMessage());
                    System.err.println("Signup failed: " + e.getMessage());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred on the server: " + e.getMessage());
                    System.err.println("Unexpected signup server error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Signup Client: " + responseJson.toString());
                try { Thread.sleep(1000); System.out.println("DEBUG (Handler): Added 200ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
            } catch (IOException e) {
                System.err.println("Error handling signup client connection: " + e.getMessage());
            } finally {
                try { if (clientSocket != null) { clientSocket.close(); System.out.println("Signup Client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing signup client socket: " + e.getMessage()); }
            }
        }
    }

    private static class LoginClientHandler implements Runnable {
        private Socket clientSocket;
        public LoginClientHandler(Socket socket) { this.clientSocket = socket; }
        @Override
        public void run() {
            try (BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                 PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {
                String jsonRequest = in.readLine();
                System.out.println("Received JSON from Login Client: " + jsonRequest);
                JSONObject responseJson = new JSONObject();
                try {
                    JSONObject loginData = new JSONObject(jsonRequest);
                    String email = loginData.getString("email");
                    String password = loginData.getString("password");
                    USER loggedInUser = USER.login(email, password);
                    responseJson.put("status", "success");
                    responseJson.put("message", "Login successful!");
                    JSONObject userDetails = new JSONObject();
                    userDetails.put("username", loggedInUser.getUsername());
                    userDetails.put("email", loggedInUser.getEmail());
                    userDetails.put("city", loggedInUser.getCity());
                    userDetails.put("wallet", loggedInUser.getWallet());
                    userDetails.put("darkTheme", loggedInUser.isDarkTheme());
                    userDetails.put("hasSubscription", loggedInUser.hasSubscription());
                    userDetails.put("subscriptionEndDate", loggedInUser.subscriptionEndDate != null ? loggedInUser.subscriptionEndDate.toString() : JSONObject.NULL);
                    userDetails.put("wallpaperPath", loggedInUser.getWallpaperPath());
                    userDetails.put("isLoggedIn", loggedInUser.isLoggedIn());
                    responseJson.put("user", userDetails);
                    System.out.println("User '" + loggedInUser.getEmail() + "' logged in successfully.");
                } catch (SecurityException e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", e.getMessage());
                    System.err.println("Login failed: " + e.getMessage());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred on the server: " + e.getMessage());
                    System.err.println("Unexpected Login Server error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Login Client: " + responseJson.toString());
                try { Thread.sleep(1000); System.out.println("DEBUG (Handler): Added 200ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
            } catch (IOException e) {
                System.err.println("Error handling login client: " + e.getMessage());
            } finally {
                try { if (clientSocket != null) { clientSocket.close(); System.out.println("Login client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing login client socket: " + e.getMessage()); }
            }
        }
    }

    private static class LoginResetPassword implements Runnable {
        private Socket clientSocket;
        public LoginResetPassword(Socket socket) { this.clientSocket = socket; }
        @Override
        public void run() {
            try (BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                 PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {
                String jsonRequest = in.readLine();
                System.out.println("Received JSON from Reset Password Client: " + jsonRequest);
                JSONObject responseJson = new JSONObject();
                try {
                    JSONObject requestData = new JSONObject(jsonRequest);
                    String requestType = requestData.getString("type");
                    String city = requestData.getString("city");
                    int birthDay = requestData.getInt("birthDay");
                    int birthMonth = requestData.getInt("birthMonth");
                    int birthYear = requestData.getInt("birthYear");
                    USER targetUser = findUserByPersonalDetails(city, birthDay, birthMonth, birthYear);
                    if (targetUser == null) {
                        responseJson.put("status", "no");
                        responseJson.put("message", "Verification failed. Details do not match any user.");
                        System.out.println("Reset Password Verification failed for: " + city + ", " + birthYear);
                    } else {
                        if ("verify".equals(requestType)) {
                            responseJson.put("status", "ok");
                            responseJson.put("message", "Verification successful. You can now set your new password.");
                            System.out.println("Reset Password Verification successful for user: " + targetUser.getEmail());
                        } else if ("update".equals(requestType)) {
                            String newPassword = requestData.getString("newPassword");
                            if (newPassword.length() < 8) {
                                throw new IllegalArgumentException("New password must be at least 8 characters.");
                            }
                            targetUser.resetPassword(city, birthDay, birthMonth, birthYear, newPassword, newPassword);
                            responseJson.put("status", "success");
                            responseJson.put("message", "Password updated successfully for " + targetUser.getEmail());
                            System.out.println("Password updated successfully for user: " + targetUser.getEmail());
                        } else {
                            responseJson.put("status", "error");
                            responseJson.put("message", "Invalid request type for password reset.");
                            System.err.println("Invalid request type: " + requestType);
                        }
                    }
                } catch (SecurityException | IllegalArgumentException e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", e.getMessage());
                    System.err.println("Password Reset failed: " + e.getMessage());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred during password reset: " + e.getMessage());
                    System.err.println("Unexpected Reset Password Server error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Reset Password Client: " + responseJson.toString());
                try { Thread.sleep(1000); System.out.println("DEBUG (Handler): Added 200ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
            } catch (IOException e) {
                System.err.println("Error handling reset password client: " + e.getMessage());
            } finally {
                try { if (clientSocket != null) { clientSocket.close(); System.out.println("Reset Password Client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing reset password client socket: " + e.getMessage()); }
            }
        }
    }

    private static class Contact implements Runnable{
        private Socket clientSocket;
        private String jsonRequestString;
        public Contact(Socket socket, String jsonRequest) { this.clientSocket = socket; this.jsonRequestString = jsonRequest; }
        @Override
        public void run() {
            try(PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)){
                JSONObject responseJson = new JSONObject();
                try{
                    JSONObject requestData = new JSONObject(jsonRequestString);
                    String userEmail = requestData.getString("email");
                    String message = requestData.getString("message");
                    System.out.println("Received contact message from " + userEmail + ": " + message);
                    SupportTicket newTicket = new SupportTicket(userEmail, message);
                    writeSupportTicketToFile(newTicket);
                    System.out.println("Support ticket created: " + newTicket.getTicketId());
                    responseJson.put("status", "success");
                    responseJson.put("message", "Thank you for your message, " + userEmail + ". We have created ticket ID " + newTicket.getTicketId() + " and will get back to you shortly.");
                    responseJson.put("ticketId", newTicket.getTicketId());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "Failed to process message: " + e.getMessage());
                    System.err.println("Error processing contact client request: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Contact Client: " + responseJson.toString());
                try { Thread.sleep(1000); System.out.println("DEBUG (Handler): Added 200ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
            }catch (IOException e) {
                System.err.println("Error handling contact client connection: " + e.getMessage());
            }finally {
                try { if (clientSocket != null && !clientSocket.isClosed()) { clientSocket.close(); System.out.println("Contact client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing contact client socket: " + e.getMessage()); }
            }
        }
    }

    private static class Edit implements Runnable{
        private Socket clientSocket;
        private String jsonRequestString;
        public Edit(Socket socket, String jsonRequest) { this.clientSocket = socket; this.jsonRequestString = jsonRequest; }
        @Override
        public void run() {
            try(PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)){
                JSONObject responseJson = new JSONObject();
                try {
                    JSONObject requestData = new JSONObject(jsonRequestString);
                    String previousEmail = requestData.getString("previousEmail");
                    String currentPassword = requestData.getString("password");
                    String newUsername = requestData.getString("newUsername");
                    String newEmail = requestData.getString("newEmail");
                    String newPassword = requestData.optString("newPassword", "");
                    String confirmNewPassword = requestData.optString("confirmNewPassword", "");
                    USER userToUpdate = readUserFromFile(previousEmail, currentPassword);
                    if (userToUpdate == null) { throw new SecurityException("Invalid current email or password."); }
                    if (newUsername == null || newUsername.trim().isEmpty()) { throw new IllegalArgumentException("New username cannot be empty."); }
                    if (newEmail == null || !newEmail.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) { throw new IllegalArgumentException("Invalid new email format."); }
                    if (!newEmail.equals(previousEmail) && findUserByEmail(newEmail) != null) { throw new IllegalArgumentException("New email is already registered by another user."); }
                    if (!newPassword.isEmpty()) {
                        if (!newPassword.equals(confirmNewPassword)) { throw new IllegalArgumentException("New passwords do not match."); }
                        if (newPassword.length() < 8) { throw new IllegalArgumentException("New password must be at least 8 characters."); }
                        userToUpdate.setPassword(newPassword);
                    }
                    userToUpdate.setUsername(newUsername);
                    userToUpdate.setEmail(newEmail);
                    updateUserInFile(userToUpdate);
                    System.out.println("User profile updated for " + userToUpdate.getEmail());
                    responseJson.put("status", "success");
                    responseJson.put("message", "Profile updated successfully!");
                    JSONObject userDetails = new JSONObject();
                    userDetails.put("username", userToUpdate.getUsername());
                    userDetails.put("email", userToUpdate.getEmail());
                    userDetails.put("city", userToUpdate.getCity());
                    userDetails.put("wallet", userToUpdate.getWallet());
                    userDetails.put("darkTheme", userToUpdate.isDarkTheme());
                    userDetails.put("hasSubscription", userToUpdate.hasSubscription());
                    userDetails.put("subscriptionEndDate", userToUpdate.subscriptionEndDate != null ? userToUpdate.subscriptionEndDate.toString() : JSONObject.NULL);
                    userDetails.put("wallpaperPath", userToUpdate.getWallpaperPath());
                    userDetails.put("isLoggedIn", userToUpdate.isLoggedIn());
                    responseJson.put("user", userDetails);
                } catch (SecurityException | IllegalArgumentException e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", e.getMessage());
                    System.err.println("Edit profile failed: " + e.getMessage());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred during profile edit: " + e.getMessage());
                    System.err.println("Unexpected Edit Server error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Edit Client: " + responseJson.toString());
                try { Thread.sleep(1000); System.out.println("DEBUG (Handler): Added 200ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
            } catch (IOException e) {
                System.err.println("Error handling edit client connection: " + e.getMessage());
            } finally {
                try { if (clientSocket != null && !clientSocket.isClosed()) { clientSocket.close(); System.out.println("Edit client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing edit client socket: " + e.getMessage()); }
            }
        }
    }

    private static class Delete implements Runnable{
        private Socket clientSocket;
        private String jsonRequestString;
        public Delete(Socket socket, String jsonRequest) { this.clientSocket = socket; this.jsonRequestString = jsonRequest; }
        @Override
        public void run() {
            try(PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)){
                JSONObject responseJson = new JSONObject();
                try{
                    JSONObject requestData = new JSONObject(jsonRequestString);
                    String username = requestData.getString("username");
                    String email = requestData.getString("email");
                    String password = requestData.getString("password");
                    System.out.println("DEBUG (Delete Handler): Received Delete Request - Username: '" + username + "', Email: '" + email + "', Password: '" + password + "'");
                    Path path = Paths.get(USER_DATABASE);
                    if (Files.exists(path)) {
                        System.out.println("DEBUG (Delete Handler): Current USER.txt content before deletion attempt:");
                        Files.readAllLines(path).forEach(line -> System.out.println("  -> " + line));
                    } else {
                        System.out.println("DEBUG (Delete Handler): USER.txt does not exist.");
                    }
                    boolean isDeleted = DeleteUSerFromFile(username, email, password);
                    if (isDeleted) {
                        responseJson.put("status", "success");
                        responseJson.put("message", "Profile deleted successfully!");
                        System.out.println("User profile deleted: " + email);
                    }
                    else {
                        responseJson.put("status", "error");
                        responseJson.put("message", "Profile could not be deleted! User not found or credentials incorrect. Please check backend logs for details.");
                        System.err.println("Profile deletion failed for: " + email + ". User not found or credentials incorrect.");
                        System.err.println("DEBUG (Delete Handler): DeleteUSerFromFile returned false for username: '" + username + "', email: '" + email + "'");
                    }
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred during profile deletion: " + e.getMessage());
                    System.err.println("Unexpected error during profile deletion: " + e.getMessage());
                    e.printStackTrace();
                } finally {
                    out.println(responseJson.toString());
                    System.out.println("DEBUG (Delete Handler): Sent response to Delete Client: " + responseJson.toString());
                    try { Thread.sleep(1000); System.out.println("DEBUG (Delete Handler): Added 200ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
                }
            }catch (IOException e) {
                System.err.println("Error handling delete client connection: " + e.getMessage());
            } finally {
                try { if (clientSocket != null && !clientSocket.isClosed()) { clientSocket.close(); System.out.println("Delete client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing delete client socket: " + e.getMessage()); }
            }
        }
    }

    private static class BuyPremiumHandler implements Runnable{
        private  Socket clientSocket;
        private String jsonRequestString;
        public BuyPremiumHandler(Socket socket, String jsonRequest) { this.clientSocket = socket; this.jsonRequestString = jsonRequest; }
        @Override
        public void run() {
            try(PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)){
                JSONObject responseJson = new JSONObject();
                try {
                    JSONObject requestData = new JSONObject(jsonRequestString);
                    String userEmail = requestData.getString("email");
                    int months = requestData.getInt("months");
                    USER targetUser = findUserByEmail(userEmail);
                    if (targetUser == null) { throw new IllegalArgumentException("User not found for premium purchase: " + userEmail); }
                    targetUser.buyPremium(months);
                    updateUserInFile(targetUser);
                    responseJson.put("status", "success");
                    responseJson.put("message", "Premium subscription activated successfully!");
                    JSONObject userDetails = new JSONObject();
                    userDetails.put("username", targetUser.getUsername());
                    userDetails.put("email", targetUser.getEmail());
                    userDetails.put("city", targetUser.getCity());
                    userDetails.put("wallet", targetUser.getWallet());
                    userDetails.put("darkTheme", targetUser.isDarkTheme());
                    userDetails.put("hasSubscription", targetUser.hasSubscription());
                    userDetails.put("subscriptionEndDate", targetUser.subscriptionEndDate != null ? targetUser.subscriptionEndDate.toString() : JSONObject.NULL);
                    userDetails.put("wallpaperPath", targetUser.getWallpaperPath());
                    userDetails.put("isLoggedIn", targetUser.isLoggedIn());
                    responseJson.put("user", userDetails);
                    System.out.println("Premium purchased for user: " + userEmail + " for " + months + " months.");
                } catch (IllegalStateException | IllegalArgumentException | IOException e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", e.getMessage());
                    System.err.println("Premium purchase failed: " + e.getMessage());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred during premium purchase: " + e.getMessage());
                    System.err.println("Unexpected Premium Purchase Server error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Buy Premium Client: " + responseJson.toString());
                try { Thread.sleep(1000); System.out.println("DEBUG (Handler): Added 200ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
            } catch (IOException e) {
                System.err.println("Error handling Buy Premium client connection: " + e.getMessage());
            } finally {
                try { if (clientSocket != null) { clientSocket.close(); System.out.println("Buy Premium Client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing Buy Premium client socket: " + e.getMessage()); }
            }
        }
    }

    private static class ChangeWallpaperHandler implements Runnable {
        private Socket clientSocket;
        private String jsonRequestString;
        public ChangeWallpaperHandler(Socket socket, String jsonRequest) { this.clientSocket = socket; this.jsonRequestString = jsonRequest; }
        @Override
        public void run() {
            try (PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {
                JSONObject responseJson = new JSONObject();
                try {
                    JSONObject requestData = new JSONObject(jsonRequestString);
                    String userEmail = requestData.getString("email");
                    String base64ImageData = requestData.getString("imageData");
                    String fileExtension = requestData.getString("fileExtension");
                    USER targetUser = findUserByEmail(userEmail);
                    if (targetUser == null) { throw new IllegalArgumentException("User not found for wallpaper change: " + userEmail); }
                    byte[] imageBytes = Base64.getDecoder().decode(base64ImageData);
                    if (!isValidImageExtension(fileExtension)) { throw new IllegalArgumentException("Invalid file extension: " + fileExtension); }
                    String uniqueFileName = UUID.randomUUID().toString() + "." + fileExtension;
                    Path uploadDirPath = Paths.get(PROFILE_PICTURE_UPLOAD_DIR);
                    if (!Files.exists(uploadDirPath)) { Files.createDirectories(uploadDirPath); }
                    Path imageFilePath = uploadDirPath.resolve(uniqueFileName);
                    Files.write(imageFilePath, imageBytes);
                    System.out.println("Image saved to: " + imageFilePath.toString());
                    targetUser.changeWallpaper(uniqueFileName);
                    updateUserInFile(targetUser);
                    responseJson.put("status", "success");
                    responseJson.put("message", "Wallpaper updated successfully!");
                    JSONObject userDetails = new JSONObject();
                    userDetails.put("username", targetUser.getUsername());
                    userDetails.put("email", targetUser.getEmail());
                    userDetails.put("city", targetUser.getCity());
                    userDetails.put("wallet", targetUser.getWallet());
                    userDetails.put("darkTheme", targetUser.isDarkTheme());
                    userDetails.put("hasSubscription", targetUser.hasSubscription());
                    userDetails.put("subscriptionEndDate", targetUser.subscriptionEndDate != null ? targetUser.subscriptionEndDate.toString() : JSONObject.NULL);
                    userDetails.put("wallpaperPath", targetUser.getWallpaperPath());
                    userDetails.put("isLoggedIn", targetUser.isLoggedIn());
                    responseJson.put("user", userDetails);
                    System.out.println("Wallpaper updated for user: " + userEmail + " to file: " + uniqueFileName);
                } catch (IllegalArgumentException | IOException e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", e.getMessage());
                    System.err.println("Wallpaper change failed: " + e.getMessage());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred during wallpaper change: " + e.getMessage());
                    System.err.println("Unexpected Wallpaper Change Server error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Change Wallpaper Client: " + responseJson.toString());
                try { Thread.sleep(1000); System.out.println("DEBUG (Handler): Added 200ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
            } catch (IOException e) {
                System.err.println("Error handling Change Wallpaper client connection: " + e.getMessage());
            } finally {
                try { if (clientSocket != null) { clientSocket.close(); System.out.println("Change Wallpaper Client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing Change Wallpaper client socket: " + e.getMessage()); }
            }
        }
        private boolean isValidImageExtension(String extension) {
            if (extension == null || extension.trim().isEmpty()) { return false; }
            String lowerCaseExtension = extension.toLowerCase();
            return lowerCaseExtension.equals("jpg") || lowerCaseExtension.equals("jpeg") || lowerCaseExtension.equals("png") || lowerCaseExtension.equals("gif") || lowerCaseExtension.equals("bmp");
        }
    }

    private static class AddFundsHandler implements Runnable {
        private Socket clientSocket;
        private String jsonRequestString;
        public AddFundsHandler(Socket socket, String jsonRequest) { this.clientSocket = socket; this.jsonRequestString = jsonRequest; }
        @Override
        public void run() {
            try (PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {
                JSONObject responseJson = new JSONObject();
                try {
                    JSONObject requestData = new JSONObject(jsonRequestString);
                    String userEmail = requestData.getString("email");
                    long amount = requestData.getLong("amount");
                    USER targetUser = findUserByEmail(userEmail);
                    if (targetUser == null) { throw new IllegalArgumentException("User not found for adding funds: " + userEmail); }
                    targetUser.addFunds(amount);
                    updateUserInFile(targetUser);
                    responseJson.put("status", "success");
                    responseJson.put("message", "Successfully added " + amount + " to your wallet. New balance: " + targetUser.getWallet());
                    JSONObject userDetails = new JSONObject();
                    userDetails.put("username", targetUser.getUsername());
                    userDetails.put("email", targetUser.getEmail());
                    userDetails.put("city", targetUser.getCity());
                    userDetails.put("wallet", targetUser.getWallet());
                    userDetails.put("darkTheme", targetUser.isDarkTheme());
                    userDetails.put("hasSubscription", targetUser.hasSubscription());
                    userDetails.put("subscriptionEndDate", targetUser.subscriptionEndDate != null ? targetUser.subscriptionEndDate.toString() : JSONObject.NULL);
                    userDetails.put("wallpaperPath", targetUser.getWallpaperPath());
                    userDetails.put("isLoggedIn", targetUser.isLoggedIn());
                    responseJson.put("user", userDetails);
                    System.out.println("Funds added to user: " + userEmail + ". New wallet balance: " + targetUser.getWallet());
                } catch (IllegalArgumentException | IOException e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", e.getMessage());
                    System.err.println("Adding funds failed: " + e.getMessage());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred during adding funds: " + e.getMessage());
                    System.err.println("Unexpected Add Funds Server error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Add Funds Client: " + responseJson.toString());
                try { Thread.sleep(1000); System.out.println("DEBUG (Handler): Added 1000ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
            } catch (IOException e) {
                System.err.println("Error handling Add Funds client connection: " + e.getMessage());
            } finally {
                try { if (clientSocket != null) { clientSocket.close(); System.out.println("Add Funds Client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing Add Funds client socket: " + e.getMessage()); }
            }
        }
    }

    private static class changeTheme implements Runnable{
        private Socket clientSocket;
        private String jsonRequestString;
        public changeTheme(Socket socket, String jsonRequest) { this.clientSocket = socket; this.jsonRequestString = jsonRequest; }
        @Override
        public void run() {
            try (PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {
                JSONObject responseJson = new JSONObject();
                try {
                    JSONObject requestData = new JSONObject(jsonRequestString);
                    String userEmail = requestData.getString("email");
                    boolean isDark = requestData.getBoolean("isDark");
                    System.out.println("DEBUG (ChangeTheme Handler): Received Change Theme Request for email: '" + userEmail + "', isDark: " + isDark);
                    USER targetUser = findUserByEmail(userEmail);
                    if (targetUser == null) { throw new IllegalArgumentException("User not found for theme change: " + userEmail); }
                    targetUser.setDarkTheme(isDark);
                    updateUserInFile(targetUser);
                    responseJson.put("status", "success");
                    responseJson.put("message", "Theme preference updated successfully!");
                    JSONObject userDetails = new JSONObject();
                    userDetails.put("username", targetUser.getUsername());
                    userDetails.put("email", targetUser.getEmail());
                    userDetails.put("city", targetUser.getCity());
                    userDetails.put("wallet", targetUser.getWallet());
                    userDetails.put("darkTheme", targetUser.isDarkTheme());
                    userDetails.put("hasSubscription", targetUser.hasSubscription());
                    userDetails.put("subscriptionEndDate", targetUser.subscriptionEndDate != null ? targetUser.subscriptionEndDate.toString() : JSONObject.NULL);
                    userDetails.put("wallpaperPath", targetUser.getWallpaperPath());
                    userDetails.put("isLoggedIn", targetUser.isLoggedIn());
                    responseJson.put("user", userDetails);
                    System.out.println("Theme updated for user: " + userEmail + " to darkTheme: " + isDark);
                } catch (IllegalArgumentException | IOException e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", e.getMessage());
                    System.err.println("Theme change failed: " + e.getMessage());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred during theme change: " + e.getMessage());
                    System.err.println("Unexpected Theme Change Server error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Change Theme Client: " + responseJson.toString());
                try { Thread.sleep(1000); System.out.println("DEBUG (Handler): Added 200ms delay before socket close."); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); System.err.println("DEBUG (Handler): Delay was interrupted."); }
            } catch (IOException e) {
                System.err.println("Error handling Change Theme client connection: " + e.getMessage());
            } finally {
                try { if (clientSocket != null) { clientSocket.close(); System.out.println("Change Theme Client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing Change Theme client socket: " + e.getMessage()); }
            }
        }
    }

    private static class GetUserHandler implements Runnable {
        private Socket clientSocket;
        public GetUserHandler(Socket clientSocket) { this.clientSocket = clientSocket; }
        @Override
        public void run() {
            try (BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                 PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {
                String jsonRequestString = in.readLine();
                JSONObject responseJson = new JSONObject();
                if (jsonRequestString == null || jsonRequestString.trim().isEmpty()) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "Received empty request.");
                    System.err.println("Received empty or null JSON request from Get User Client.");
                    out.println(responseJson.toString());
                    return;
                }
                System.out.println("Received JSON from Refresh User Client: " + jsonRequestString);
                try {
                    JSONObject requestData = new JSONObject(jsonRequestString);
                    String userEmail = requestData.getString("email");
                    USER targetUser = findUserByEmail(userEmail);
                    if (targetUser == null) { throw new IllegalArgumentException("User not found: " + userEmail); }
                    if (targetUser.hasSubscription && targetUser.subscriptionEndDate != null && LocalDate.now().isAfter(targetUser.subscriptionEndDate)) {
                        System.out.println("DEBUG: User " + targetUser.email + "'s subscription expired on refresh. Resetting status.");
                        targetUser.hasSubscription = false;
                        targetUser.subscriptionEndDate = null;
                        updateUserInFile(targetUser);
                    }
                    JSONObject userDetails = new JSONObject();
                    userDetails.put("username", targetUser.getUsername());
                    userDetails.put("email", targetUser.getEmail());
                    userDetails.put("city", targetUser.getCity());
                    userDetails.put("wallet", targetUser.getWallet());
                    userDetails.put("darkTheme", targetUser.isDarkTheme());
                    userDetails.put("hasSubscription", targetUser.hasSubscription());
                    userDetails.put("subscriptionEndDate", targetUser.subscriptionEndDate != null ? targetUser.subscriptionEndDate.toString() : JSONObject.NULL);
                    userDetails.put("wallpaperPath", targetUser.getWallpaperPath());
                    userDetails.put("isLoggedIn", targetUser.isLoggedIn());
                    responseJson.put("status", "success");
                    responseJson.put("user", userDetails);
                    responseJson.put("message", "User data refreshed successfully.");
                    System.out.println("User data retrieved for: " + userEmail);
                } catch (IllegalArgumentException | IOException e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", e.getMessage());
                    System.err.println("User data refresh failed: " + e.getMessage());
                } catch (Exception e) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "An unexpected error occurred during user data refresh: " + e.getMessage());
                    System.err.println("Unexpected Get User Server error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println(responseJson.toString());
                System.out.println("Sent response to Get User Client: " + responseJson.toString());
                try { Thread.sleep(1000); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }
            } catch (IOException e) {
                System.err.println("Error handling Get User client connection: " + e.getMessage());
            } finally {
                try { if (clientSocket != null) { clientSocket.close(); System.out.println("Get User Client disconnected: " + clientSocket.getInetAddress().getHostAddress()); } } catch (IOException e) { System.err.println("Error closing Get User client socket: " + e.getMessage()); }
            }
        }
    }


    // ===== Getters & Setters (No changes) =====
    public String getUsername() { return username; }
    public void setUsername(String username) { if (username == null || username.trim().isEmpty()) { throw new IllegalArgumentException("Username cannot be empty."); } this.username = username.trim(); }
    public String getEmail() { return email; }
    public void setEmail(String email) { if (email == null || !email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) { throw new IllegalArgumentException("Invalid email format."); } this.email = email.trim(); }
    public void setPassword(String password) { this.password = password; }
    public int getBirthDay() { return birthDay; }
    public int getBirthMonth() { return birthMonth; }
    public int getBirthYear() { return birthYear; }
    public void setBirthDate(int day, int month, int year) { try { LocalDate.of(year, month, day); this.birthDay = day; this.birthMonth = month; this.birthYear = year; } catch (Exception e) { throw new IllegalArgumentException("Invalid date."); } }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = (city != null) ? city.trim() : "Unknown"; }
    public long getWallet() { return wallet; }
    public void setWallet(long amount) { if (amount < 0) { throw new IllegalArgumentException("Wallet balance cannot be negative."); } this.wallet = amount; }
    public boolean isDarkTheme() { return darkTheme; }
    public void setDarkTheme(boolean darkTheme) { this.darkTheme = darkTheme; }
    public boolean hasSubscription() { return hasSubscription; }
    public void setSubscription(boolean hasSubscription) { this.hasSubscription = hasSubscription; }
    public boolean isLoggedIn() { return isLoggedIn; }
    public String getWallpaperPath() { return wallpaperPath; }
    public void logout() { this.isLoggedIn = false; }
    public void addFunds(long amount) throws IOException { if (amount <= 0) { throw new IllegalArgumentException("Amount must be positive."); } this.wallet += amount; updateUserInFile(this); }
    public void editProfile(String newUsername, String currentPassword, String newPassword) throws IOException { USER currentUser = findUserByEmail(this.email); if (currentUser == null) { throw new IOException("Current user not found in database."); } if (!currentUser.password.equals(currentPassword)) { throw new SecurityException("Current password is incorrect."); } currentUser.setUsername(newUsername); currentUser.setPassword(newPassword); updateUserInFile(currentUser); this.username = newUsername; this.password = newPassword; }
    public void buyPremium(int months) throws IOException { if (months != 1 && months != 3 && months != 6) { throw new IllegalArgumentException("Invalid subscription period. Choose 1, 3, or 6 months."); } long cost = months * 100000L; if (wallet < cost) { throw new IllegalStateException("Insufficient funds in wallet."); } this.wallet -= cost; this.hasSubscription = true; this.subscriptionEndDate = LocalDate.now().plusMonths(months); updateUserInFile(this); }
    public void deleteAccount() throws IOException { this.username = "Deleted User"; this.email = ""; this.password = ""; this.birthDay = 0; this.birthMonth = 0; this.birthYear = 0; this.city = ""; this.wallet = 0; this.darkTheme = false; this.hasSubscription = false; this.subscriptionEndDate = null; this.isLoggedIn = false; this.wallpaperPath = ""; }
    public void changeWallpaper(String newWallpaperPath) throws IOException { if (newWallpaperPath == null || newWallpaperPath.trim().isEmpty()) { throw new IllegalArgumentException("Wallpaper path cannot be empty."); } this.wallpaperPath = newWallpaperPath; updateUserInFile(this); }
    public void resetPassword(String currentCity, int currentDay, int currentMonth, int currentYear, String newPassword, String confirmNewPassword) throws IOException { USER userToReset = findUserByPersonalDetails(currentCity, currentDay, currentMonth, currentYear); if (userToReset == null) { throw new SecurityException("User verification failed for reset. Details do not match any user."); } if (!newPassword.equals(confirmNewPassword)) { throw new IllegalArgumentException("New passwords do not match."); } if (newPassword.length() < 8) { throw new IllegalArgumentException("New password must be at least 8 characters."); } userToReset.setPassword(newPassword); updateUserInFile(userToReset); }
    public boolean isSubscriptionActive() { if (!hasSubscription) return false; if (subscriptionEndDate == null) return false; return !LocalDate.now().isAfter(subscriptionEndDate); }
    public int getAge() { if (birthYear == 0) return 0; return Period.between(LocalDate.of(birthYear, birthMonth, birthDay), LocalDate.now()).getYears(); }
    public String getSubscriptionStatus() { if (!hasSubscription) return "No active subscription"; if (subscriptionEndDate == null || LocalDate.now().isAfter(subscriptionEndDate)) { return "Subscription expired"; } return "Active until " + subscriptionEndDate.toString(); }
    @Override public boolean equals(Object o) { if (this == o) return true; if (o == null || getClass() != o.getClass()) return false; USER user = (USER) o; return email.equals(user.email); }
    @Override public int hashCode() { return Objects.hash(email); }
    @Override public String toString() { return String.format("User: %s | Email: %s | City: %s | Wallet: %,d | Subscription: %s", username, email, city, wallet, getSubscriptionStatus()); }

    public static void main(String[] args) {
        new Thread(() -> {
            try (ServerSocket serverSocket = new ServerSocket(SIGNUP_PORT)) {
                System.out.println("Signup Server started on port " + SIGNUP_PORT + "...");
                System.out.println("Waiting for signup client connections...");
                while (true) {
                    Socket clientSocket = serverSocket.accept();
                    System.out.println("Signup Client connected: " + clientSocket.getInetAddress().getHostAddress());
                    new Thread(new ClientHandler(clientSocket)).start();
                }
            } catch (IOException e) {
                System.err.println("Signup Server error: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();

        new Thread(() -> {
            try (ServerSocket serverSocket = new ServerSocket(LOGIN_PORT)) {
                System.out.println("Login Server started on port " + LOGIN_PORT + "...");
                System.out.println("Waiting for login client connections...");
                while (true) {
                    Socket clientSocket = serverSocket.accept();
                    System.out.println("Login Client connected: " + clientSocket.getInetAddress().getHostAddress());
                    new Thread(new LoginClientHandler(clientSocket)).start();
                }
            } catch (IOException e) {
                System.err.println("Login Server error: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();

        new Thread(() -> {
            try (ServerSocket serverSocket = new ServerSocket(RESET_PASSWORD_PORT)) {
                System.out.println("Reset Password Server started on port " + RESET_PASSWORD_PORT + "...");
                System.out.println("Waiting for reset password client connections...");
                while (true) {
                    Socket clientSocket = serverSocket.accept();
                    System.out.println("Reset Password Client connected: " + clientSocket.getInetAddress().getHostAddress());
                    new Thread(new LoginResetPassword(clientSocket)).start();
                }
            } catch (IOException e) {
                System.err.println("Reset Password Server error: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();

        new Thread(() -> {
            try (ServerSocket serverSocket = new ServerSocket(REFRESH_USER_PORT)) {
                System.out.println("Refresh User Server started on port " + REFRESH_USER_PORT + "...");
                System.out.println("Waiting for refresh user client connections...");
                while (true) {
                    Socket clientSocket = serverSocket.accept();
                    System.out.println("Refresh User Client connected: " + clientSocket.getInetAddress().getHostAddress());
                    new Thread(new GetUserHandler(clientSocket)).start();
                }
            } catch (IOException e) {
                System.err.println("Refresh User Server error: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();

        new Thread(() -> {
            try (ServerSocket serverSocket = new ServerSocket(PROFILE)) {
                System.out.println("Profile Server started on port " + PROFILE + "...");
                System.out.println("Waiting for profile client connections...");
                while (true) {
                    Socket clientSocket = serverSocket.accept();
                    System.out.println("Profile Client connected: " + clientSocket.getInetAddress().getHostAddress());
                    String jsonRequest = null;
                    try {
                        BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                        jsonRequest = in.readLine();
                        if (jsonRequest == null || jsonRequest.trim().isEmpty()) {
                            System.err.println("Received empty or null JSON request from Profile Client. Closing socket.");
                            clientSocket.close();
                            continue;
                        }
                        System.out.println("Received JSON from Profile Client: " + jsonRequest);
                        JSONObject request = new JSONObject(jsonRequest);
                        String action = request.getString("action");
                        switch (action){
                            case "contact" : new Thread(new Contact(clientSocket, jsonRequest)).start(); break;
                            case "editProfile" : new Thread(new Edit(clientSocket, jsonRequest)).start(); break;
                            case "deleteProfile" : new Thread(new Delete(clientSocket, jsonRequest)).start(); break;
                            case "changeWallpaper": new Thread(new ChangeWallpaperHandler(clientSocket, jsonRequest)).start(); break;
                            case "buyPremium": new Thread(new BuyPremiumHandler(clientSocket, jsonRequest)).start(); break;
                            case "changeTheme": new Thread(new changeTheme(clientSocket, jsonRequest)).start(); break;
                            case "addFunds": new Thread(new AddFundsHandler(clientSocket, jsonRequest)).start(); break;
                            default:
                                System.err.println("Unknown action received for Profile Server: " + action + ". Closing socket.");
                                try (PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {
                                    JSONObject errorResponse = new JSONObject();
                                    errorResponse.put("status", "error");
                                    errorResponse.put("message", "Unknown action: " + action);
                                    out.println(errorResponse.toString());
                                }
                                clientSocket.close();
                                break;
                        }
                    } catch (Exception e){
                        System.err.println("Error processing Profile Client request: " + e.getMessage());
                        e.printStackTrace();
                        try (PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true)) {
                            JSONObject errorResponse = new JSONObject();
                            errorResponse.put("status", "error");
                            errorResponse.put("message", "Server error processing request: " + e.getMessage());
                            out.println(errorResponse.toString());
                        } catch (IOException ioException) {
                            System.err.println("Error sending error response: " + ioException.getMessage());
                        }
                        clientSocket.close();
                    }
                }
            } catch (IOException e) {
                System.err.println("Profile Server error: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();

        // NEW: Start the dedicated Image Server
        new Thread(new ImageServer()).start();

        System.out.println("All servers launched.");
    }
}
