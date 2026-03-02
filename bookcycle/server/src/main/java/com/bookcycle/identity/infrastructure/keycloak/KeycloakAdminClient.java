package com.bookcycle.identity.infrastructure.keycloak;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.util.StringUtils;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.nio.charset.StandardCharsets;
import java.net.URI;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

/**
 * Infrastructure adapter for Keycloak Admin REST API.
 * Handles user creation and required action emails.
 */
@Component
public class KeycloakAdminClient {
    private static final String UPDATE_PASSWORD = "UPDATE_PASSWORD";
    private static final String VERIFY_EMAIL = "VERIFY_EMAIL";

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${app.keycloak.admin-url}")
    private String adminUrl;

    @Value("${app.keycloak.admin-realm:master}")
    private String adminRealm;

    @Value("${app.keycloak.admin-username:admin}")
    private String adminUsername;

    @Value("${app.keycloak.admin-password:admin123}")
    private String adminPassword;

    @Value("${app.keycloak.mobile-realm:bookcycle-mobile}")
    private String mobileRealm;

    @Value("${app.keycloak.webadmin-realm:bookcycle-webadmin}")
    private String webadminRealm;

    @Value("${app.keycloak.mobile-client-id:bookcycle-mobile}")
    private String mobileClientId;

    @Value("${app.keycloak.webadmin-client-id:bookcycle-webadmin}")
    private String webadminClientId;

    @Value("${app.keycloak.webadmin-client-secret:webadmin-client-secret}")
    private String webadminClientSecret;

    public KeycloakAdminClient(RestTemplate restTemplate, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }

    public UUID createMobileUser(String email, String displayName, String password) {
        UUID userId = createUser(
            mobileRealm,
            email,
            displayName,
            password,
            false,
            Set.of("MEMBER")
        );
        executeActionsEmail(mobileRealm, userId, mobileClientId, List.of(VERIFY_EMAIL), 86400);
        return userId;
    }

    public UUID createWebAdminUserWithTemporaryPassword(
            String email,
            String displayName,
            String temporaryPassword,
            Set<String> roles) {
        Set<String> safeRoles = (roles == null || roles.isEmpty()) ? Set.of("MODERATOR") : roles;
        return createUser(
            webadminRealm,
            email,
            displayName,
            temporaryPassword,
            true,
            safeRoles
        );
    }

    public void sendMobilePasswordResetEmail(String email) {
        Optional<UUID> userId = findUserIdByEmail(mobileRealm, email);
        userId.ifPresent(id -> executeActionsEmail(
            mobileRealm,
            id,
            mobileClientId,
            List.of(UPDATE_PASSWORD),
            900
        ));
    }

    public Set<String> authenticateWebAdmin(String email, String password) {
        String accessToken = requestWebAdminAccessToken(email, password);
        Set<String> roles = extractRolesFromAccessToken(accessToken);

        if (!roles.contains("ADMIN") && !roles.contains("MODERATOR")) {
            throw new IllegalArgumentException("User has no admin or moderator role.");
        }
        return roles;
    }

    public void completeWebAdminPasswordChange(
            String email,
            String currentPassword,
            String newPassword) {
        validateCurrentWebAdminPassword(email, currentPassword);

        UUID userId = findUserIdByEmail(webadminRealm, email)
            .orElseThrow(() -> new IllegalArgumentException("Admin user not found for email: " + email));

        String token = obtainAdminAccessToken();
        resetPassword(webadminRealm, userId, token, newPassword, false);
        removeRequiredAction(webadminRealm, userId, token, UPDATE_PASSWORD);
    }

    private UUID createUser(
            String realm,
            String email,
            String displayName,
            String password,
            boolean temporaryPassword,
            Set<String> realmRoles) {
        String token = obtainAdminAccessToken();
        URI uri = UriComponentsBuilder
            .fromHttpUrl(adminUrl)
            .path("/admin/realms/{realm}/users")
            .buildAndExpand(realm)
            .toUri();

        Map<String, String> nameParts = splitDisplayName(displayName);
        Map<String, Object> userPayload = Map.of(
            "username", email,
            "email", email,
            "enabled", true,
            "emailVerified", false,
            "firstName", nameParts.get("firstName"),
            "lastName", nameParts.get("lastName"),
            "requiredActions", temporaryPassword ? List.of(UPDATE_PASSWORD) : List.of(),
            "credentials", List.of(Map.of(
                "type", "password",
                "value", password,
                "temporary", temporaryPassword
            ))
        );

        try {
            ResponseEntity<Void> response = restTemplate.exchange(
                uri,
                HttpMethod.POST,
                new HttpEntity<>(userPayload, jsonHeaders(token)),
                Void.class
            );

            if (response.getStatusCode() != HttpStatus.CREATED) {
                throw new IllegalStateException("Keycloak did not create user. Status: " + response.getStatusCode());
            }

            String location = response.getHeaders().getFirst(HttpHeaders.LOCATION);
            if (location == null || location.isBlank()) {
                throw new IllegalStateException("Missing Location header from Keycloak create user response");
            }

            UUID userId = extractUserIdFromLocation(location);
            assignRealmRoles(realm, userId, token, realmRoles);
            return userId;
        } catch (HttpClientErrorException.Conflict conflict) {
            throw new IllegalArgumentException("User with email " + email + " already exists in Keycloak");
        } catch (RestClientException ex) {
            throw new IllegalStateException("Failed to create user in Keycloak", ex);
        }
    }

    private void assignRealmRoles(String realm, UUID userId, String token, Set<String> realmRoles) {
        if (realmRoles == null || realmRoles.isEmpty()) {
            return;
        }

        List<Map<String, Object>> roleRepresentations = new ArrayList<>();
        for (String roleName : realmRoles) {
            URI roleUri = UriComponentsBuilder
                .fromHttpUrl(adminUrl)
                .path("/admin/realms/{realm}/roles/{roleName}")
                .buildAndExpand(realm, roleName)
                .toUri();

            ResponseEntity<Map> roleResponse = restTemplate.exchange(
                roleUri,
                HttpMethod.GET,
                new HttpEntity<>(jsonHeaders(token)),
                Map.class
            );

            Map<String, Object> body = roleResponse.getBody();
            if (body != null && !body.isEmpty()) {
                roleRepresentations.add(body);
            }
        }

        if (roleRepresentations.isEmpty()) {
            return;
        }

        URI mappingUri = UriComponentsBuilder
            .fromHttpUrl(adminUrl)
            .path("/admin/realms/{realm}/users/{userId}/role-mappings/realm")
            .buildAndExpand(realm, userId)
            .toUri();

        restTemplate.exchange(
            mappingUri,
            HttpMethod.POST,
            new HttpEntity<>(roleRepresentations, jsonHeaders(token)),
            Void.class
        );
    }

    private Optional<UUID> findUserIdByEmail(String realm, String email) {
        String token = obtainAdminAccessToken();
        URI uri = UriComponentsBuilder
            .fromHttpUrl(adminUrl)
            .path("/admin/realms/{realm}/users")
            .queryParam("email", email)
            .queryParam("exact", true)
            .buildAndExpand(realm)
            .toUri();

        ResponseEntity<List> response = restTemplate.exchange(
            uri,
            HttpMethod.GET,
            new HttpEntity<>(jsonHeaders(token)),
            List.class
        );

        List<?> users = response.getBody();
        if (users == null || users.isEmpty()) {
            return Optional.empty();
        }

        Object firstUser = users.get(0);
        if (!(firstUser instanceof Map<?, ?> userMap)) {
            return Optional.empty();
        }

        Object id = userMap.get("id");
        if (!(id instanceof String userIdText)) {
            return Optional.empty();
        }

        return Optional.of(UUID.fromString(userIdText));
    }

    private void resetPassword(
            String realm,
            UUID userId,
            String token,
            String password,
            boolean temporary) {
        URI uri = UriComponentsBuilder
            .fromHttpUrl(adminUrl)
            .path("/admin/realms/{realm}/users/{userId}/reset-password")
            .buildAndExpand(realm, userId)
            .toUri();

        Map<String, Object> payload = Map.of(
            "type", "password",
            "value", password,
            "temporary", temporary
        );

        restTemplate.exchange(
            uri,
            HttpMethod.PUT,
            new HttpEntity<>(payload, jsonHeaders(token)),
            Void.class
        );
    }

    private void removeRequiredAction(
            String realm,
            UUID userId,
            String token,
            String actionToRemove) {
        URI userUri = UriComponentsBuilder
            .fromHttpUrl(adminUrl)
            .path("/admin/realms/{realm}/users/{userId}")
            .buildAndExpand(realm, userId)
            .toUri();

        ResponseEntity<Map> userResponse = restTemplate.exchange(
            userUri,
            HttpMethod.GET,
            new HttpEntity<>(jsonHeaders(token)),
            Map.class
        );

        Map<String, Object> user = userResponse.getBody();
        if (user == null) {
            return;
        }

        Object requiredActions = user.get("requiredActions");
        if (requiredActions instanceof List<?> actions) {
            List<String> updatedActions = actions.stream()
                .filter(String.class::isInstance)
                .map(String.class::cast)
                .filter(action -> !actionToRemove.equalsIgnoreCase(action))
                .toList();
            user.put("requiredActions", updatedActions);
        }

        restTemplate.exchange(
            userUri,
            HttpMethod.PUT,
            new HttpEntity<>(user, jsonHeaders(token)),
            Void.class
        );
    }

    private void validateCurrentWebAdminPassword(String email, String password) {
        try {
            requestWebAdminAccessToken(email, password);
        } catch (PasswordUpdateRequiredException ex) {
            // Temporary password is valid and change is required - intended case.
        }
    }

    private String requestWebAdminAccessToken(String email, String password) {
        URI tokenUri = UriComponentsBuilder
            .fromHttpUrl(adminUrl)
            .path("/realms/{realm}/protocol/openid-connect/token")
            .buildAndExpand(webadminRealm)
            .toUri();

        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "password");
        form.add("client_id", webadminClientId);
        form.add("client_secret", webadminClientSecret);
        form.add("username", email);
        form.add("password", password);
        form.add("scope", "openid profile email");

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(
                tokenUri,
                new HttpEntity<>(form, headers),
                Map.class
            );
            Map<?, ?> body = response.getBody();
            Object token = body != null ? body.get("access_token") : null;
            if (!(token instanceof String tokenValue) || tokenValue.isBlank()) {
                throw new IllegalArgumentException("Authentication failed.");
            }
            return tokenValue;
        } catch (HttpClientErrorException ex) {
            Map<String, Object> errorBody = parseErrorBody(ex.getResponseBodyAsString());
            String errorDescription = (String) errorBody.getOrDefault("error_description", "");
            if (errorDescription.contains("Account is not fully set up")) {
                throw new PasswordUpdateRequiredException(email);
            }
            throw new IllegalArgumentException("Invalid email or password.");
        } catch (RestClientException ex) {
            throw new IllegalStateException("Keycloak authentication failed.", ex);
        }
    }

    private Set<String> extractRolesFromAccessToken(String accessToken) {
        String[] parts = accessToken.split("\\.");
        if (parts.length < 2) {
            return Set.of();
        }

        try {
            String payloadJson = new String(
                Base64.getUrlDecoder().decode(parts[1]),
                StandardCharsets.UTF_8
            );
            Map<String, Object> claims = objectMapper.readValue(
                payloadJson,
                new TypeReference<Map<String, Object>>() {}
            );

            Set<String> roles = new HashSet<>();
            collectRoles(claims.get("roles"), roles);

            Object realmAccess = claims.get("realm_access");
            if (realmAccess instanceof Map<?, ?> realmAccessMap) {
                collectRoles(realmAccessMap.get("roles"), roles);
            }

            return roles;
        } catch (Exception ex) {
            return Set.of();
        }
    }

    private void collectRoles(Object source, Set<String> target) {
        if (!(source instanceof Collection<?> collection)) {
            return;
        }
        for (Object role : collection) {
            if (role instanceof String roleName && StringUtils.hasText(roleName)) {
                target.add(roleName.toUpperCase());
            }
        }
    }

    private Map<String, Object> parseErrorBody(String bodyText) {
        try {
            if (!StringUtils.hasText(bodyText)) {
                return Map.of();
            }
            return objectMapper.readValue(bodyText, new TypeReference<Map<String, Object>>() {});
        } catch (Exception ex) {
            return Map.of();
        }
    }

    private void executeActionsEmail(
            String realm,
            UUID userId,
            String clientId,
            Collection<String> actions,
            int lifespanSeconds) {
        String token = obtainAdminAccessToken();
        URI uri = UriComponentsBuilder
            .fromHttpUrl(adminUrl)
            .path("/admin/realms/{realm}/users/{userId}/execute-actions-email")
            .queryParam("client_id", clientId)
            .queryParam("lifespan", lifespanSeconds)
            .buildAndExpand(realm, userId)
            .toUri();

        try {
            restTemplate.exchange(
                uri,
                HttpMethod.PUT,
                new HttpEntity<>(actions, jsonHeaders(token)),
                Void.class
            );
        } catch (RestClientException ex) {
            throw new IllegalStateException("Failed to trigger Keycloak required actions email", ex);
        }
    }

    private String obtainAdminAccessToken() {
        URI tokenUri = UriComponentsBuilder
            .fromHttpUrl(adminUrl)
            .path("/realms/{realm}/protocol/openid-connect/token")
            .buildAndExpand(adminRealm)
            .toUri();

        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "password");
        form.add("client_id", "admin-cli");
        form.add("username", adminUsername);
        form.add("password", adminPassword);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        ResponseEntity<Map> response = restTemplate.postForEntity(
            tokenUri,
            new HttpEntity<>(form, headers),
            Map.class
        );

        Map<?, ?> body = response.getBody();
        if (body == null || !body.containsKey("access_token")) {
            throw new IllegalStateException("Could not obtain Keycloak admin token");
        }

        Object token = body.get("access_token");
        if (!(token instanceof String tokenValue) || tokenValue.isBlank()) {
            throw new IllegalStateException("Invalid Keycloak admin token");
        }
        return tokenValue;
    }

    private HttpHeaders jsonHeaders(String token) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(token);
        return headers;
    }

    private UUID extractUserIdFromLocation(String location) {
        String normalized = location.endsWith("/") ? location.substring(0, location.length() - 1) : location;
        String userId = normalized.substring(normalized.lastIndexOf('/') + 1);
        return UUID.fromString(userId);
    }

    private Map<String, String> splitDisplayName(String displayName) {
        String safeName = Objects.requireNonNullElse(displayName, "").trim();
        if (safeName.isEmpty()) {
            return Map.of("firstName", "Bookcycle", "lastName", "User");
        }

        String[] parts = safeName.split("\\s+", 2);
        String firstName = parts[0];
        String lastName = parts.length > 1 ? parts[1] : "";
        return Map.of("firstName", firstName, "lastName", lastName);
    }
}
