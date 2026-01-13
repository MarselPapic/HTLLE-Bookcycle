---
description: Neuen REST Endpoint für Bookcycle erstellen
---

## REST Endpoint – Bookcycle

Erstelle einen neuen REST-Endpoint für das **Bookcycle Backend (Spring Boot)**.

---

### Anforderungen
- Spring Boot REST Controller (`@RestController`)
- DTO für Request und Response
- Service-Methode mit Business-Logik
- Repository-Zugriff via Spring Data JPA
- Exception Handling mit Custom Exceptions
- Validierung mit Bean Validation (`@Valid`, `@NotNull`, etc.)

---

### Regeln
- RESTful Design (Plural-Namen, korrekte HTTP-Statuscodes)
- Saubere Paketstruktur:
  - controller
  - service
  - repository
  - domain / model
  - dto
- **Kein Business-Code im Controller**
- H2-Datenbank kompatibel bleiben
- Clean Architecture einhalten

---

### Ausgabe
Liefere:
- Controller
- Service
- DTO(s)
- Repository (falls erforderlich)
- Kurze technische Erklärung der Lösung
