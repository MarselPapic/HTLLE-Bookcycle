package com.bookcycle.identity.presentation.rest;

import com.bookcycle.identity.application.service.IdentityApplicationService;
import com.bookcycle.identity.application.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.UUID;

/**
 * REST Controller: UserController
 * 
 * Handles user profile endpoints:
 * - GET /users/me – Get current user profile
 * - PUT /users/me – Update current user profile
 * 
 * Bounded Context: Identity & Access
 * Requires: JWT Bearer token authentication
 */
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {
    private final IdentityApplicationService identityService;

    /**
     * Get current user's profile
     * GET /users/me
     * 
     * Requires: Valid JWT Bearer token from Keycloak
     * Returns: User profile with roles, email, display name, etc.
     */
    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }

        // Extract user ID from JWT (sub claim)
        // In real implementation, this would come from authentication principal
        String userId = authentication.getName();
        UUID userUUID = UUID.fromString(userId);

        UserProfileResponse profile = identityService.getCurrentUser(userUUID);
        return ResponseEntity.ok(profile);
    }

    /**
     * Update current user's profile
     * PUT /users/me
     * 
     * Updatable fields:
     * - displayName (required)
     * - location (optional)
     * - avatarUrl (optional)
     * 
     * Non-updatable:
     * - email (managed by Keycloak)
     * - roles (managed by Keycloak admins)
     */
    @PutMapping("/me")
    public ResponseEntity<UserProfileResponse> updateProfile(
            Authentication authentication,
            @Valid @RequestBody UpdateUserProfileRequest request) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }

        String userId = authentication.getName();
        UUID userUUID = UUID.fromString(userId);

        UserProfileResponse profile = identityService.updateProfile(userUUID, request);
        return ResponseEntity.ok(profile);
    }
}
