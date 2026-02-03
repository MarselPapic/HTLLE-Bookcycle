# Folder Overview (Detailed)

This file explains the current project folder structure after consolidating shared documentation.

## Top-Level Structure

```
bookcycle/
|-- docs/
|   |-- api/                      # API docs (README or references)
|   |-- architecture/             # Architecture + CDD/DDD structure
|   |-- chats/                    # Prompt/chats used for process guidance
|   |-- configurations/           # Config references
|   |-- delivery/                 # Delivery/hand-over notes
|   |-- development/              # Project overview, workflow, workspace usage
|   |-- implementation-details/   # Implementation summaries + traceability
|   |-- lessons-learned/          # Post-mortem and learnings
|   |-- prompts/                  # Prompt library
|   |-- requirements/             # User stories and acceptance criteria
|   |-- UI/                       # UI/Flutter component instructions
|   `-- shared-resources/         # Consolidated shared docs (see below)
|       |-- api-contracts/         # Shared API contract docs (moved from shared-resources)
|       |-- design-tokens/         # Design tokens docs (moved from shared-resources)
|       |-- documentation/         # General shared docs (moved from shared-resources)
|       |-- email-templates/       # HTML/TXT email templates
|       `-- ui/                    # UI prototypes (admin + mobile)
|-- infra/                         # Docker, DB init, Keycloak realms, mail templates
|-- legacy-frontend/               # Old static frontend (unused)
|-- mobile/                        # Flutter app
|   |-- lib/
|   |   |-- features/              # Bounded-context features (marketplace, trading, ...)
|   |   |-- screens/               # Page-level screens (Search, Chat, Profile, ...)
|   |   |-- shared/                # Shared providers/models
|   |   |-- theme/                 # Design tokens/theme setup
|   |   `-- widgets/               # Component-driven UI (see CDD below)
|   |-- test/                      # Widget/unit tests
|   `-- pubspec.yaml
|-- openapi/                       # OpenAPI specs
|-- server/                        # Spring Boot backend + Admin UI
|   |-- src/
|   |   |-- main/java/com/bookcycle/
|   |   |   |-- identity/           # Identity bounded context
|   |   |   |-- marketplace/        # Marketplace bounded context
|   |   |   |-- trading/            # Trading bounded context
|   |   |   |-- communication/      # Communication bounded context
|   |   |   |-- moderation/         # Moderation bounded context
|   |   |   `-- shared/             # Shared kernel + config
|   |   `-- main/resources/
|   |       |-- admin-ui/           # Admin UI templates + assets (Thymeleaf)
|   |       `-- static/             # Static assets
|   |-- pom.xml
|   `-- Dockerfile
|-- shared-resources/              # Now only technical artifacts
|   `-- yaml-schema/               # YAML schema definitions (kept here)
|-- .env.example
|-- docker-compose.yml
|-- README.md
`-- ...
```

## Shared Documentation (Single Source)

- All shared docs now live under `docs/`.
- The previous `shared-resources/docs` folder was removed.
- `shared-resources/` is reserved for non-doc assets (currently only `yaml-schema/`).

## CDD UI Structure (Flutter)

```
mobile/lib/widgets/
|-- atom/       # Smallest building blocks (buttons, inputs, icons)
|-- molecule/   # Combinations of atoms (search bar, cards, profile tiles)
|-- organism/   # Sections composed of molecules (lists, forms, threads)
`-- templates/  # Layout scaffolds and page structure
```

## Bounded Context Layout (Backend)

Each context follows the same internal layers:

```
server/src/main/java/com/bookcycle/<context>/
|-- domain/         # Entities, value objects, domain services
|-- application/    # DTOs, application services
|-- infrastructure/ # Persistence adapters, repositories
`-- presentation/   # REST + (optional) Web MVC controllers
```
