package com.bookcycle.identity.infrastructure.keycloak;

public class PasswordUpdateRequiredException extends RuntimeException {
    private final String email;

    public PasswordUpdateRequiredException(String email) {
        super("Password update required");
        this.email = email;
    }

    public String getEmail() {
        return email;
    }
}
