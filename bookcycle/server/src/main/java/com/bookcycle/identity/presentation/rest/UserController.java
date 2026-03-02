package com.bookcycle.identity.presentation.rest;

import com.bookcycle.identity.application.service.IdentityApplicationService;
import com.bookcycle.identity.application.dto.*;
import com.bookcycle.identity.domain.model.UserRole;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
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
/**
 * User Story: US-005 User Management
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

        UUID userUUID = UUID.fromString(authentication.getName());
        ensureUserSynchronized(authentication, userUUID);

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

        UUID userUUID = UUID.fromString(authentication.getName());
        ensureUserSynchronized(authentication, userUUID);

        UserProfileResponse profile = identityService.updateProfile(userUUID, request);
        return ResponseEntity.ok(profile);
    }

    private void ensureUserSynchronized(Authentication authentication, UUID userId) {
        try {
            identityService.getCurrentUser(userId);
            return;
        } catch (IllegalArgumentException ignored) {
            // User is missing in backend and needs first-login sync from JWT.
        }

        if (!(authentication instanceof JwtAuthenticationToken jwtAuthenticationToken)) {
            throw new IllegalArgumentException("JWT authentication is required for user synchronization.");
        }

        Jwt jwt = jwtAuthenticationToken.getToken();
        String email = jwt.getClaimAsString("email");
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Authenticated token does not contain an email claim.");
        }

        String displayName = resolveDisplayName(jwt, email);
        Set<UserRole> roles = extractRoles(jwt);

        identityService.synchronizeUserFromKeycloak(userId, email, displayName, roles);
    }

    private String resolveDisplayName(Jwt jwt, String email) {
        String fullName = jwt.getClaimAsString("name");
        if (fullName != null && !fullName.isBlank()) {
            return fullName.trim();
        }

        String givenName = jwt.getClaimAsString("given_name");
        String familyName = jwt.getClaimAsString("family_name");
        String combined = (Objects.toString(givenName, "") + " " + Objects.toString(familyName, "")).trim();
        if (!combined.isBlank()) {
            return combined;
        }

        String preferredUsername = jwt.getClaimAsString("preferred_username");
        if (preferredUsername != null && !preferredUsername.isBlank()) {
            return preferredUsername.trim();
        }

        int atIndex = email.indexOf('@');
        return atIndex > 0 ? email.substring(0, atIndex) : email;
    }

    private Set<UserRole> extractRoles(Jwt jwt) {
        Set<UserRole> roles = new HashSet<>();

        Object rolesClaim = jwt.getClaims().get("roles");
        if (rolesClaim instanceof Iterable<?> roleItems) {
            for (Object role : roleItems) {
                addKnownRole(role, roles);
            }
        }

        Object realmAccessClaim = jwt.getClaims().get("realm_access");
        if (realmAccessClaim instanceof Map<?, ?> realmAccess) {
            Object realmRoles = realmAccess.get("roles");
            if (realmRoles instanceof Iterable<?> roleItems) {
                for (Object role : roleItems) {
                    addKnownRole(role, roles);
                }
            }
        }

        if (roles.isEmpty()) {
            roles.add(UserRole.MEMBER);
        }

        return roles;
    }

    private void addKnownRole(Object roleObject, Set<UserRole> roles) {
        if (!(roleObject instanceof String roleName) || roleName.isBlank()) {
            return;
        }

        String normalized = roleName.trim().toUpperCase();
        switch (normalized) {
            case "MEMBER" -> roles.add(UserRole.MEMBER);
            case "MODERATOR" -> roles.add(UserRole.MODERATOR);
            case "ADMIN" -> roles.add(UserRole.ADMIN);
            default -> {
                // Ignore Keycloak internal/default roles.
            }
        }
    }
}
