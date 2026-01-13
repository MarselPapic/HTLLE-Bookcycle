---
name: User Story
about: New feature or user-facing requirement
title: "[FEATURE] "
labels: ["feature", "user-story"]
assignees: []
---

## User Story
**As a** [user/admin/system]  
**I want to** [action]  
**So that** [business value]

---

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
- [ ] Criterion 4
- [ ] Criterion 5

---

## Technical Details

### Affected Components
- [ ] Backend (Spring Boot API)
- [ ] Web Frontend (Spring Web MVC)
- [ ] Admin Frontend (Flutter)
- [ ] Infrastructure

### Architecture Considerations
<!-- Any special architectural patterns or decisions -->

---

## Definition of Done
- [ ] Code in feature branch
- [ ] Unit tests written (80%+ coverage)
- [ ] Integration tests written (if applicable)
- [ ] Architecture checklist completed
- [ ] Code review approved
- [ ] Documentation updated
- [ ] Tested in staging environment

---

## Task Breakdown

### Backend Tasks
- [ ] Task 1: [Description]
- [ ] Task 2: [Description]

**Estimation:** [X hours]

### Web Frontend Tasks
- [ ] Task 1: [Description]
- [ ] Task 2: [Description]

**Estimation:** [X hours]

### Admin Frontend Tasks
- [ ] Task 1: [Description]
- [ ] Task 2: [Description]

**Estimation:** [X hours]

**Total Estimation:** [Story Points] (Fibonacci: 1,2,3,5,8,13)

---

## Dependencies
<!-- Any other features/issues this depends on -->
- Depends on: #[issue-number]
- Blocks: #[issue-number]

---

## Testing Strategy

### Unit Tests
```java
// Example test structure
class [Feature]Test {
    @Test
    void should[Expected]When[Condition]() {
        // Arrange
        // Act
        // Assert
    }
}
```

### Acceptance Tests
```gherkin
Feature: [Feature Name]
  Scenario: [Scenario 1]
    Given [precondition]
    When [action]
    Then [expected result]
```

---

## Acceptance
- [ ] Stakeholder sign-off
- [ ] Performance acceptable
- [ ] No regressions
- [ ] Production-ready

---

## Related Issues
- Epic: #[issue-number]
- Related: #[issue-number]
