package com.bookcycle.identity.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.util.Objects;

/**
 * Value Object: AvatarUrl
 * 
 * User's avatar/profile picture URL. Optional.
 * Immutable and self-validating.
 */
@Embeddable
public class AvatarUrl {
    @Column(name = "avatar_url_value", length = 500)
    private String value;

    protected AvatarUrl() {
        // For JPA
    }

    private AvatarUrl(String value) {
        this.value = Objects.requireNonNull(value, "AvatarUrl cannot be null").trim();
        validateUrl(this.value);
    }

    public static AvatarUrl of(String url) {
        return new AvatarUrl(url);
    }

    private static void validateUrl(String url) {
        if (url.isEmpty()) {
            throw new IllegalArgumentException("AvatarUrl cannot be empty");
        }
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
            throw new IllegalArgumentException("AvatarUrl must be a valid HTTP/HTTPS URL");
        }
        if (url.length() > 500) {
            throw new IllegalArgumentException("AvatarUrl cannot exceed 500 characters");
        }
    }

    public String getValue() {
        return value;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof AvatarUrl)) return false;
        AvatarUrl that = (AvatarUrl) o;
        return Objects.equals(value, that.value);
    }

    @Override
    public int hashCode() {
        return Objects.hash(value);
    }

    @Override
    public String toString() {
        return value;
    }
}
