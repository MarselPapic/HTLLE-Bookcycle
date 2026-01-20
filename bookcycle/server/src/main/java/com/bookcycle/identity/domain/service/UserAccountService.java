package com.bookcycle.identity.domain.service;

import com.bookcycle.identity.domain.model.*;
import com.bookcycle.identity.infrastructure.persistence.UserAccountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * Domain Service: UserAccountService
 * 
 * Handles user account business logic and persistence.
 * Orchestrates between domain model and infrastructure layer.
 */
@Service
@RequiredArgsConstructor
public class UserAccountService {
    private final UserAccountRepository repository;

    /**
     * Create and persist a new user account
     * Typically called during registration
     */
    @Transactional
    public UserAccount createUserAccount(UUID keycloakId, String email, String displayName) {
        // Check if user already exists
        if (repository.findByEmailValue(email).isPresent()) {
            throw new IllegalArgumentException("User with email " + email + " already exists");
        }

        UserAccount account = UserAccount.create(
            keycloakId,
            Email.of(email),
            DisplayName.of(displayName)
        );

        return repository.save(account);
    }

    /**
     * Get user account by ID
     */
    @Transactional(readOnly = true)
    public Optional<UserAccount> getUserAccount(UUID id) {
        return repository.findByIdAndActiveTrue(id);
    }

    /**
     * Get user account by email
     */
    @Transactional(readOnly = true)
    public Optional<UserAccount> getUserAccountByEmail(String email) {
        return repository.findByEmailValue(email);
    }

    /**
     * Synchronize user roles from Keycloak JWT
     * Called when user authenticates
     */
    @Transactional
    public UserAccount synchronizeFromKeycloak(UUID keycloakId, String email, 
                                               String displayName, Set<UserRole> roles) {
        Optional<UserAccount> existing = repository.findById(keycloakId);

        if (existing.isPresent()) {
            UserAccount account = existing.get();
            account.synchronizeRoles(roles);
            return repository.save(account);
        } else {
            // First time user - create account
            return createUserAccount(keycloakId, email, displayName);
        }
    }

    /**
     * Update user profile information
     */
    @Transactional
    public UserAccount updateProfile(UUID id, DisplayName displayName, 
                                     Location location, AvatarUrl avatarUrl) {
        UserAccount account = repository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + id));

        account.updateProfile(displayName, location, avatarUrl);
        return repository.save(account);
    }

    /**
     * Deactivate a user account
     */
    @Transactional
    public void deactivateUser(UUID id) {
        UserAccount account = repository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + id));

        account.deactivate();
        repository.save(account);
    }

    /**
     * Get total active user count
     */
    @Transactional(readOnly = true)
    public long getActiveUserCount() {
        return repository.countByActiveTrue();
    }
}
