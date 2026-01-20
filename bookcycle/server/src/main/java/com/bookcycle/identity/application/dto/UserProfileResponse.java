package com.bookcycle.identity.application.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

/**
 * DTO: UserProfileResponse
 * 
 * Response object containing user profile information.
 * Includes profile data + roles from JWT.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfileResponse {
    private UUID id;
    private String email;
    @JsonProperty("displayName")
    private String displayName;
    private String location;
    @JsonProperty("avatarUrl")
    private String avatarUrl;
    private Set<String> roles;
    private boolean active;
    @JsonProperty("createdAt")
    private LocalDateTime createdAt;
    @JsonProperty("updatedAt")
    private LocalDateTime updatedAt;
}
