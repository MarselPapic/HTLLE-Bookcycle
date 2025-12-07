# Bookcycle – Projektübersicht

## 1. Architektur & Bounded Contexts

- **Bookcycle Mobile (Flutter)** – Marketplace & Trading UI
- **Bookcycle Server (Spring Boot)** – REST-API + Admin-Weboberfläche
- Verknüpfung mit den Bounded Contexts aus dem Domain Model (Marketplace, Trading, Communication, Identity, Moderation).

## 2. Projektstruktur

- `mobile/`: Flutter-App für Enduser (Listings suchen, Bücher einstellen usw.)
- `server/`: Backend & Admin-GUI (Moderation, User Management, Reports)
- `shared-resources/`: Gemeinsame Dokumentation, Design Tokens, API-Contracts.
- `docs/`: Architektur, Workspace-Guide, Onboarding.

## 3. Workspace-Guide

  - Für Änderungen über mehrere Bounded Contexts (z. B. API + Mobile UI).
  - Fokus ausschließlich auf der Bookcycle-App (Flutter).
  - Fokus auf Backend & Admin-Weboberfläche.

### When to use which workspace

- `bookcycle-full.code-workspace`: Use this when you touch both mobile and server (API changes + UI). It opens `mobile/`, `server/` and shared resources.
- `bookcycle-mobile.code-workspace`: Use for focused Flutter development (only `mobile/` folder visible). Recommended when iterating on UI.
- `bookcycle-server.code-workspace`: Use for backend/server work and Admin UI. Opens `server/` only.
- `bookcycle-admin.code-workspace`: Optional workspace that focuses on the Admin UI inside `server/` (controllers, templates). Useful when editing views/templates frequently.

## 4. Entwicklungs-Workflow

1. Issues über Bookcycle-Issue-Templates anlegen.
2. Branch pro User Story (z. B. `feature/US-001-search-listings`).
3. Code in passendem Workspace bearbeiten.
4. Tests via VS-Code-Tasks ausführen (Flutter tests, mvn verify).
5. PR mit dem passenden Bookcycle-PR-Template erstellen.

## 5. GitHub Templates

- Issue Templates (in `.github/ISSUE_TEMPLATE/`):
  - `01_user_story.yml` – create a User Story (format & fields for planning)
  - `02_bug_report.yml` – bug reporting form
  - `03_enhancement.yml` – feature/enhancement requests
  - `04_refactor.yml` – refactor plan template

- Pull Request Templates (in `.github/PULL_REQUEST_TEMPLATE/`):
  - `bookcycle-mobile_pr_template.md` – use for mobile/Flutter changes
  - `bookcycle-server_pr_template.md` – use for backend changes
  - `bookcycle-admin_pr_template.md` – use for Admin UI changes

When testing templates locally, create test Issues/PRs on GitHub to verify the form fields.

## 6. VS Code Tasks (how to run)

Open Command Palette → `Tasks: Run Task` and choose one of:

- `mobile: pub get` – runs `flutter pub get` in `mobile/`
- `mobile: run` – runs `flutter run` in `mobile/`
- `mobile: test` – runs `flutter test`
- `server: mvn verify` – runs `mvn verify` in `server/`
- `server: run` – runs `mvn spring-boot:run`

Example to open mobile workspace:

```powershell
code bookcycle-mobile.code-workspace
```

Example to open full workspace:

```powershell
code bookcycle-full.code-workspace
```

## 7. Notes & Tips

- Keep `mobile/` as the active Flutter project (run `flutter create .` only if platforms are missing).
- Use the workspace-specific extension recommendations (VS Code will prompt to install them when you open the workspace).
- If you prefer exactly four workspace files for grading, keep `bookcycle-admin.code-workspace` as a dedicated Admin view.
