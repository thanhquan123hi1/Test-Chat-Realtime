package com.example.chat.service;

import com.example.chat.entity.RoomEntity;
import com.example.chat.repository.RoomRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class RoomService {
    private final RoomRepository roomRepository;

    public RoomService(RoomRepository roomRepository) {
        this.roomRepository = roomRepository;
    }

    public RoomEntity createRoom(String name, String description) {
        RoomEntity room = new RoomEntity();
        room.setName(name);
        room.setDescription(description);
        return roomRepository.save(room);
    }

    public Optional<RoomEntity> findById(String id) {
        return roomRepository.findById(id);
    }

    public List<RoomEntity> findAll() {
        return roomRepository.findAll();
    }

    public void addMemberToRoom(String roomId, String userId) {
        Optional<RoomEntity> roomOpt = findById(roomId);
        if (roomOpt.isPresent()) {
            RoomEntity room = roomOpt.get();
            if (!room.getMemberIds().contains(userId)) {
                room.getMemberIds().add(userId);
                roomRepository.save(room);
            }
        }
    }
}

