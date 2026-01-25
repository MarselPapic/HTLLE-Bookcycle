package com.bookcycle.shared.infrastructure.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationProvider;
import org.springframework.security.oauth2.server.resource.authentication.JwtIssuerAuthenticationManagerResolver;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.authentication.AuthenticationManagerResolver;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import jakarta.servlet.http.HttpServletRequest;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Security Configuration
 * 
 * Configures:
 * - JWT Bearer authentication (OAuth2 Resource Server)
 * - CORS for web/mobile clients
 * - HTTP security policy
 * - Token validation with Keycloak
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    /**
     * Configure HTTP security
     * - Stateless (JWT)
     * - CORS enabled
     * - OAuth2 resource server with JWT bearer tokens
     */
    @Bean
    public SecurityFilterChain filterChain(
            HttpSecurity http,
            AuthenticationManagerResolver<HttpServletRequest> authenticationManagerResolver) throws Exception {
        http
            .csrf().disable()
            .cors().and()
            .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeHttpRequests(authz -> authz
                // Public endpoints
                .requestMatchers("/api/v1/auth/register").permitAll()
                .requestMatchers("/api/v1/auth/login").permitAll()
                .requestMatchers("/api/v1/auth/password-reset").permitAll()
                .requestMatchers("/api/v1/auth/password-reset/confirm").permitAll()
                .requestMatchers("/api/health").permitAll()
                .requestMatchers("/admin/**").permitAll()
                .requestMatchers("/health").permitAll()
                .requestMatchers("/health/live").permitAll()
                .requestMatchers("/health/ready").permitAll()
                .requestMatchers("/swagger-ui.html").permitAll()
                .requestMatchers("/v3/api-docs").permitAll()
                .requestMatchers("/v3/api-docs/**").permitAll()
                // All other requests require authentication
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .authenticationManagerResolver(authenticationManagerResolver)
            );

        return http.build();
    }

    /**
     * CORS configuration
     * Allows requests from web and mobile clients
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",
            "http://localhost:8080",
            "http://localhost:19000"
        ));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    /**
     * Resolve JWT issuers for multiple Keycloak realms.
     */
    @Bean
    public AuthenticationManagerResolver<HttpServletRequest> authenticationManagerResolver(
            @Value("${app.keycloak.issuers}") List<String> issuers,
            @Value("${app.keycloak.internal-issuer-base:http://localhost:8180}") String internalIssuerBase,
            KeycloakJwtAuthenticationConverter converter) {
        Map<String, AuthenticationManager> managers = new HashMap<>();
        for (String issuer : issuers) {
            String jwkSetUri = issuer;
            if (issuer.startsWith("http://localhost:8180")) {
                jwkSetUri = issuer.replace("http://localhost:8180", internalIssuerBase);
            } else if (issuer.startsWith("http://127.0.0.1:8180")) {
                jwkSetUri = issuer.replace("http://127.0.0.1:8180", internalIssuerBase);
            }
            jwkSetUri = jwkSetUri + "/protocol/openid-connect/certs";

            NimbusJwtDecoder decoder = NimbusJwtDecoder.withJwkSetUri(jwkSetUri).build();
            decoder.setJwtValidator(JwtValidators.createDefaultWithIssuer(issuer));

            JwtAuthenticationProvider provider = new JwtAuthenticationProvider(decoder);
            provider.setJwtAuthenticationConverter(converter);
            managers.put(issuer, new ProviderManager(provider));
        }
        return new JwtIssuerAuthenticationManagerResolver(managers::get);
    }
}

