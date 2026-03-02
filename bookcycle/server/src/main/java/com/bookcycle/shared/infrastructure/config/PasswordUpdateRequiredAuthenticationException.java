package com.bookcycle.shared.infrastructure.config;

import org.springframework.security.core.AuthenticationException;

public class PasswordUpdateRequiredAuthenticationException extends AuthenticationException {
    private final String email;

    public PasswordUpdateRequiredAuthenticationException(String email) {
        super("Password update required for first login");
        this.email = email;
    }

    public String getEmail() {
        return email;
    }
}
