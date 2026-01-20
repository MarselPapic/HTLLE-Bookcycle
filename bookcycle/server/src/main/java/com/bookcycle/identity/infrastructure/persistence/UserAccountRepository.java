package com.bookcycle.identity.infrastructure.persistence;

import com.bookcycle.identity.domain.model.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository: UserAccount
 * 
 * Spring Data JPA repository for UserAccount aggregate persistence.
 * Abstracts database operations and maintains transactional boundaries.
 */
@Repository
public interface UserAccountRepository extends JpaRepository<UserAccount, UUID> {
    Optional<UserAccount> findByEmailValue(String email);
    Optional<UserAccount> findByIdAndActiveTrue(UUID id);
    long countByActiveTrue();
}
