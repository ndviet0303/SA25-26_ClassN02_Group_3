package com.nozie.identityservice.mapper;

import com.nozie.identityservice.dto.response.UserResponse;
import com.nozie.identityservice.entity.Permission;
import com.nozie.identityservice.entity.Role;
import com.nozie.identityservice.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface UserMapper {

    @Mapping(target = "status", expression = "java(user.getStatus().name())")
    @Mapping(target = "roles", source = "roles", qualifiedByName = "mapRoles")
    @Mapping(target = "permissions", source = "roles", qualifiedByName = "mapPermissions")
    @Mapping(target = "lastLoginAt", expression = "java(user.getLastLoginAt() != null ? user.getLastLoginAt().toString() : \"\")")
    @Mapping(target = "createdAt", expression = "java(user.getCreatedAt().toString())")
    @Mapping(target = "fullName", source = "profile.fullName")
    @Mapping(target = "avatarUrl", source = "profile.avatarUrl")
    @Mapping(target = "phone", source = "user", qualifiedByName = "mapPhone")
    @Mapping(target = "country", source = "profile.country")
    @Mapping(target = "dateOfBirth", source = "profile.dateOfBirth")
    @Mapping(target = "gender", source = "profile.gender")
    @Mapping(target = "age", source = "profile.age")
    @Mapping(target = "genres", source = "profile.genres")
    UserResponse toUserResponse(User user);

    @Named("mapRoles")
    default Set<String> mapRoles(Set<Role> roles) {
        if (roles == null)
            return null;
        return roles.stream()
                .map(Role::getName)
                .collect(Collectors.toSet());
    }

    @Named("mapPermissions")
    default Set<String> mapPermissions(Set<Role> roles) {
        if (roles == null)
            return null;
        return roles.stream()
                .flatMap(role -> role.getPermissions().stream())
                .map(Permission::getName)
                .collect(Collectors.toSet());
    }

    @Named("mapPhone")
    default String mapPhone(User user) {
        return user.getPhoneNumber();
    }
}
