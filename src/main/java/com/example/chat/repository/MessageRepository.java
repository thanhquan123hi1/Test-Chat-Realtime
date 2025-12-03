package com.example.chat.repository;

import com.example.chat.entity.MessageEntity;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends MongoRepository<MessageEntity, String> {
    List<MessageEntity> findByRoomIdOrderByCreatedAtDesc(String roomId, Pageable pageable);
}

