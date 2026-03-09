package com.bookcycle.identity.application.service;

import com.bookcycle.identity.domain.model.*;
import com.bookcycle.identity.domain.service.UserAccountService;
import com.bookcycle.identity.application.dto.*;
import com.bookcycle.identity.infrastructure.keycloak.KeycloakAdminClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;
import java.util.UUID;

/**
 * Application Service: IdentityApplicationService
 * 
 * Coordinates use cases between domain and presentation layers.
 * Handles:
 * - Registration
 * - Profile synchronization
 * - Profile updates
 */
@Service
@RequiredArgsConstructor
public class IdentityApplicationService {
    private final UserAccountService accountService;
    private final KeycloakAdminClient keycloakAdminClient;

    /**
     * Register a new user
     * 1. Creates user in Keycloak (via external call - not shown here)
     * 2. Creates backend profile
     * 3. Returns user ID for confirmation
     */
    @Transactional
    public RegisterResponse registerUser(RegisterRequest request) {
        UUID keycloakUserId = keycloakAdminClient.createMobileUser(
            request.getEmail(),
            request.getDisplayName(),
            request.getPassword()
        );
        
        UserAccount account = accountService.createUserAccount(
            keycloakUserId,
            request.getEmail(),
            request.getDisplayName()
        );

        return RegisterResponse.builder()
            .id(account.getId())
            .email(account.getEmail().getValue())
            .displayName(account.getProfile().getDisplayName().getValue())
            .message("User registered successfully. Check your email for verification.")
            .build();
    }

    @Transactional(readOnly = true)
    public void requestPasswordReset(String email) {
        keycloakAdminClient.sendMobilePasswordResetEmail(email);
    }

    @Transactional(readOnly = true)
    public void requestWebAdminPasswordReset(String email) {
        keycloakAdminClient.sendWebAdminPasswordResetEmail(email);
    }

    @Transactional
    public UUID createWebAdminUserWithTemporaryPassword(
            String email,
            String displayName,
            String temporaryPassword,
            Set<String> roles) {
        return keycloakAdminClient.createWebAdminUserWithTemporaryPassword(
            email,
            displayName,
            temporaryPassword,
            roles
        );
    }

    @Transactional
    public void completeWebAdminPasswordChange(
            String email,
            String currentPassword,
            String newPassword) {
        keycloakAdminClient.completeWebAdminPasswordChange(email, currentPassword, newPassword);
    }

    /**
     * Synchronize user from Keycloak JWT claims
     * Called when user authenticates
     */
    @Transactional
    public UserProfileResponse synchronizeUserFromKeycloak(UUID keycloakId, String email, 
                                                          String displayName, Set<UserRole> roles) {
        UserAccount account = accountService.synchronizeFromKeycloak(
            keycloakId,
            email,
            displayName,
            roles
        );

        return toResponse(account, roles);
    }

    /**
     * Get current user profile
     */
    @Transactional(readOnly = true)
    public UserProfileResponse getCurrentUser(UUID userId) {
        UserAccount account = accountService.getUserAccount(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        // Roles would come from JWT in real implementation
        return toResponse(account, account.getRoles());
    }

    /**
     * Update user profile
     */
    @Transactional
    public UserProfileResponse updateProfile(UUID userId, UpdateUserProfileRequest request) {
        Location location = request.getLocation() != null && !request.getLocation().isEmpty() 
            ? Location.of(request.getLocation()) 
            : null;

        AvatarUrl avatarUrl = request.getAvatarUrl() != null && !request.getAvatarUrl().isEmpty()
            ? AvatarUrl.of(request.getAvatarUrl())
            : null;

        UserAccount account = accountService.updateProfile(
            userId,
            DisplayName.of(request.getDisplayName()),
            location,
            avatarUrl
        );

        return toResponse(account, account.getRoles());
    }

    // Helper method
    private UserProfileResponse toResponse(UserAccount account, Set<UserRole> roles) {
        UserProfile profile = account.getProfile();
        
        return UserProfileResponse.builder()
            .id(account.getId())
            .email(account.getEmail().getValue())
            .displayName(profile.getDisplayName().getValue())
            .location(profile.getLocation() != null ? profile.getLocation().getValue() : null)
            .avatarUrl(profile.getAvatarUrl() != null ? profile.getAvatarUrl().getValue() : null)
            .roles(roles.stream().map(Enum::name).collect(java.util.stream.Collectors.toSet()))
            .active(account.isActive())
            .createdAt(account.getCreatedAt())
            .updatedAt(account.getUpdatedAt())
            .build();
    }
}
