package com.example.backendtest1.controller;

import com.example.backendtest1.model.Song;
import com.example.backendtest1.service.SongService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/songs")
@CrossOrigin(origins = "*") // اجازه اتصال از هر مبدا
public class SongController {

    private final SongService songService;

    public SongController(SongService songService) {
        this.songService = songService;
    }

    // گرفتن همه آهنگ‌ها
    @GetMapping
    public List<Song> getAllSongs() {
        return songService.getAllSongs();
    }

    // اضافه کردن آهنگ جدید
    @PostMapping
    public Song addSong(@RequestBody Song song) {
        return songService.addSong(song);
    }

    // حذف یک آهنگ با ID مشخص
    @DeleteMapping("/{id}")
    public String deleteSong(@PathVariable Long id) {
        songService.deleteSong(id);
        return "Song with ID " + id + " deleted!";
    }
}
