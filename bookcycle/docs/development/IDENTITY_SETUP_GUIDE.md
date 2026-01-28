# Bookcycle â€“ Identity, Backend & DevOps Setup Guide

**Status:** âœ… Production-ready architecture  
**Version:** 1.0.0  
**Date:** January 2026  

---

## ðŸ“‹ Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Local Setup (Docker Compose)](#local-setup-docker-compose)
3. [Keycloak Configuration](#keycloak-configuration)
4. [Backend Development](#backend-development)
5. [Mobile Development](#mobile-development)
6. [API Documentation](#api-documentation)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

### Identity & Access Bounded Context

**Bookcycle** implements **Domain-Driven Design (DDD)** with a focus on Identity & Access:

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Keycloak (Auth Provider)                               â”‚
â”‚ - User Management (LDAP, DB)                           â”‚
â”‚ - OAuth2 / OIDC Protocol                              â”‚
â”‚ - JWT Token Issuance                                  â”‚
â”‚ - SMTP Integration (MailPit)                         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                   â”‚
                   â”‚ Token + Claims
                   â”‚
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Spring Boot Backend (Resource Server)                  â”‚
â”‚                                                        â”‚
â”‚ Domain Layer:                                         â”‚
â”‚  - UserAccount (Aggregate Root)                       â”‚
â”‚  - UserProfile (Entity)                              â”‚
â”‚  - Email, DisplayName, Location (Value Objects)      â”‚
â”‚  - UserRole Enum                                     â”‚
â”‚                                                        â”‚
â”‚ Application Layer:                                    â”‚
â”‚  - IdentityApplicationService                        â”‚
â”‚  - AuthenticationController                          â”‚
â”‚  - UserController                                    â”‚
â”‚                                                        â”‚
â”‚ Infrastructure:                                       â”‚
â”‚  - UserAccountRepository (JPA)                       â”‚
â”‚  - PostgreSQL Persistence                           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                   â”‚
                   â”‚ REST API
                   â”‚
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Mobile / Web Clients                                   â”‚
â”‚ - Flutter App (Repository Pattern)                    â”‚
â”‚ - Admin Web (Spring MVC templates)                                â”‚
â”‚ - OAuth2 Redirect Flow                              â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Design Principles

- **Single Source of Truth:**
  - **Keycloak:** Email, Password, Roles (canonical)
  - **Backend:** Profile data (displayName, location, avatarUrl)

- **Role-Based Access Control (RBAC):**
  - MEMBER: Basic user
  - MODERATOR: Moderation privileges
  - ADMIN: Full system access

- **JWT Token Structure:**
  ```json
  {
    "sub": "uuid-from-keycloak",
    "email": "user@example.com",
    "roles": ["MEMBER"],
    "exp": 1234567890,
    "iat": 1234567800
  }
  ```

---

## Local Setup (Docker Compose)

### Prerequisites

- **Docker Desktop** (version 20.10+)
- **Docker Compose** (version 1.29+)
- **Java 17** (for local backend development)
- **Maven 3.8+** (for building backend)
- **Flutter 3.0+** (for mobile development)

### Quick Start

#### 1. Clone & Navigate

```bash
cd bookcycle
```

#### 2. Create `.env` file

```bash
cp .env.example .env
```

Default values are safe for local development:

```env
POSTGRES_DB=bookcycle
POSTGRES_USER=bookcycle
POSTGRES_PASSWORD=bookcycle123
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin123
```

#### 3. Start Services

```bash
docker-compose up -d
```

Wait for all services to be healthy (~30-60 seconds):

```bash
docker-compose ps
```

Expected output:
```
NAME                    STATUS
bookcycle-postgres      healthy
bookcycle-keycloak      healthy
bookcycle-mailpit       healthy
```

#### 4. Verify Setup

**Keycloak Admin Console:**
- URL: http://localhost:8180
- Username: `admin`
- Password: `admin123` (first login requires change)

**MailPit (Email Testing):**
- URL: http://localhost:8025

**Postgres (if you need direct access):**
```bash
psql -h localhost -U bookcycle -d bookcycle
# Password: bookcycle123
```

---

## Keycloak Configuration

### Realms: `bookcycle-mobile` and `bookcycle-webadmin`

Both realms are automatically imported when Keycloak starts (via `infra/keycloak-realms/realm-bookcycle-mobile.json` and `infra/keycloak-realms/realm-bookcycle-webadmin.json`).
A combined export with client credentials is stored at `infra/realm-export.json`.

#### Pre-configured Users

**Mobile realm (`bookcycle-mobile`)**

| Username | Email | Password | Role |
|----------|-------|----------|------|
| `demo-member` | member@bookcycle.local | member123 | MEMBER |

**Webadmin realm (`bookcycle-webadmin`)**

| Username | Email | Password | Role |
|----------|-------|----------|------|
| `master-admin` | master-admin@bookcycle.local | admin123 (temporary) | ADMIN |

#### Clients

**Mobile realm**
1. **bookcycle-mobile** (public)
   - Authorization Code Flow + Direct Access Grants
   - Deep linking: `com.bookcycle.app://callback`
2. **bookcycle-backend** (confidential)
   - Service-to-service and token validation

**Webadmin realm**
1. **bookcycle-webadmin** (confidential)
   - Authorization Code Flow
   - Redirects: `http://localhost:3001/*`
2. **bookcycle-backend** (confidential)
   - Service-to-service and token validation

### Email Configuration

Keycloak is configured to use **MailPit** (port 1025) for email:

- **From:** noreply@bookcycle.local
- **SMTP Server:** mailpit:1025

Email templates are customized via the `bookcycle` email theme (see `infra/keycloak-theme/bookcycle/email/messages`).

To view sent emails:
1. Go to http://localhost:8025
2. Check "Email Verification" messages
3. Extract reset tokens or confirmation links

### Roles

Realm-level roles are defined per realm:

```
bookcycle-mobile:
├─ MEMBER
├─ MODERATOR

bookcycle-webadmin:
├─ ADMIN
└─ MODERATOR
```

Client roles are also defined per client (e.g. `profile:read`, `reports:manage`) and included in the token via protocol mappers.

Roles are:
- Assigned to users in Keycloak Admin Console
- Included in JWT `roles` claim
- Validated by Spring Security on backend
---

## Backend Development

### Project Structure

```
server/
â”œâ”€ pom.xml                          # Maven configuration
â”œâ”€ src/
â”‚  â”œâ”€ main/
â”‚  â”‚  â”œâ”€ java/com/bookcycle/
â”‚  â”‚  â”‚  â”œâ”€ identity/
â”‚  â”‚  â”‚  â”‚  â”œâ”€ domain/
â”‚  â”‚  â”‚  â”‚  â”‚  â”œâ”€ model/
â”‚  â”‚  â”‚  â”‚  â”‚  â”‚  â”œâ”€ UserAccount.java
â”‚  â”‚  â”‚  â”‚  â”‚  â”‚  â”œâ”€ UserProfile.java
â”‚  â”‚  â”‚  â”‚  â”‚  â”‚  â”œâ”€ UserRole.java
â”‚  â”‚  â”‚  â”‚  â”‚  â”‚  â”œâ”€ Email.java
â”‚  â”‚  â”‚  â”‚  â”‚  â”‚  â”œâ”€ DisplayName.java
â”‚  â”‚  â”‚  â”‚  â”‚  â”‚  â””â”€ ...
â”‚  â”‚  â”‚  â”‚  â”‚  â””â”€ service/
â”‚  â”‚  â”‚  â”‚  â”‚     â””â”€ UserAccountService.java
â”‚  â”‚  â”‚  â”‚  â”œâ”€ application/
â”‚  â”‚  â”‚  â”‚  â”‚  â”œâ”€ service/
â”‚  â”‚  â”‚  â”‚  â”‚  â”‚  â””â”€ IdentityApplicationService.java
â”‚  â”‚  â”‚  â”‚  â”‚  â””â”€ dto/
â”‚  â”‚  â”‚  â”‚  â”‚     â”œâ”€ RegisterRequest.java
â”‚  â”‚  â”‚  â”‚  â”‚     â”œâ”€ UserProfileResponse.java
â”‚  â”‚  â”‚  â”‚  â”‚     â””â”€ ...
â”‚  â”‚  â”‚  â”‚  â”œâ”€ infrastructure/
â”‚  â”‚  â”‚  â”‚  â”‚  â””â”€ persistence/
â”‚  â”‚  â”‚  â”‚  â”‚     â””â”€ UserAccountRepository.java
â”‚  â”‚  â”‚  â”‚  â””â”€ presentation/
â”‚  â”‚  â”‚  â”‚     â””â”€ rest/
â”‚  â”‚  â”‚  â”‚        â”œâ”€ AuthenticationController.java
â”‚  â”‚  â”‚  â”‚        â””â”€ UserController.java
â”‚  â”‚  â”‚  â””â”€ config/
â”‚  â”‚  â”‚     â”œâ”€ SecurityConfig.java
â”‚  â”‚  â”‚     â””â”€ KeycloakJwtAuthenticationConverter.java
â”‚  â”‚  â””â”€ resources/
â”‚  â”‚     â””â”€ application.yml
â”‚  â””â”€ test/
â”‚     â””â”€ java/...
â””â”€ target/
```

### Build & Run

#### Build

```bash
cd server
mvn clean package
```

#### Run Locally

**Option 1: Maven Spring Boot Plugin**

```bash
mvn spring-boot:run
```

**Option 2: Docker (if Dockerfile exists)**

```bash
docker build -t bookcycle-server:latest .
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/bookcycle \
  bookcycle-server:latest
```

#### Access Backend

- **API Root:** http://localhost:8080/api/v1
- **Swagger/OpenAPI:** http://localhost:8080/swagger-ui.html
- **Health:** http://localhost:8080/health

### Testing

#### Unit Tests

```bash
mvn test
```

#### Integration Tests

```bash
mvn verify -P integration-tests
```

Tests use H2 in-memory database by default. To use PostgreSQL:

```bash
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/bookcycle_test \
mvn verify
```

---

## Mobile Development

### Repository Pattern (Offline-First)

The Flutter app implements a **Repository Pattern** with mock and real implementations:

**Mock Mode (Default):**
```bash
cd mobile
flutter run
# App runs with local mock data (no backend needed)
```

**Live Mode:**
```bash
flutter run --dart-define=BOOKCYCLE_MOCK_MODE=false
# App connects to real backend at http://localhost:8080/api/v1
```

### Project Structure

```
mobile/
â”œâ”€ pubspec.yaml
â”œâ”€ lib/
â”‚  â”œâ”€ main.dart                          # Repository selection
â”‚  â”œâ”€ shared/
â”‚  â”‚  â”œâ”€ repositories/
â”‚  â”‚  â”‚  â””â”€ user_repository.dart         # Interface + Mock + Real
â”‚  â”‚  â””â”€ models/
â”‚  â”‚     â””â”€ user_model.dart              # User DTO
â”‚  â””â”€ pages/
â”‚     â”œâ”€ home_page.dart
â”‚     â””â”€ login_page.dart
â””â”€ test/
   â””â”€ ...
```

### Development Workflow

#### Running with Mock Data

```bash
cd mobile
flutter pub get
flutter run
```

This:
1. Uses `MockUserRepository` (in-memory data)
2. Simulates network delays (500ms)
3. Allows offline development & testing

#### Running with Real Backend

1. Start backend: `cd server && mvn spring-boot:run`
2. Update backend URL in code (if needed)
3. Run: `flutter run --dart-define=BOOKCYCLE_MOCK_MODE=false`

#### Tests

```bash
flutter test
```

---

## API Documentation

### OpenAPI 3.0 Specification

The API is fully documented in **Contract-First** approach:

**Location:** `openapi/api-spec-identity.yaml`

### Endpoints

#### Authentication

| Method | Endpoint | Public? | Description |
|--------|----------|---------|-------------|
| POST | /auth/register | Yes | Register new user |
| POST | /auth/login | Yes | Login (redirects to Keycloak) |
| POST | /auth/logout | No | Logout & revoke token |
| POST | /auth/password-reset | Yes | Request password reset |
| POST | /auth/password-reset/confirm | Yes | Confirm password reset |

#### Users

| Method | Endpoint | Public? | Description |
|--------|----------|---------|-------------|
| GET | /users/me | No | Get current user profile |
| PUT | /users/me | No | Update user profile |

#### Health

| Method | Endpoint | Public? | Description |
|--------|----------|---------|-------------|
| GET | /health | Yes | Application health |
| GET | /health/live | Yes | Liveness probe (K8s) |
| GET | /health/ready | Yes | Readiness probe (K8s) |

### Example: Get Current User

**Request:**
```bash
curl -H "Authorization: Bearer <JWT_TOKEN>" \
  http://localhost:8080/api/v1/users/me
```

**Response (200):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "user@example.com",
  "displayName": "John Doe",
  "location": "Vienna",
  "avatarUrl": null,
  "roles": ["MEMBER"],
  "active": true,
  "createdAt": "2024-01-20T10:30:00Z",
  "updatedAt": "2024-01-20T10:30:00Z"
}
```

### Example: Update Profile

**Request:**
```bash
curl -X PUT \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  http://localhost:8080/api/v1/users/me \
  -d '{
    "displayName": "John Updated",
    "location": "Salzburg",
    "avatarUrl": "https://example.com/avatar.jpg"
  }'
```

### Getting a JWT Token

For local testing, use Keycloak's token endpoint:

```bash
# Mobile realm
curl -X POST http://localhost:8180/realms/bookcycle-mobile/protocol/openid-connect/token \
  -d "client_id=bookcycle-backend" \
  -d "client_secret=change-me-in-production" \
  -d "username=demo-member" \
  -d "password=member123" \
  -d "grant_type=password"

# Webadmin realm
curl -X POST http://localhost:8180/realms/bookcycle-webadmin/protocol/openid-connect/token \
  -d "client_id=bookcycle-backend" \
  -d "client_secret=change-me-in-production" \
  -d "username=master-admin" \
  -d "password=admin123" \
  -d "grant_type=password"
```

Response includes `access_token` (use as Bearer token).

---

## CI/CD Pipeline

### GitHub Actions Workflows

Located in `.github/workflows/`:

#### 1. `backend-ci.yml` (Backend Build & Tests)

Triggered on:
- Push to `main` / `develop` (changes in `server/`)
- Pull Requests

Jobs:
- **Code Quality:** Compile check, style validation
- **Build:** Maven clean package
- **Tests:** Unit + Integration tests
- **OpenAPI Validation:** YAML syntax + completeness
- **Docker Build:** (on main branch)
- **Security Scan:** Trivy vulnerability scanner

**Status Required:** Yes (blocks PR merge if failed)

#### 2. `merge-validation.yml` (PR Merge Rules)

Enforces:
- âœ… All CI jobs must pass
- âœ… Code reviews: minimum 1 approval
- âœ… Conversation resolution
- âœ… Branch up-to-date with main

### Local CI Simulation

Test locally before pushing:

```bash
# Backend build + tests
cd server
mvn clean verify

# OpenAPI validation
cd ../openapi
# Validate syntax (requires openapi-generator-cli)
openapi-generator-cli validate -i api-spec-identity.yaml
```

### Deployment (Future)

Once CI/CD is stable, add deployment workflows:
- Docker image push to registry
- Infrastructure provisioning (Bicep/Terraform)
- Kubernetes deployment

---

## Troubleshooting

### Docker Issues

**Keycloak won't start:**
```bash
docker-compose logs keycloak
```

Check:
- PostgreSQL is healthy first: `docker-compose ps`
- Port 8180 is available
- Sufficient disk space

**Reset everything:**
```bash
docker-compose down -v
docker-compose up -d
```

### Backend Build Fails

**Maven issues:**
```bash
cd server
mvn clean
mvn compile
```

**Java version mismatch:**
```bash
java -version  # Must be Java 17+
export JAVA_HOME=/path/to/jdk17
```

### Keycloak Token Issues

**Token validation fails in Spring:**
1. Verify JWT decoder can reach Keycloak JWK endpoint
2. Check `SecurityConfig` issuer list matches the active realms
3. Ensure Keycloak is running: `http://localhost:8180/health`

**Get a fresh token:**
```bash
# Mobile realm
curl -X POST http://localhost:8180/realms/bookcycle-mobile/protocol/openid-connect/token \
  -d "client_id=bookcycle-backend" \
  -d "client_secret=change-me-in-production" \
  -d "username=demo-member" \
  -d "password=member123" \
  -d "grant_type=password"

# Webadmin realm
curl -X POST http://localhost:8180/realms/bookcycle-webadmin/protocol/openid-connect/token \
  -d "client_id=bookcycle-backend" \
  -d "client_secret=change-me-in-production" \
  -d "username=master-admin" \
  -d "password=admin123" \
  -d "grant_type=password"
```

### Flutter App Issues

**Mock data not loading:**
- Check `USE_MOCK_DATA` constant in `main.dart`
- Ensure `user_repository.dart` is in `lib/shared/repositories/`

**Live mode fails:**
1. Verify backend is running: `http://localhost:8080/health`
2. Check CORS config in `SecurityConfig`
3. Update backend URL if needed

---

## Definition of Done âœ…

### Identity & Backend Implementation

- [x] Keycloak realms exported as JSON (see `infra/keycloak-realms` and `infra/realm-export.json`)
- [x] PostgreSQL schema initialized
- [x] Domain Model (UserAccount, UserProfile, Value Objects)
- [x] REST Controllers (Auth, Users)
- [x] Application Services
- [x] Repository Pattern with JPA
- [x] JWT validation in Spring Security
- [x] OpenAPI 3.0 specification
- [x] Docker Compose (PG + Keycloak + MailPit)
- [x] `docker-compose up` launches all services
- [x] GitHub Actions CI/CD pipeline
- [x] Mobile mock mode repository pattern
- [x] README documentation

### Testing & Validation

- [ ] Integration tests (local)
- [ ] Keycloak SMTP email flow tested
- [ ] Token refresh working
- [ ] Password reset flow validated
- [ ] Mobile mock data scenario complete

---

## Next Steps (Future Features)

1. **Marketplace Bounded Context**
   - Listing Management
   - Offer/Request System

2. **Trading Bounded Context**
   - Trade Negotiation
   - Escrow Management

3. **Communication Bounded Context**
   - Messaging System
   - Notifications

4. **Moderation Bounded Context**
   - Content Moderation
   - User Reporting

---

## Support & Questions

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review logs: `docker-compose logs <service>`
3. Check OpenAPI spec: `openapi/api-spec-identity.yaml`
4. Review code comments in domain model

---

**Version:** 1.0.0 | **Last Updated:** January 2026






