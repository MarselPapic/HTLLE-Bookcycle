package com.bookcycle.shared.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.util.Objects;

/**
 * Value Object: Isbn
 */
@Embeddable
public class Isbn {
    @Column(name = "isbn", length = 20, nullable = false)
    private String value;

    protected Isbn() {
        // JPA
    }

    private Isbn(String value) {
        this.value = Objects.requireNonNull(value, "isbn cannot be null").trim();
        validate(this.value);
    }

    public static Isbn of(String value) {
        return new Isbn(value);
    }

    private static void validate(String value) {
        if (value.isEmpty()) {
            throw new IllegalArgumentException("isbn cannot be empty");
        }
        if (value.length() > 20) {
            throw new IllegalArgumentException("isbn too long");
        }
    }

    public String getValue() {
        return value;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Isbn)) return false;
        Isbn isbn = (Isbn) o;
        return Objects.equals(value, isbn.value);
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
