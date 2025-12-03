package com.example.chat.controller;

import com.example.chat.entity.RoomEntity;
import com.example.chat.service.RoomService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/rooms")
public class RoomController {
    private final RoomService roomService;

    public RoomController(RoomService roomService) {
        this.roomService = roomService;
    }

    @GetMapping
    public ResponseEntity<List<RoomEntity>> getAllRooms() {
        try {
            List<RoomEntity> rooms = roomService.findAll();
            return ResponseEntity.ok(rooms != null ? rooms : new ArrayList<>());
        } catch (Exception e) {
            System.err.println("Error loading rooms: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.ok(new ArrayList<>()); // Trả về list rỗng thay vì lỗi
        }
    }
}

