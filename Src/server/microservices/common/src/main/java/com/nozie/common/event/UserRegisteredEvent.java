package com.nozie.common.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserRegisteredEvent implements Serializable {
    private Long userId;
    private String username;
    private String email;

    // Profile info to be saved in Customer Service
    private String fullName;
    private String phoneNumber;
    private String dateOfBirth;
    private String gender;
    private String country;
    private String avatarUrl;
    private String bio;
    private List<String> genres;
}
