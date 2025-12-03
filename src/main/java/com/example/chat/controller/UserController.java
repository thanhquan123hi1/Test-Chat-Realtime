package com.example.chat.controller;

import com.example.chat.entity.UserEntity;
import com.example.chat.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/create")
    public ResponseEntity<UserEntity> createUser(@RequestParam String username) {
        UserEntity user = userService.getOrCreateUser(username);
        return ResponseEntity.ok(user);
    }
}

