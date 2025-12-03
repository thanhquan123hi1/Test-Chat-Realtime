package com.example.chat.repository;

import com.example.chat.entity.RoomEntity;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RoomRepository extends MongoRepository<RoomEntity, String> {
}

