package com.example.chat.service;

import com.example.chat.entity.MessageEntity;
import com.example.chat.repository.MessageRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class MessageService {
    private final MessageRepository messageRepository;

    public MessageService(MessageRepository messageRepository) {
        this.messageRepository = messageRepository;
    }

    public MessageEntity saveMessage(String roomId, String senderId, String content) {
        MessageEntity message = new MessageEntity();
        message.setRoomId(roomId);
        message.setSenderId(senderId);
        message.setContent(content);
        message.setCreatedAt(LocalDateTime.now());
        return messageRepository.save(message);
    }

    public List<MessageEntity> getLatestMessages(String roomId, int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        return messageRepository.findByRoomIdOrderByCreatedAtDesc(roomId, pageable);
    }
}

