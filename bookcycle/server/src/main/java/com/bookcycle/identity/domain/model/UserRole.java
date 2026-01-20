package com.bookcycle.identity.domain.model;

/**
 * Enum: UserRole
 * 
 * Bounded Context: Identity & Access
 * 
 * Roles are:
 * - Defined in Keycloak realm
 * - Included in JWT token
 * - Synchronized to backend for authorization
 */
public enum UserRole {
    MEMBER("Member", "Basic user with trading capabilities"),
    MODERATOR("Moderator", "User with moderation privileges"),
    ADMIN("Administrator", "Full system access");

    private final String displayName;
    private final String description;

    UserRole(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getDescription() {
        return description;
    }

    /**
     * Safe lookup by name (case-insensitive)
     */
    public static UserRole fromString(String role) {
        if (role == null || role.isEmpty()) {
            return MEMBER; // Default
        }
        try {
            return UserRole.valueOf(role.toUpperCase());
        } catch (IllegalArgumentException e) {
            return MEMBER;
        }
    }
}
