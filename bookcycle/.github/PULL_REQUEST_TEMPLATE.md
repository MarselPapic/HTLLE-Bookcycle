## Description
<!-- Brief description of what this PR changes -->

---

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Infrastructure / CI-CD change
- [ ] Documentation update

---

## Related Issues
Closes: #[issue-number]  
Related to: #[issue-number]

---

## Changes Made

### Backend (Spring Boot)
- [ ] Entity/Model changes
- [ ] Repository/Query changes
- [ ] Service layer changes
- [ ] REST Controller changes
- [ ] Exception handling changes
- [ ] Configuration changes

**Summary:**
- Change 1
- Change 2
- Change 3

### Web Frontend (Spring Web MVC)
- [ ] Controller changes
- [ ] Template (Thymeleaf) changes
- [ ] Form handling changes
- [ ] CSS/Styling changes
- [ ] Error page updates

**Summary:**
- Change 1
- Change 2

### Admin Frontend (Flutter)
- [ ] Widget changes
- [ ] State management (Riverpod) changes
- [ ] API integration changes
- [ ] Error handling changes

**Summary:**
- Change 1
- Change 2

---

## Testing

### Unit Tests
- [ ] New tests added
- [ ] Existing tests updated
- [ ] All tests passing locally
- [ ] Test coverage: [X%]

```bash
# Test commands executed
mvn test
flutter test
```

### Integration Tests
- [ ] Integration tests added
- [ ] Database tests passing (H2 in-memory)
- [ ] API contract tests passing

### Manual Testing
- [ ] Tested locally
- [ ] Tested in different browsers (if UI)
- [ ] Tested error scenarios

**Tested on:**
- OS: [Windows/macOS/Linux]
- Browser: [Chrome/Firefox/Safari]
- Device: [if mobile]

---

## Architecture Review

### Clean Architecture Compliance
- [ ] No business logic in Controller
- [ ] Domain Layer has zero Framework dependencies
- [ ] DTOs used for REST (not Entities)
- [ ] Proper layer separation maintained
- [ ] Service Layer handles @Transactional
- [ ] Custom Exception hierarchy used correctly

### Code Quality
- [ ] Code follows project style guide
- [ ] No hardcoded values or secrets
- [ ] No debug statements (console.log, System.out.println, etc.)
- [ ] Proper logging implemented (DEBUG/INFO/WARN/ERROR)
- [ ] No unnecessary comments (only complex logic documented)

### Performance
- [ ] No N+1 query problems
- [ ] Efficient database queries
- [ ] No memory leaks
- [ ] Pagination implemented (if listing large datasets)

### Security
- [ ] Input validation implemented
- [ ] SQL injection prevention (using parameterized queries)
- [ ] CSRF token handling (if form submission)
- [ ] No sensitive data logged (passwords, tokens, PII)

---

## Breaking Changes
- [ ] Yes, this is a breaking change
- [ ] No breaking changes

If yes, please describe:
```
- API endpoint changed from X to Y
- Request/Response DTO structure changed
- Database schema migration required
```

---

## Deployment

### Database Changes
- [ ] No DB changes required
- [ ] Schema changes (describe below)
- [ ] Migration script provided

**SQL Migration:**
```sql
-- If applicable, include migration scripts
```

### Configuration Changes
- [ ] No config changes
- [ ] Environment variables added (describe below)
- [ ] Application properties updated

**New Properties:**
```properties
new.property=value
```

### Deployment Checklist
- [ ] Can be deployed without downtime
- [ ] Feature flags implemented (if needed)
- [ ] Rollback plan documented
- [ ] Monitoring/alerts configured

---

## Documentation

### Code Documentation
- [ ] Javadoc added (public methods)
- [ ] Complex logic commented
- [ ] README updated (if needed)

### User/Admin Documentation
- [ ] User guide updated (if applicable)
- [ ] API documentation updated (OpenAPI/Swagger)
- [ ] Screenshots/GIFs added (if UI changes)

### Video / Screenshots
<!-- Attach screenshots or screen recordings of UI changes -->

---

## Checklist

### Before Requesting Review
- [ ] Self-reviewed the code
- [ ] Walked through changes logically
- [ ] No console errors/warnings
- [ ] All tests passing
- [ ] Commit messages follow Conventional Commits
- [ ] Branch is up to date with main
- [ ] No merge conflicts

### For Reviewers
- [ ] Code is readable and understandable
- [ ] Architecture decisions are sound
- [ ] Test coverage is adequate
- [ ] Performance is acceptable
- [ ] Security is not compromised
- [ ] Documentation is clear

---

## Reviewers
<!-- Tag reviewers who should review this PR -->
@backend-lead @web-lead @admin-lead

---

## Additional Notes
<!-- Any additional context or concerns -->

---

## Performance Impact
- [ ] No performance impact
- [ ] Performance improved
- [ ] Performance degradation (explain mitigations)

**Metrics (if measured):**
- Endpoint response time: [before] → [after]
- Memory usage: [before] → [after]
- Database queries: [before] → [after]

---

## Migration Guide (if needed)
```
Step 1: Deploy backend
Step 2: Run database migrations
Step 3: Deploy web frontend
Step 4: Deploy admin frontend
Step 5: Verify in production
```

---

**Thank you for contributing to Bookcycle!**
