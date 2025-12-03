package com.example.chat.controller;

import com.example.chat.dto.ChatMessageDTO;
import com.example.chat.entity.MessageEntity;
import com.example.chat.entity.UserEntity;
import com.example.chat.service.MessageService;
import com.example.chat.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class ChatController {
    private final MessageService messageService;
    private final UserService userService;
    private final SimpMessagingTemplate messagingTemplate;

    public ChatController(MessageService messageService, UserService userService, SimpMessagingTemplate messagingTemplate) {
        this.messageService = messageService;
        this.userService = userService;
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/chat.sendMessage")
    public void sendMessage(ChatMessageDTO chatMessage) {
        // Lưu message vào MongoDB
        MessageEntity savedMessage = messageService.saveMessage(
                chatMessage.getRoomId(),
                chatMessage.getSenderId(),
                chatMessage.getContent()
        );

        // Lấy thông tin sender
        UserEntity sender = userService.findById(chatMessage.getSenderId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Tạo DTO để broadcast
        ChatMessageDTO response = new ChatMessageDTO();
        response.setSenderId(sender.getId());
        response.setSenderName(sender.getDisplayName());
        response.setRoomId(chatMessage.getRoomId());
        response.setContent(chatMessage.getContent());
        response.setTimestamp(savedMessage.getCreatedAt());

        // Broadcast message tới topic /topic/rooms/{roomId}
        messagingTemplate.convertAndSend("/topic/rooms/" + chatMessage.getRoomId(), response);
    }

    @GetMapping("/rooms/{roomId}/messages")
    public ResponseEntity<List<ChatMessageDTO>> getMessages(@PathVariable String roomId) {
        List<MessageEntity> messages = messageService.getLatestMessages(roomId, 20);
        
        List<ChatMessageDTO> messageDTOs = messages.stream()
                .map(msg -> {
                    UserEntity sender = userService.findById(msg.getSenderId())
                            .orElse(null);
                    
                    ChatMessageDTO dto = new ChatMessageDTO();
                    dto.setSenderId(msg.getSenderId());
                    dto.setSenderName(sender != null ? sender.getDisplayName() : "Unknown");
                    dto.setRoomId(msg.getRoomId());
                    dto.setContent(msg.getContent());
                    dto.setTimestamp(msg.getCreatedAt());
                    return dto;
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(messageDTOs);
    }
}

