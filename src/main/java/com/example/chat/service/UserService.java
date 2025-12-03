package com.example.chat.service;

import com.example.chat.entity.UserEntity;
import com.example.chat.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserEntity createUser(String username, String displayName) {
        UserEntity user = new UserEntity();
        user.setUsername(username);
        user.setDisplayName(displayName);
        return userRepository.save(user);
    }

    public Optional<UserEntity> findById(String id) {
        return userRepository.findById(id);
    }

    public Optional<UserEntity> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public UserEntity getOrCreateUser(String username) {
        return findByUsername(username)
                .orElseGet(() -> createUser(username, username));
    }
}

