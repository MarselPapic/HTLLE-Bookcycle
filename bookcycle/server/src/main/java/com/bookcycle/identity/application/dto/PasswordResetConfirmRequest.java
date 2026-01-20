package com.bookcycle.identity.application.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO: PasswordResetConfirmRequest
 * 
 * Request object for confirming password reset.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PasswordResetConfirmRequest {
    private String token;
    @JsonProperty("newPassword")
    private String newPassword;
}
