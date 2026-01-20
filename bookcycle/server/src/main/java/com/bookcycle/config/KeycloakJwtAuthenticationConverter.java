package com.bookcycle.config;

import org.springframework.core.convert.converter.Converter;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * JWT Authentication Converter for Keycloak
 * 
 * Extracts roles from Keycloak JWT claims and converts them to Spring Security authorities.
 * 
 * JWT structure (from Keycloak):
 * {
 *   "sub": "uuid",
 *   "email": "user@example.com",
 *   "roles": ["MEMBER", "MODERATOR"]
 * }
 */
@Component
public class KeycloakJwtAuthenticationConverter implements Converter<Jwt, AbstractAuthenticationToken> {

    @Override
    public AbstractAuthenticationToken convert(Jwt jwt) {
        Collection<GrantedAuthority> authorities = extractAuthorities(jwt);
        return new JwtAuthenticationToken(jwt, authorities);
    }

    /**
     * Extract roles from JWT and convert to Spring Security authorities
     */
    private Collection<GrantedAuthority> extractAuthorities(Jwt jwt) {
        Object roles = jwt.getClaims().get("roles");

        if (roles instanceof Collection<?>) {
            return ((Collection<?>) roles).stream()
                .filter(role -> role instanceof String)
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
                .collect(Collectors.toSet());
        }

        return Collections.emptySet();
    }
}
