package com.example.chat.config;

import com.example.chat.service.RoomService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {
    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);
    private final RoomService roomService;

    public DataInitializer(RoomService roomService) {
        this.roomService = roomService;
    }

    @Override
    public void run(String... args) {
        try {
            if (roomService.findAll().isEmpty()) {
                log.info("Initializing default rooms...");
                roomService.createRoom("General", "Phòng chat chung cho mọi người");
                roomService.createRoom("Tech", "Thảo luận về công nghệ");
                roomService.createRoom("Random", "Chat tự do về mọi chủ đề");
                log.info("Default rooms created successfully!");
            } else {
                log.info("Rooms already exist, skipping initialization.");
            }
        } catch (Exception e) {
            log.error("Error initializing rooms. Make sure MongoDB is running: " + e.getMessage(), e);
            // Không throw exception để ứng dụng vẫn có thể chạy
        }
    }
}

