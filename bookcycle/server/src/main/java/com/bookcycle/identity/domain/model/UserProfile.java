package com.bookcycle.identity.domain.model;

import jakarta.persistence.AttributeOverride;
import jakarta.persistence.Column;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
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
@Entity
@Table(schema = "identity", name = "user_profiles")
public class UserProfile {
    @Id
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "user_id")
    private UserAccount userAccount;

    @Embedded
    @AttributeOverride(name = "value", column = @Column(name = "display_name", length = 100, nullable = false))
    private DisplayName displayName;

    @Embedded
    @AttributeOverride(name = "value", column = @Column(name = "location", length = 100))
    private Location location;

    @Embedded
    @AttributeOverride(name = "value", column = @Column(name = "avatar_url", length = 500))
    private AvatarUrl avatarUrl;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
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

    void attachUserAccount(UserAccount userAccount) {
        this.userAccount = Objects.requireNonNull(userAccount, "userAccount cannot be null");
        this.userId = userAccount.getId();
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
