package com.bookcycle.identity.presentation.rest;

import com.bookcycle.identity.application.service.IdentityApplicationService;
import com.bookcycle.identity.application.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.UUID;

/**
 * REST Controller: AuthenticationController
 * 
 * Handles authentication endpoints:
 * - POST /auth/register – User registration
 * - POST /auth/login – Login flow information
 * - POST /auth/logout – Logout
 * - POST /auth/password-reset – Request password reset
 * - POST /auth/password-reset/confirm – Confirm password reset
 * 
 * Bounded Context: Identity & Access
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthenticationController {
    private final IdentityApplicationService identityService;

    /**
     * Register a new user
     * POST /auth/register
     */
    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> register(@Valid @RequestBody RegisterRequest request) {
        RegisterResponse response = identityService.registerUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Login endpoint (informational)
     * In real implementation, redirects to Keycloak
     * POST /auth/login
     */
    @PostMapping("/login")
    public ResponseEntity<LoginInfoResponse> login() {
        LoginInfoResponse response = LoginInfoResponse.builder()
            .keycloakUrl("http://localhost:8180/realms/bookcycle-mobile/protocol/openid-connect/auth")
            .message("Redirect to Keycloak (mobile realm) for authentication")
            .build();
        return ResponseEntity.ok(response);
    }

    /**
     * Logout endpoint
     * Revokes token and clears session
     * POST /auth/logout
     */
    @PostMapping("/logout")
    public ResponseEntity<LogoutResponse> logout(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(LogoutResponse.builder().message("Not authenticated").build());
        }

        // In real implementation, would revoke refresh token in Keycloak
        LogoutResponse response = LogoutResponse.builder()
            .message("Logged out successfully")
            .build();
        return ResponseEntity.ok(response);
    }

    /**
     * Request password reset
     * Sends email with reset link (valid 15 minutes)
     * POST /auth/password-reset
     */
    @PostMapping("/password-reset")
    public ResponseEntity<MessageResponse> requestPasswordReset(
            @Valid @RequestBody PasswordResetRequest request) {
        // In real implementation, would:
        // 1. Check if email exists in Keycloak
        // 2. Generate reset token
        // 3. Send email via Keycloak/MailPit
        
        MessageResponse response = MessageResponse.builder()
            .message("If email exists, password reset link has been sent")
            .build();
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(response);
    }

    /**
     * Confirm password reset with token
     * POST /auth/password-reset/confirm
     */
    @PostMapping("/password-reset/confirm")
    public ResponseEntity<MessageResponse> confirmPasswordReset(
            @Valid @RequestBody PasswordResetConfirmRequest request) {
        // In real implementation, would:
        // 1. Validate reset token (check expiration - 15 minutes)
        // 2. Update password in Keycloak
        // 3. Invalidate token
        
        MessageResponse response = MessageResponse.builder()
            .message("Password reset successfully")
            .build();
        return ResponseEntity.ok(response);
    }
}

// Supporting DTOs for response bodies
@lombok.Data
@lombok.NoArgsConstructor
@lombok.AllArgsConstructor
@lombok.Builder
class LoginInfoResponse {
    private String keycloakUrl;
    private String message;
}

@lombok.Data
@lombok.NoArgsConstructor
@lombok.AllArgsConstructor
@lombok.Builder
class LogoutResponse {
    private String message;
}

@lombok.Data
@lombok.NoArgsConstructor
@lombok.AllArgsConstructor
@lombok.Builder
class MessageResponse {
    private String message;
}

@lombok.Data
@lombok.NoArgsConstructor
@lombok.AllArgsConstructor
@lombok.Builder
class PasswordResetRequest {
    @jakarta.validation.constraints.NotBlank
    @jakarta.validation.constraints.Email
    private String email;
}
