# Keycloak - Wichtige Hinweise (Bookcycle)

## Zugangsdaten
- Keycloak Server-Admin (master realm):
  - Benutzer: `admin` (aus docker-compose KEYCLOAK_ADMIN)
  - Passwort: `admin123` (aus docker-compose KEYCLOAK_ADMIN_PASSWORD)
- Webadmin Realm-Admin (importierter User):
  - Realm: `bookcycle-webadmin`
  - Benutzer: `master-admin`
  - E-Mail: `master-admin@bookcycle.local`
  - Erstes Passwort: `admin123` (muss beim ersten Login geaendert werden)
- Mobile Demo-User:
  - Realm: `bookcycle-mobile`
  - Benutzer: `demo-member`
  - E-Mail: `member@bookcycle.local`
  - Passwort: `member123`

## Ports & URLs
- Keycloak laeuft lokal auf: `http://localhost:8180`
- Realms: `bookcycle-mobile`, `bookcycle-webadmin`

## Docker Compose Services
- Postgres (DB)
- Keycloak
- MailPit (SMTP)

## Realm-Import
- Realm-Exportdateien: `bookcycle/infra/keycloak-realms/realm-bookcycle-mobile.json` und `bookcycle/infra/keycloak-realms/realm-bookcycle-webadmin.json`
- Kombinierter Export: `bookcycle/infra/realm-export.json` (enthaelt Client-Credentials)
- Wird beim Start mit `--import-realm` geladen (siehe `bookcycle/docker-compose.yml`)

## Rollenvergabe
- Der User `master-admin` hat die Rolle `realm-admin` im Client `realm-management`.
- Damit kann er Rollen vergeben und andere Admins im Realm anlegen.

## Hinweise
- Wenn du den Realm neu importierst, werden Nutzer aus der JSON geladen.
- Aendere Default-Passwoerter fuer Produktion.
