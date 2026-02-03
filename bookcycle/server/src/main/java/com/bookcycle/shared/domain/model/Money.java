package com.bookcycle.shared.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.math.BigDecimal;
import java.util.Objects;

/**
 * Value Object: Money
 */
@Embeddable
public class Money {
    @Column(name = "amount", precision = 12, scale = 2, nullable = false)
    private BigDecimal amount;

    @Column(name = "currency", length = 3, nullable = false)
    private String currency;

    protected Money() {
        // JPA
    }

    private Money(BigDecimal amount, String currency) {
        this.amount = Objects.requireNonNull(amount, "amount cannot be null");
        this.currency = Objects.requireNonNull(currency, "currency cannot be null").trim().toUpperCase();
        validate(this.amount, this.currency);
    }

    public static Money of(BigDecimal amount, String currency) {
        return new Money(amount, currency);
    }

    private static void validate(BigDecimal amount, String currency) {
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("amount cannot be negative");
        }
        if (currency.length() != 3) {
            throw new IllegalArgumentException("currency must be ISO 4217 3-letter code");
        }
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public String getCurrency() {
        return currency;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Money)) return false;
        Money money = (Money) o;
        return Objects.equals(amount, money.amount) && Objects.equals(currency, money.currency);
    }

    @Override
    public int hashCode() {
        return Objects.hash(amount, currency);
    }

    @Override
    public String toString() {
        return amount + " " + currency;
    }
}
