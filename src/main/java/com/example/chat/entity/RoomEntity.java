package com.example.chat.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

@Document(collection = "rooms")
public class RoomEntity {
    @Id
    private String id;
    private String name;
    private String description;
    private List<String> memberIds = new ArrayList<>();

    public RoomEntity() {
    }

    public RoomEntity(String id, String name, String description, List<String> memberIds) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.memberIds = memberIds != null ? memberIds : new ArrayList<>();
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<String> getMemberIds() {
        return memberIds;
    }

    public void setMemberIds(List<String> memberIds) {
        this.memberIds = memberIds;
    }
}

