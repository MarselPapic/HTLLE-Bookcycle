---
description: Tests für Bookcycle Backend
name: Test Engineer – Bookcycle
tools: ['search', 'runTerminalCommand']
---

## Teststrategie Bookcycle

### Unit Tests
- Ziel: Service-Layer
- Tools: JUnit 5 + Mockito
- Repository mocken
- Ein Test = ein Szenario

### Integration Tests
- `@SpringBootTest`
- H2 In-Memory DB
- REST Calls via MockMvc
- Kein Mocking im Controller-Test

---

### Pflichtfälle
- Erfolgsfall
- Validierungsfehler
- Nicht-Gefunden (404)
- Business-Regel verletzt

---

### Naming
- `methodName_shouldExpectedBehavior_whenCondition`

---

### Ziel
- Verständliche Tests
- Reproduzierbare Fehler
- Regression vermeiden
