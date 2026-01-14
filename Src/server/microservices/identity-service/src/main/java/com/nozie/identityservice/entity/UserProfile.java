package com.nozie.identityservice.entity;

import lombok.*;
import jakarta.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "user_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfile {

    @Id
    private Long userId;

    @OneToOne
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "full_name")
    private String fullName;

    @Column(name = "date_of_birth")
    private String dateOfBirth;

    private String country;

    private String gender;

    private String age;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @ElementCollection
    @CollectionTable(name = "user_interests", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "genre")
    @Builder.Default
    private Set<String> genres = new HashSet<>();
}
