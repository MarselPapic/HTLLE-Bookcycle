package com.bookcycle.identity.application.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * DTO: RegisterResponse
 * 
 * Response object for registration.
 * Contains user ID and confirmation message.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RegisterResponse {
    private UUID id;
    private String email;
    @JsonProperty("displayName")
    private String displayName;
    private String message;
}
