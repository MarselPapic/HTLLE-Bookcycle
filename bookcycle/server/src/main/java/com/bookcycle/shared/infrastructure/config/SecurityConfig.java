package com.bookcycle.shared.infrastructure.config;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationManagerResolver;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationProvider;
import org.springframework.security.oauth2.server.resource.authentication.JwtIssuerAuthenticationManagerResolver;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.util.UriUtils;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Security Configuration
 *
 * - API: JWT resource server (stateless)
 * - Admin Webapp: OAuth2 login with Keycloak (session)
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    @Order(1)
    public SecurityFilterChain apiFilterChain(
            HttpSecurity http,
            AuthenticationManagerResolver<HttpServletRequest> authenticationManagerResolver) throws Exception {
        http
            .securityMatcher("/api/**", "/health/**", "/actuator/**", "/swagger-ui.html", "/swagger-ui/**", "/v3/api-docs/**")
            .csrf(csrf -> csrf.disable())
            .cors(Customizer.withDefaults())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/v1/auth/register").permitAll()
                .requestMatchers("/api/v1/auth/login").permitAll()
                .requestMatchers("/api/v1/auth/password-reset").permitAll()
                .requestMatchers("/api/v1/auth/password-reset/confirm").permitAll()
                .requestMatchers("/api/v1/listings/**").permitAll()
                .requestMatchers("/api/v1/purchases/**").permitAll()
                .requestMatchers("/api/v1/conversations/**").permitAll()
                .requestMatchers("/api/v1/reports/**").permitAll()
                .requestMatchers("/api/v1/moderation/**").permitAll()
                .requestMatchers("/api/health").permitAll()
                .requestMatchers("/actuator/health").permitAll()
                .requestMatchers("/error").permitAll()
                .requestMatchers("/health").permitAll()
                .requestMatchers("/health/live").permitAll()
                .requestMatchers("/health/ready").permitAll()
                .requestMatchers("/swagger-ui.html").permitAll()
                .requestMatchers("/v3/api-docs").permitAll()
                .requestMatchers("/v3/api-docs/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .authenticationManagerResolver(authenticationManagerResolver)
            );

        return http.build();
    }

    @Bean
    @Order(2)
    public SecurityFilterChain adminFilterChain(
            HttpSecurity http,
            KeycloakAdminAuthenticationProvider keycloakAdminAuthenticationProvider,
            AuthenticationFailureHandler adminAuthenticationFailureHandler) throws Exception {
        http
            .securityMatcher("/admin/**", "/admin-assets/**", "/")
            .csrf(csrf -> csrf.disable())
            .authenticationProvider(keycloakAdminAuthenticationProvider)
            .authorizeHttpRequests(authz -> authz
                .requestMatchers(
                    "/admin/login",
                    "/admin/password-reset",
                    "/admin/password-change",
                    "/admin-assets/**",
                    "/error"
                ).permitAll()
                .requestMatchers("/admin/**").hasAnyRole("ADMIN", "MODERATOR")
                .requestMatchers("/").authenticated()
                .anyRequest().permitAll()
            )
            .formLogin(form -> form
                .loginPage("/admin/login")
                .loginProcessingUrl("/admin/login")
                .defaultSuccessUrl("/admin/dashboard", true)
                .failureHandler(adminAuthenticationFailureHandler)
            )
            .logout(logout -> logout
                .logoutUrl("/admin/logout")
                .logoutSuccessUrl("/admin/login?logout")
                .deleteCookies("JSESSIONID")
                .invalidateHttpSession(true)
            );

        return http.build();
    }

    @Bean
    public AuthenticationFailureHandler adminAuthenticationFailureHandler() {
        return (request, response, exception) -> {
            if (exception instanceof PasswordUpdateRequiredAuthenticationException passwordException) {
                String encodedEmail = UriUtils.encode(
                    passwordException.getEmail(),
                    StandardCharsets.UTF_8
                );
                response.sendRedirect("/admin/password-change?required=1&email=" + encodedEmail);
                return;
            }
            response.sendRedirect("/admin/login?error");
        };
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",
            "http://localhost:3001",
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
