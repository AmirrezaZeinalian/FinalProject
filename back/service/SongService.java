package com.example.backendtest1.service;

import com.example.backendtest1.model.Song;
import com.example.backendtest1.repository.SongRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SongService {

    private final SongRepository songRepository;

    public SongService(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    // گرفتن همه آهنگ‌ها
    public List<Song> getAllSongs() {
        return songRepository.findAll();
    }

    // اضافه کردن آهنگ جدید
    public Song addSong(Song song) {
        return songRepository.save(song);
    }

    // حذف یک آهنگ با ID مشخص
    public void deleteSong(Long id) {
        songRepository.deleteById(id);
    }
}
