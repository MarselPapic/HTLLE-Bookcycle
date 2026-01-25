package com.bookcycle.identity.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.util.Objects;

/**
 * Value Object: Email
 * 
 * Single Responsibility: Email validation and representation.
 * Immutable, self-validating.
 */
@Embeddable
public class Email {
    @Column(name = "email_value", length = 254)
    private String value;

    protected Email() {
        // For JPA
    }

    private Email(String value) {
        this.value = Objects.requireNonNull(value, "Email cannot be null");
        validateEmail(value);
    }

    public static Email of(String email) {
        return new Email(email);
    }

    private static void validateEmail(String email) {
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            throw new IllegalArgumentException("Invalid email format: " + email);
        }
        if (email.length() > 254) {
            throw new IllegalArgumentException("Email too long (max 254 characters)");
        }
    }

    public String getValue() {
        return value;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Email)) return false;
        Email email = (Email) o;
        return Objects.equals(value, email.value);
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
