# CDD / DDD Implementation Structure

This project follows context-driven DDD. Each bounded context owns its domain model and application logic.

## Backend (Spring Boot)

Package root: server/src/main/java/com/bookcycle/

Contexts:
- identity (existing implementation)
- marketplace
- trading
- communication
- moderation
- shared (shared kernel)

Each context uses the same internal layers:
- domain
- application
- infrastructure
- presentation

## Admin Web (Spring Boot templates)

Location: server/src/main/resources/admin-ui/

- assets/css
- assets/js
- pages
- partials

## Mobile (Flutter)

Feature root: mobile/lib/features/

Contexts (features):
- marketplace
- trading
- communication
- identity
- moderation

Each feature uses:
- data
- domain
- presentation

## Shared Resources

shared-resources/ contains cross-team docs, design tokens, and UI prototypes.
