package com.bookcycle.shared.infrastructure.config;

import com.bookcycle.identity.infrastructure.keycloak.KeycloakAdminClient;
import com.bookcycle.identity.infrastructure.keycloak.PasswordUpdateRequiredException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import java.util.Set;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class KeycloakAdminAuthenticationProvider implements AuthenticationProvider {
    private final KeycloakAdminClient keycloakAdminClient;

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String email = authentication.getName();
        String password = authentication.getCredentials() != null
            ? authentication.getCredentials().toString()
            : "";

        try {
            Set<String> roles = keycloakAdminClient.authenticateWebAdmin(email, password);

            Set<SimpleGrantedAuthority> authorities = roles.stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
                .collect(Collectors.toSet());

            return new UsernamePasswordAuthenticationToken(email, null, authorities);
        } catch (PasswordUpdateRequiredException ex) {
            throw new PasswordUpdateRequiredAuthenticationException(ex.getEmail());
        } catch (IllegalArgumentException ex) {
            throw new BadCredentialsException(ex.getMessage());
        }
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication);
    }
}
