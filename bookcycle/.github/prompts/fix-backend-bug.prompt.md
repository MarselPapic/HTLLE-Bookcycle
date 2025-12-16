---
description: Systematischer Bugfix für Spring Boot Backend
mode: agent
---

## Bugfix – Bookcycle Backend

Behebe den Bug im aktuellen Code.

### Vorgehen
1. **Bug verstehen**
   - Beschreibung analysieren
   - Erwartetes vs. tatsächliches Verhalten

2. **Reproduktion**
   - Wo tritt der Fehler auf?
   - Exception / HTTP-Status?

3. **Root Cause Analysis**
   - Service, Repository oder Controller?
   - Datenbankzustand (H2)?

4. **Fix**
   - Minimaler Code-Eingriff
   - Keine neuen Features
   - Clean Architecture einhalten

5. **Test**
   - Test schreiben, der vorher fehlschlägt
   - Nach Fix erfolgreich

---

### Regeln
- Keine Quick-Hacks
- Keine neuen Dependencies
- Liefere:
  - Erklärung
  - Code-Diff
  - Testfall
