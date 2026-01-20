package com.bookcycle.identity.domain.model;

import java.util.Objects;

/**
 * Value Object: DisplayName
 * 
 * Represents the user's public display name.
 * Immutable and self-validating.
 */
public final class DisplayName {
    private final String value;

    private DisplayName(String value) {
        this.value = Objects.requireNonNull(value, "DisplayName cannot be null");
        validateDisplayName(value);
    }

    public static DisplayName of(String name) {
        return new DisplayName(name);
    }

    private static void validateDisplayName(String name) {
        String trimmed = name.trim();
        if (trimmed.isEmpty()) {
            throw new IllegalArgumentException("DisplayName cannot be empty");
        }
        if (trimmed.length() < 2) {
            throw new IllegalArgumentException("DisplayName must be at least 2 characters");
        }
        if (trimmed.length() > 100) {
            throw new IllegalArgumentException("DisplayName cannot exceed 100 characters");
        }
    }

    public String getValue() {
        return value;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof DisplayName)) return false;
        DisplayName that = (DisplayName) o;
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
