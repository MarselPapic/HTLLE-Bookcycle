---
description: Systematischer Bugfix für das gesamte Bookcycle Backend
---

## Bugfix – Bookcycle Backend

Behebe den Bug im aktuellen **Bookcycle Spring Boot Backend**.

---

### Vorgehen

#### 1. Bug verstehen
- Fehlerbeschreibung sorgfältig analysieren
- Erwartetes vs. tatsächliches Verhalten vergleichen
- Betroffene Funktion klar benennen

---

#### 2. Reproduktion
- Wo tritt der Fehler auf?
- Exception, Log-Ausgabe oder HTTP-Statuscode analysieren
- Zusammenhang mit der H2-Datenbank prüfen

---

#### 3. Root Cause Analysis
- Ursache eindeutig identifizieren
- Betroffene Schicht benennen:
  - Controller
  - Service
  - Repository
- Konkrete Klasse und Methode nennen

---

#### 4. Fix
- Minimaler, gezielter Code-Eingriff
- Keine neuen Features
- Keine Architekturverletzungen
- Clean Architecture einhalten

---

#### 5. Test
- Test schreiben oder erweitern
- Test muss vor dem Fix fehlschlagen
- Test muss nach dem Fix bestehen
- JUnit 5 / Spring Boot Test verwenden

---

### Regeln
- Keine Quick-Hacks
- Keine neuen Dependencies
- Kein Auskommentieren von Code

---

### Liefere
- Kurze Erklärung der Ursache
- Relevanten Code oder Diff
- Passenden Testfall (Unit oder Integration)
