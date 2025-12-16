# Bookcycle – Backend KI Instructions

## Projektkontext
Du arbeitest am Backend-Projekt **Bookcycle**.
- Technologie: **Spring Boot (Java 17+)**
- Architektur: **Clean Architecture + REST**
- Datenbank: **H2 (In-Memory für Dev & Tests)**
- Build Tool: **Maven**
- Testing: **JUnit 5, Mockito, Spring Boot Test**

Bookcycle ist eine Plattform zum **Tauschen, Verleihen und Verwalten von Büchern**.

---

## Architekturregeln
- Trenne strikt:
  - controller (REST)
  - service (Business Logic)
  - repository (Persistence)
  - domain/model (Entities, Enums)
- Kein Business-Code im Controller
- Repositories enthalten **keine** Geschäftslogik

---

## Coding Standards (Java)
- Klassen: `PascalCase`
- Methoden & Variablen: `camelCase`
- REST-Endpoints im Plural (`/books`, `/users`)
- Verwende `Optional` statt `null`
- Nutze `@Transactional` bewusst

---

## Datenbank (H2)
- Verwende JPA/Hibernate
- Keine DB-spezifischen SQL-Features
- Initialisierung über `data.sql` nur für Tests
- IDs: `@GeneratedValue(strategy = GenerationType.IDENTITY)`

---

## Error Handling
- Verwende `@ControllerAdvice`
- Eigene Exceptions (z.B. `BookNotFoundException`)
- Keine Stacktraces im REST-Response

---

## Testing-Regeln
- **JUnit 5**
- Unit Tests für Services
- Integration Tests für Controller (`@SpringBootTest`)
- Arrange – Act – Assert strikt einhalten

---

## Antwortverhalten
- Antworte **technisch, präzise, ohne Emojis**
- Liefere **Code + kurze Begründung**
- Wenn Annahmen nötig sind → explizit nennen
