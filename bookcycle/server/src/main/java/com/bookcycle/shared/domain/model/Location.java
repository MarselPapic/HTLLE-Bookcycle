package com.bookcycle.shared.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.util.Objects;

/**
 * Value Object: Location (city + zip)
 */
@Embeddable
public class Location {
    @Column(name = "city", length = 100, nullable = false)
    private String city;

    @Column(name = "zip_code", length = 20, nullable = false)
    private String zipCode;

    protected Location() {
        // JPA
    }

    private Location(String city, String zipCode) {
        this.city = Objects.requireNonNull(city, "city cannot be null").trim();
        this.zipCode = Objects.requireNonNull(zipCode, "zipCode cannot be null").trim();
        validate(this.city, this.zipCode);
    }

    public static Location of(String city, String zipCode) {
        return new Location(city, zipCode);
    }

    private static void validate(String city, String zipCode) {
        if (city.isEmpty()) {
            throw new IllegalArgumentException("city cannot be empty");
        }
        if (zipCode.isEmpty()) {
            throw new IllegalArgumentException("zip code cannot be empty");
        }
    }

    public String getCity() {
        return city;
    }

    public String getZipCode() {
        return zipCode;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Location)) return false;
        Location location = (Location) o;
        return Objects.equals(city, location.city) && Objects.equals(zipCode, location.zipCode);
    }

    @Override
    public int hashCode() {
        return Objects.hash(city, zipCode);
    }

    @Override
    public String toString() {
        return city + " " + zipCode;
    }
}
