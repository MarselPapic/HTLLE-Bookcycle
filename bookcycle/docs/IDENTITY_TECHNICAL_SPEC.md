# Identity & Access Control – Technical Specification

**Document:** Technical Design for Identity & Access Management  
**Bounded Context:** Identity & Access  
**Architecture:** DDD + Clean/Hexagonal  
**Date:** January 2026

---

## 1. Domain Model

### Aggregate Root: UserAccount

```
UserAccount (Root)
├─ id: UUID (Keycloak UUID)
├─ email: Email (Value Object)
├─ profile: UserProfile (Owned Entity)
├─ roles: Set<UserRole> (Enumeration)
├─ active: Boolean
├─ createdAt: LocalDateTime
└─ updatedAt: LocalDateTime

Invariants:
- Email is unique
- At least one role (MEMBER)
- Active users only in queries
- ID immutable (from Keycloak)
```

### Entity: UserProfile

```
UserProfile (Owned by UserAccount)
├─ userId: UUID (FK)
├─ displayName: DisplayName (Value Object, required)
├─ location: Location (Value Object, optional)
├─ avatarUrl: AvatarUrl (Value Object, optional)
├─ createdAt: LocalDateTime
└─ updatedAt: LocalDateTime

Invariants:
- Must belong to existing UserAccount
- Display name always required
```

### Value Objects

1. **Email** (254 chars max, valid format)
2. **DisplayName** (2-100 chars, non-empty)
3. **Location** (0-100 chars, optional)
4. **AvatarUrl** (valid HTTPS URL, optional, 500 chars max)

### Enumeration: UserRole

```
MEMBER       → Basic trading rights
MODERATOR    → Moderation + MEMBER rights
ADMIN        → All rights (composite)
```

---

## 2. Bounded Context Boundaries

**Scope:** User identity, authentication, authorization  
**External:** Keycloak realm, MailPit for emails  
**Internal:** Profile persistence, role synchronization

---

## 3. Repository Interface

```java
public interface UserAccountRepository {
    void save(UserAccount account);
    Optional<UserAccount> findById(UUID id);
    Optional<UserAccount> findByEmail(Email email);
    Optional<UserAccount> findActiveUser(UUID id);
    long countActiveUsers();
    void delete(UserAccount account);
}
```

---

## 4. Key Use Cases

### UC1: Register User
```
Input: email, password, displayName
Output: User ID + confirmation message
Process:
1. Validate inputs
2. Check email uniqueness
3. Create UserAccount + UserProfile
4. Persist to DB
5. (Async) Create in Keycloak
6. Send verification email
```

### UC2: Get Current User Profile
```
Input: JWT token (with sub, email, roles)
Output: UserProfileResponse
Process:
1. Validate JWT
2. Extract userId from "sub" claim
3. Find UserAccount by ID
4. Return profile + roles from JWT
```

### UC3: Update Profile
```
Input: JWT token, updateRequest (displayName, location, avatarUrl)
Output: Updated UserProfileResponse
Process:
1. Validate JWT + extract userId
2. Find UserAccount
3. Update profile fields
4. Persist changes
5. Return updated profile
```

### UC4: Synchronize Roles (from JWT)
```
Input: Keycloak JWT with roles claim
Output: Updated UserAccount
Process:
1. Extract userId, roles from JWT
2. Find or create UserAccount
3. Update role set
4. Persist
```

---

## 5. API Contracts (OpenAPI 3.0)

### Authentication Endpoints

```yaml
POST /auth/register:
  - Request: { email, password, displayName }
  - Response: { id, email, displayName, message }
  - Status: 201 Created

POST /auth/login:
  - Redirects to Keycloak OAuth2 endpoint
  - Status: 200 OK (info response)

POST /auth/logout:
  - Requires: JWT Bearer token
  - Response: { message }
  - Status: 200 OK

POST /auth/password-reset:
  - Request: { email }
  - Response: { message }
  - Status: 202 Accepted

POST /auth/password-reset/confirm:
  - Request: { token, newPassword }
  - Response: { message }
  - Status: 200 OK
```

### User Profile Endpoints

```yaml
GET /users/me:
  - Requires: JWT Bearer token
  - Response: UserProfileResponse
  - Status: 200 OK

PUT /users/me:
  - Requires: JWT Bearer token
  - Request: { displayName, location?, avatarUrl? }
  - Response: UserProfileResponse
  - Status: 200 OK
```

### Health Endpoints

```yaml
GET /health:
  - Response: { status, components }
  - Status: 200 OK / 503 Service Unavailable

GET /health/live:
  - K8s liveness probe
  - Status: 200 (UP) / 503 (DOWN)

GET /health/ready:
  - K8s readiness probe
  - Status: 200 (READY) / 503 (NOT_READY)
```

---

## 6. Database Schema

### Table: user_accounts
```sql
CREATE TABLE identity.user_accounts (
    id UUID PRIMARY KEY,
    email VARCHAR(254) NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

### Table: user_profiles
```sql
CREATE TABLE identity.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES user_accounts(id),
    display_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    avatar_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

### Table: user_roles
```sql
CREATE TABLE identity.user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES user_accounts(id),
    role VARCHAR(50) NOT NULL CHECK (role IN ('MEMBER', 'MODERATOR', 'ADMIN')),
    assigned_at TIMESTAMP NOT NULL,
    UNIQUE(user_id, role)
);
```

---

## 7. Security Configuration

### JWT Validation
- **Issuer:** Keycloak (http://keycloak:8080/realms/bookcycle)
- **JWK Endpoint:** .../protocol/openid-connect/certs
- **Claims:** sub, email, roles, exp, iat

### Authorities Mapping
- JWT `roles` → Spring `GrantedAuthority` (ROLE_MEMBER, etc.)
- Via: `KeycloakJwtAuthenticationConverter`

### Endpoint Authorization
```
PUBLIC: /auth/register, /auth/login, /auth/password-reset, /health
AUTHENTICATED: /users/**, /auth/logout
ROLE_ADMIN: (future moderation endpoints)
ROLE_MODERATOR: (future moderation endpoints)
```

---

## 8. Error Scenarios

| Scenario | HTTP Status | Error Code | Message |
|----------|-------------|-----------|---------|
| Invalid email format | 400 | INVALID_REQUEST | Email must be valid |
| Email already exists | 409 | CONFLICT | User with this email already exists |
| User not found | 404 | NOT_FOUND | User profile not found |
| Invalid JWT | 401 | UNAUTHORIZED | Invalid or expired token |
| Permission denied | 403 | FORBIDDEN | Insufficient permissions |
| Server error | 500 | INTERNAL_ERROR | Internal server error |

---

## 9. Integration Points

### With Keycloak
- OAuth2 Authorization Code Flow
- User creation via Admin API (future)
- Role synchronization (JWT claims)
- Email verification (via MailPit)
- Password reset (token-based, 15 min expiry)

### With PostgreSQL
- User account persistence
- Profile data storage
- Role assignments
- Audit log (future)

### With MailPit
- Email verification links
- Password reset tokens
- Notification emails (future)

---

## 10. Future Enhancements

- [ ] Audit logging (WHO did WHAT WHEN)
- [ ] Two-factor authentication (2FA)
- [ ] Social login (Google, GitHub)
- [ ] User account deactivation
- [ ] Export/import user data
- [ ] Admin user management endpoints
- [ ] Permission-based access (vs. role-based)
- [ ] Refresh token rotation

---

**Version:** 1.0 | **Status:** ✅ Implementation Complete
