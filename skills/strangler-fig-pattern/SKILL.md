---
name: strangler-fig-pattern
description: Use when refactoring large legacy systems - incrementally replace old code with new code without a big-bang rewrite
---

# Strangler Fig Pattern

## When to Use

- Refactoring large legacy systems
- Replacing outdated frameworks
- Modernizing monoliths
- Risk-averse rewrites
- Can't afford downtime

**Don't use when:**
- Small, well-tested codebase (just refactor directly)
- Complete rewrite is actually necessary
- Old and new systems can't coexist

## The Problem

**Big-Bang Rewrite:**
```
Month 1-6: Build new system
Month 7: "Big switch" to new system
Month 8: 🔥 Everything is broken 🔥
```

**Strangler Fig Pattern:**
```
Month 1: Replace 10% of system
Month 2: Replace another 10%
...
Month 10: Old system completely replaced
Each month: Working system in production
```

## The Pattern

Like a strangler fig tree that grows around a host tree and eventually replaces it, incrementally replace old code with new code.

### Step 1: Identify a Strangleable Component

**Good candidates:**
- Isolated feature or module
- Clear boundaries
- Can run in parallel with old code

**Bad candidates:**
- Core infrastructure everything depends on
- Tightly coupled to entire system
- No clear boundaries

**Example:**
```
✅ Good: User authentication module
✅ Good: Reporting system
✅ Good: Search functionality
❌ Bad: Database layer
❌ Bad: Request routing
❌ Bad: Logging infrastructure
```

### Step 2: Create an Abstraction Layer

**Add an interface that can route to old or new implementation:**

```python
# abstraction_layer.py
class ReportGenerator:
    def __init__(self):
        self.old_generator = LegacyReportGenerator()
        self.new_generator = None  # Will be added incrementally

    def generate(self, data, format='pdf'):
        # Feature flag: control rollout
        if should_use_new_generator(format):
            return self.new_generator.generate(data, format)
        else:
            return self.old_generator.generate(data, format)

def should_use_new_generator(format):
    # Start with 0%, gradually increase
    rollout_percentage = get_rollout_percentage('new_report_generator')
    return random.random() < rollout_percentage
```

**All code now uses abstraction layer:**

```python
# Before
from legacy_reports import LegacyReportGenerator
generator = LegacyReportGenerator()
report = generator.generate(data)

# After
from abstraction_layer import ReportGenerator
generator = ReportGenerator()
report = generator.generate(data)  # Routes to old or new
```

### Step 3: Implement New Version for One Use Case

**Start small:**

```python
# new_report_generator.py
class ModernReportGenerator:
    def generate(self, data, format='pdf'):
        if format == 'pdf':
            return self._generate_pdf(data)
        else:
            raise NotImplementedError(f"Format {format} not yet supported")

    def _generate_pdf(self, data):
        # New, clean implementation for PDF only
        ...
```

**Update abstraction layer:**

```python
class ReportGenerator:
    def __init__(self):
        self.old_generator = LegacyReportGenerator()
        self.new_generator = ModernReportGenerator()

    def generate(self, data, format='pdf'):
        # Only use new generator for PDF format, others still use old
        if format == 'pdf' and should_use_new_generator(format):
            return self.new_generator.generate(data, format)
        else:
            return self.old_generator.generate(data, format)
```

### Step 4: Gradual Rollout

**Week 1: 1% of PDF reports use new generator**

```python
def should_use_new_generator(format):
    if format == 'pdf':
        return random.random() < 0.01  # 1%
    return False
```

**Monitor:** Errors, performance, user feedback

**Week 2: If successful, increase to 10%**

```python
def should_use_new_generator(format):
    if format == 'pdf':
        return random.random() < 0.10  # 10%
    return False
```

**Week 3: 50%**
**Week 4: 100%**

```python
def should_use_new_generator(format):
    if format == 'pdf':
        return True  # 100%
    return False
```

### Step 5: Repeat for Next Use Case

**Now implement HTML format:**

```python
class ModernReportGenerator:
    def generate(self, data, format='pdf'):
        if format == 'pdf':
            return self._generate_pdf(data)
        elif format == 'html':
            return self._generate_html(data)  # New
        else:
            raise NotImplementedError(f"Format {format} not yet supported")
```

**Gradual rollout again:**

```python
def should_use_new_generator(format):
    if format == 'pdf':
        return True  # PDF fully migrated
    elif format == 'html':
        return random.random() < 0.01  # Start HTML at 1%
    return False
```

### Step 6: Remove Old Implementation

**Once all use cases migrated and stable:**

```python
# Remove abstraction layer
class ReportGenerator:
    def generate(self, data, format='pdf'):
        # Old implementation completely removed
        return ModernReportGenerator().generate(data, format)

# Eventually: Remove abstraction layer entirely, use ModernReportGenerator directly
```

**Delete legacy code:**

```bash
git rm legacy_reports.py
git commit -m "refactor: remove legacy report generator

All use cases migrated to ModernReportGenerator.
"
```

## Complete Example: Authentication Migration

### Phase 1: Add Abstraction

```python
# auth.py
class AuthService:
    def __init__(self):
        self.old_auth = LegacySessionAuth()
        self.new_auth = ModernJWTAuth()

    def authenticate(self, username, password):
        # Route based on user flag
        user = get_user(username)
        if user and user.use_jwt_auth:
            return self.new_auth.authenticate(username, password)
        else:
            return self.old_auth.authenticate(username, password)
```

### Phase 2: Implement New Auth (JWT)

```python
# modern_jwt_auth.py
class ModernJWTAuth:
    def authenticate(self, username, password):
        user = db.query(User).filter_by(username=username).first()
        if user and verify_password(password, user.password_hash):
            token = create_jwt_token(user.id)
            return {'token': token, 'user': user}
        return None
```

### Phase 3: Gradual Migration

**Week 1: Opt-in beta**

```python
# Only users who explicitly opted in
if user.beta_tester:
    user.use_jwt_auth = True
```

**Week 2: New users**

```python
# All newly registered users
if user.created_at > datetime(2025, 11, 1):
    user.use_jwt_auth = True
```

**Week 3: 10% of existing users**

```python
if hash(user.id) % 100 < 10:
    user.use_jwt_auth = True
```

**Week 4-8: Gradual increase to 100%**

**Week 9: All users on JWT**

### Phase 4: Remove Old System

```python
# auth.py - simplified
class AuthService:
    def authenticate(self, username, password):
        return ModernJWTAuth().authenticate(username, password)
```

```bash
git rm legacy_session_auth.py
git commit -m "refactor: remove legacy session auth

All users migrated to JWT authentication.
"
```

## Benefits

**Vs. Big-Bang Rewrite:**

| Big-Bang | Strangler Fig |
|----------|---------------|
| All-or-nothing | Incremental |
| High risk | Low risk |
| Long development, no releases | Continuous releases |
| Users get everything at once | Users get gradual improvements |
| Rollback = disaster | Rollback = adjust percentage |
| Hard to test everything | Test each piece thoroughly |

## Rollback Strategy

**If new implementation has issues:**

```python
# Immediate rollback
def should_use_new_generator(format):
    return False  # Back to 0% instantly
```

**Or partial rollback:**

```python
# Roll back from 50% to 10% while investigating
def should_use_new_generator(format):
    return random.random() < 0.10
```

**Big-bang rewrite:** Rollback means reverting entire deployment, losing weeks of work.

**Strangler fig:** Rollback means changing a percentage. Old code still there.

## Anti-Patterns

**DON'T:**
- ❌ Build entire new system before strangling
- ❌ Skip the abstraction layer
- ❌ Go 0% → 100% in one step
- ❌ Forget to monitor during rollout
- ❌ Leave abstraction layer forever

**DO:**
- ✅ Strangle one small piece at a time
- ✅ Always have working system in production
- ✅ Monitor each rollout percentage
- ✅ Keep old and new implementations simple
- ✅ Remove old code once migration complete

## Integration with Other Skills

**Use with:**
- @superpowers:characterization-testing - Test old behavior before strangling
- @superpowers:test-driven-development - Build new implementation with tests
- @superpowers:verification-before-completion - Verify each rollout percentage

**Workflow:**

1. Use @characterization-testing on legacy component
2. Use @writing-plans to plan strangler fig migration
3. Use @test-driven-development for new implementation
4. Implement abstraction layer
5. Gradual rollout with monitoring
6. Use @verification-before-completion at each percentage
7. Remove old code

## Success Criteria

You successfully used strangler fig pattern when:

- [ ] Old system never completely turned off until 100% migrated
- [ ] Each increment delivered working software to production
- [ ] Rollback was always possible
- [ ] Old code was eventually removed
- [ ] Users experienced gradual improvement, not disruption
