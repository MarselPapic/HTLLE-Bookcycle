---
description: Systematischer Bugfix für Spring Boot Backend
---

## Bugfix – Bookcycle Backend

Behebe den Bug im aktuellen **Bookcycle Spring Boot Backend**.

---

### Vorgehen

#### 1. Bug verstehen
- Beschreibung analysieren
- Erwartetes vs. tatsächliches Verhalten vergleichen

---

#### 2. Reproduktion
- Wo tritt der Fehler auf?
- Exception, Log-Ausgabe oder HTTP-Statuscode analysieren
- Datenbankzustand (H2) berücksichtigen

---

#### 3. Root Cause Analysis
- Ursache eindeutig bestimmen
- Betroffene Schicht identifizieren:
  - Controller
  - Service
  - Repository
- Konkrete Klasse/Methode nennen

---

#### 4. Fix
- Minimaler Code-Eingriff
- Keine neuen Features
- Clean Architecture einhalten
- Keine Seiteneffekte erzeugen

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
- Relevanten Code oder Code-Diff
- Passenden Testfall (Unit oder Integration)
