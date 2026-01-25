package com.bookcycle.identity.application.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.*;
import org.hibernate.validator.constraints.URL;

/**
 * DTO: UpdateUserProfileRequest
 * 
 * Request object for updating user profile.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateUserProfileRequest {
    
    @NotBlank(message = "Display name is required")
    @Size(min = 2, max = 100, message = "Display name must be between 2 and 100 characters")
    @JsonProperty("displayName")
    private String displayName;

    @Size(max = 100, message = "Location cannot exceed 100 characters")
    private String location;

    @Size(max = 500, message = "Avatar URL cannot exceed 500 characters")
    @URL(message = "Avatar URL must be a valid URL")
    @JsonProperty("avatarUrl")
    private String avatarUrl;
}
