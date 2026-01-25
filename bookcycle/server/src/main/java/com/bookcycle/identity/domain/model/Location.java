package com.bookcycle.identity.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.util.Objects;

/**
 * Value Object: Location
 * 
 * User's location (city/region). Optional.
 * Immutable and self-validating.
 */
@Embeddable
public class Location {
    @Column(name = "location_value", length = 100)
    private String value;

    protected Location() {
        // For JPA
    }

    private Location(String value) {
        this.value = Objects.requireNonNull(value, "Location cannot be null").trim();
        validateLocation(this.value);
    }

    public static Location of(String location) {
        return new Location(location);
    }

    private static void validateLocation(String location) {
        if (location.isEmpty()) {
            throw new IllegalArgumentException("Location cannot be empty");
        }
        if (location.length() > 100) {
            throw new IllegalArgumentException("Location cannot exceed 100 characters");
        }
    }

    public String getValue() {
        return value;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Location)) return false;
        Location location = (Location) o;
        return Objects.equals(value, location.value);
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
