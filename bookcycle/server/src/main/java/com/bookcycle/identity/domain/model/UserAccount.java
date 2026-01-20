package com.bookcycle.identity.domain.model;

import java.time.LocalDateTime;
import java.util.*;

/**
 * Aggregate Root: UserAccount
 * 
 * Central aggregate in the Identity & Access Bounded Context.
 * 
 * Responsibilities:
 * - Manage user's core identity (Keycloak ID, email)
 * - Manage user's roles (MEMBER, MODERATOR, ADMIN)
 * - Manage user's profile data (via contained UserProfile entity)
 * 
 * Single Source of Truth:
 * - Keycloak: email, password, rôles (canonical)
 * - Backend: profile data (displayName, location, avatarUrl)
 * - User-ID: Keycloak UUID from JWT
 */
public class UserAccount {
    private UUID id;
    private Email email;
    private UserProfile profile;
    private Set<UserRole> roles;
    private boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * JPA Constructor (no-args required for Hibernate)
     */
    protected UserAccount() {
        this.roles = new HashSet<>();
    }

    /**
     * Domain Constructor
     * Invoked when user registers or first authenticates via Keycloak.
     */
    private UserAccount(UUID id, Email email, UserProfile profile, Set<UserRole> roles) {
        this.id = Objects.requireNonNull(id, "id cannot be null");
        this.email = Objects.requireNonNull(email, "email cannot be null");
        this.profile = Objects.requireNonNull(profile, "profile cannot be null");
        this.roles = Objects.requireNonNull(roles, "roles cannot be null");
        this.active = true;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * Factory method to create a new UserAccount (from Keycloak registration)
     */
    public static UserAccount create(UUID keycloakId, Email email, DisplayName displayName) {
        UserProfile profile = UserProfile.create(keycloakId, displayName);
        Set<UserRole> roles = new HashSet<>();
        roles.add(UserRole.MEMBER); // Default role for new users
        return new UserAccount(keycloakId, email, profile, roles);
    }

    /**
     * Factory method to synchronize from Keycloak JWT
     * (Called when user exists in Keycloak but not yet in backend)
     */
    public static UserAccount fromKeycloakToken(UUID keycloakId, Email email, 
                                                 DisplayName displayName, Set<UserRole> roles) {
        UserProfile profile = UserProfile.create(keycloakId, displayName);
        Set<UserRole> validRoles = Objects.requireNonNull(roles, "roles cannot be null");
        if (validRoles.isEmpty()) {
            validRoles = new HashSet<>();
            validRoles.add(UserRole.MEMBER);
        }
        return new UserAccount(keycloakId, email, profile, validRoles);
    }

    // Business Logic

    public void updateProfile(DisplayName displayName, Location location, AvatarUrl avatarUrl) {
        profile.updateDisplayName(displayName);
        if (location != null) {
            profile.updateLocation(location);
        }
        if (avatarUrl != null) {
            profile.updateAvatarUrl(avatarUrl);
        }
        this.updatedAt = LocalDateTime.now();
    }

    public void synchronizeRoles(Set<UserRole> newRoles) {
        this.roles = Objects.requireNonNull(newRoles, "roles cannot be null");
        if (this.roles.isEmpty()) {
            this.roles.add(UserRole.MEMBER);
        }
        this.updatedAt = LocalDateTime.now();
    }

    public void deactivate() {
        this.active = false;
        this.updatedAt = LocalDateTime.now();
    }

    public void activate() {
        this.active = true;
        this.updatedAt = LocalDateTime.now();
    }

    public boolean hasRole(UserRole role) {
        return roles.contains(role);
    }

    public boolean isAdmin() {
        return hasRole(UserRole.ADMIN);
    }

    public boolean isModerator() {
        return hasRole(UserRole.MODERATOR);
    }

    // Getters
    public UUID getId() {
        return id;
    }

    public Email getEmail() {
        return email;
    }

    public UserProfile getProfile() {
        return profile;
    }

    public Set<UserRole> getRoles() {
        return Collections.unmodifiableSet(roles);
    }

    public boolean isActive() {
        return active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof UserAccount)) return false;
        UserAccount that = (UserAccount) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "UserAccount{" +
                "id=" + id +
                ", email=" + email +
                ", displayName=" + profile.getDisplayName() +
                ", roles=" + roles +
                ", active=" + active +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
