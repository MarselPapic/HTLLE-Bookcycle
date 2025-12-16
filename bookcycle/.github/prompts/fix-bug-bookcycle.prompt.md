---
description: Projektweiter Bugfix für das gesamte Bookcycle-Projekt
agent: true
---

## Bugfix – Bookcycle (Projektweit)

Behebe den beschriebenen Bug im **gesamten Bookcycle-Projekt**.

Der Bug kann sich befinden in:
- Backend (Spring Boot)
- REST-Controllern
- Service-Logik
- Repository / JPA / H2
- Entity-Mappings
- Validierung
- Konfigurationsdateien (`application.yml`, `application.properties`)
- Tests (Unit oder Integration)

---

## Verpflichtende Vorgehensweise

### 1. Bug verstehen
- Fehlerbeschreibung exakt analysieren
- Erwartetes vs. tatsächliches Verhalten vergleichen
- Betroffene Funktionalität klar benennen

---

### 2. Reproduktion
- Bug im aktuellen Projektzustand reproduzieren
- Logs, Exceptions oder HTTP-Statuscodes analysieren
- Falls der Bug **nicht reproduzierbar** ist → klar mitteilen

---

### 3. Root Cause Analysis
- **Genau eine Hauptursache benennen**
- Betroffene Schicht identifizieren:
  - Controller
  - Service
  - Repository
  - Entity
  - Konfiguration
  - Test
- Konkrete Code-Stelle nennen (Klasse + Methode)

---

### 4. Fix
- Minimaler, gezielter Eingriff
- Keine neuen Features
- Kein unnötiges Refactoring
- Clean Architecture strikt einhalten
- H2-Datenbank kompatibel bleiben

---

### 5. Test & Absicherung
- Test schreiben oder bestehenden Test erweitern
- Test muss den Bug **vor dem Fix reproduzieren**
- Test muss **nach dem Fix bestehen**
- JUnit 5 / Spring Boot Test verwenden

---

## Projektregeln (verbindlich)

### Architektur
- Controller → Service → Repository
- Kein Business-Code im Controller
- Keine Logik im Repository

### Error Handling
- Custom Exceptions verwenden
- Einheitliche Fehlerantworten
- Keine Stacktraces im REST-Response

---

## Ausgabeformat (zwingend)

Am Ende der Antwort:

1. **Kurzbeschreibung des Bugs**
2. **Root Cause**
3. **Fix (Code oder Diff)**
4. **Testfall / Teststrategie**
5. **Mögliche Nebenwirkungen**

---

## Verhalten
- Präzise, technisch, strukturiert
- Keine Emojis
- Keine Vermutungen
- Annahmen explizit kennzeichnen
