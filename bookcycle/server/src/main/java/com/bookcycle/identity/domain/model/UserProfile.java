package com.bookcycle.identity.domain.model;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

/**
 * Entity: UserProfile
 * 
 * Represents user's profile information.
 * Owned by UserAccount aggregate.
 * Persisted to PostgreSQL via JPA.
 */
public class UserProfile {
    private UUID userId;
    private DisplayName displayName;
    private Location location;
    private AvatarUrl avatarUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * JPA Constructor (no-args required for Hibernate)
     */
    protected UserProfile() {
    }

    /**
     * Domain Constructor
     */
    public UserProfile(UUID userId, DisplayName displayName) {
        this.userId = Objects.requireNonNull(userId, "userId cannot be null");
        this.displayName = Objects.requireNonNull(displayName, "displayName cannot be null");
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public static UserProfile create(UUID userId, DisplayName displayName) {
        return new UserProfile(userId, displayName);
    }

    public void updateDisplayName(DisplayName displayName) {
        this.displayName = Objects.requireNonNull(displayName, "displayName cannot be null");
        this.updatedAt = LocalDateTime.now();
    }

    public void updateLocation(Location location) {
        this.location = location;
        this.updatedAt = LocalDateTime.now();
    }

    public void updateAvatarUrl(AvatarUrl avatarUrl) {
        this.avatarUrl = avatarUrl;
        this.updatedAt = LocalDateTime.now();
    }

    // Getters
    public UUID getUserId() {
        return userId;
    }

    public DisplayName getDisplayName() {
        return displayName;
    }

    public Location getLocation() {
        return location;
    }

    public AvatarUrl getAvatarUrl() {
        return avatarUrl;
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
        if (!(o instanceof UserProfile)) return false;
        UserProfile that = (UserProfile) o;
        return Objects.equals(userId, that.userId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId);
    }

    @Override
    public String toString() {
        return "UserProfile{" +
                "userId=" + userId +
                ", displayName=" + displayName +
                ", location=" + location +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
