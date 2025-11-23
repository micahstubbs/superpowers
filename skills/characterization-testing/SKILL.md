---
name: characterization-testing
description: Use when working with legacy code or code you don't understand - captures actual behavior before refactoring
---

# Characterization Testing

## When to Use

- Working with legacy code
- Code with no tests
- Code you don't understand
- Before refactoring unclear code
- When documentation is missing or wrong

**Don't use when:**
- Code already has good tests
- You wrote the code recently
- Behavior is well-documented and simple

## The Problem

**Scenario:**
```
Boss: "Fix the bug in the report generator"
You: *reads 500 lines of undocumented code*
You: "I have no idea what this is supposed to do"
```

**Traditional approach:**
1. Read code, try to understand
2. Make change
3. Hope nothing breaks
4. 🔥 Production fire 🔥

**Characterization testing approach:**
1. Write tests that capture current behavior
2. Now you know what it does
3. Make change
4. Tests tell you what broke
5. Fix intentionally

## Process

### Step 1: Identify Behavior Surface

**Find the entry points:**

```python
# What are the public methods/functions?
class ReportGenerator:
    def generate(self, data, format='pdf'):  # ← Entry point
        ...

    def _internal_helper(self):  # ← Not an entry point (private)
        ...
```

**List them:**
- `generate(data, format='pdf')`
- `generate(data, format='html')`
- `generate(data, format='csv')`

### Step 2: Capture Current Behavior

**Write tests for what it currently does (not what it should do):**

```python
# tests/test_report_generator.py
def test_generate_pdf_with_simple_data():
    generator = ReportGenerator()
    data = [{'name': 'Alice', 'score': 100}]

    result = generator.generate(data, format='pdf')

    # Capture whatever it actually returns
    assert result.startswith(b'%PDF-1.4')
    assert b'Alice' in result
    assert b'100' in result

def test_generate_with_empty_data():
    generator = ReportGenerator()

    # What does it actually do with empty data?
    result = generator.generate([], format='pdf')

    # Maybe it returns empty PDF, maybe it crashes?
    # Write test for actual behavior
    assert result == b''  # Or whatever it actually does

def test_generate_html_escapes_input():
    generator = ReportGenerator()
    data = [{'name': '<script>alert("xss")</script>'}]

    result = generator.generate(data, format='html')

    # Does it escape HTML? Let's find out!
    # This test captures the actual behavior
    assert '<script>' not in result  # If this fails, we found a bug!

def test_generate_csv_with_quotes():
    generator = ReportGenerator()
    data = [{'name': 'Alice "Awesome" Anderson'}]

    result = generator.generate(data, format='csv')

    # Capture actual quoting behavior
    assert '"Alice ""Awesome"" Anderson"' in result
```

### Step 3: Run Tests and Record Results

```bash
pytest tests/test_report_generator.py -v
```

**If test fails:**
- Good! You learned something about the actual behavior
- Update test to match actual behavior
- Add comment explaining unexpected behavior

**Example:**

```python
def test_generate_with_none_data():
    generator = ReportGenerator()

    # Expected: would raise exception
    # Actual: returns empty string (weird but that's what it does)
    result = generator.generate(None, format='pdf')

    assert result == b''  # TODO: Should this raise an exception instead?
```

### Step 4: You Now Understand the Code

**Before characterization tests:**
- "I have no idea what this does"

**After characterization tests:**
- "It generates PDF/HTML/CSV reports"
- "It doesn't validate input (accepts None)"
- "HTML output doesn't escape user input (XSS vulnerability!)"
- "CSV output properly quotes values"
- "Empty data returns empty bytes"

### Step 5: Make Changes Safely

**Now you can refactor/fix bugs with confidence:**

```python
# Fix the XSS vulnerability
def generate(self, data, format='pdf'):
    if format == 'html':
        data = self._escape_html(data)  # New code
    ...
```

**Run tests:**
```bash
pytest tests/test_report_generator.py -v
```

**If tests pass:**
- ✅ Change preserved existing behavior
- ✅ (except the XSS bug you intentionally fixed)

**If tests fail:**
- ⚠️ Change broke something unexpected
- Read the failure to understand what changed
- Decide if that's intentional or a bug

## Examples

### Example 1: Unknown Function

```javascript
// What does this do?
function processOrder(order) {
    const result = {};
    if (order.items) {
        result.total = order.items.reduce((s, i) => s + (i.price * i.qty), 0);
    }
    if (order.discount) {
        result.total *= (1 - order.discount);
    }
    if (result.total > 1000) {
        result.shipping = 0;
    } else {
        result.shipping = 10;
    }
    return result;
}
```

**Characterization tests:**

```javascript
test('calculates total from items', () => {
    const result = processOrder({
        items: [
            { price: 10, qty: 2 },
            { price: 5, qty: 3 }
        ]
    });
    expect(result.total).toBe(35);
});

test('applies discount to total', () => {
    const result = processOrder({
        items: [{ price: 100, qty: 1 }],
        discount: 0.1
    });
    expect(result.total).toBe(90);
});

test('free shipping over 1000', () => {
    const result = processOrder({
        items: [{ price: 1001, qty: 1 }]
    });
    expect(result.shipping).toBe(0);
});

test('10 dollar shipping under 1000', () => {
    const result = processOrder({
        items: [{ price: 999, qty: 1 }]
    });
    expect(result.shipping).toBe(10);
});

test('handles missing items', () => {
    const result = processOrder({});
    // Actual behavior: total is undefined, shipping still calculated
    expect(result.total).toBeUndefined();
    expect(result.shipping).toBe(10);  // Bug? Should maybe throw error?
});
```

**Now you understand:**
- Calculates total from items
- Applies discount
- Free shipping >$1000, $10 otherwise
- Bug: undefined total when no items (should probably be 0 or throw error)

### Example 2: Legacy API

```python
# Legacy authentication function - unclear behavior
def authenticate_user(username, password, session):
    user = db.query(User).filter_by(username=username).first()
    if user and user.password == password:
        session['user_id'] = user.id
        user.last_login = datetime.now()
        db.commit()
        return True
    return False
```

**Characterization tests:**

```python
def test_authenticate_valid_user(db_session):
    user = User(username='alice', password='secret123')
    db_session.add(user)
    db_session.commit()
    session = {}

    result = authenticate_user('alice', 'secret123', session)

    assert result is True
    assert session['user_id'] == user.id
    assert user.last_login is not None

def test_authenticate_invalid_password(db_session):
    user = User(username='alice', password='secret123')
    db_session.add(user)
    db_session.commit()
    session = {}

    result = authenticate_user('alice', 'wrong', session)

    assert result is False
    assert 'user_id' not in session
    # Captures actual behavior: last_login NOT updated on failure
    assert user.last_login is None

def test_authenticate_nonexistent_user():
    session = {}

    result = authenticate_user('nobody', 'anything', session)

    assert result is False
    assert 'user_id' not in session

def test_authenticate_stores_plaintext_password():
    # This test captures a security vulnerability!
    user = User(username='alice', password='secret123')

    # Actual behavior: passwords stored in plaintext
    assert user.password == 'secret123'  # SECURITY BUG!
```

**Discovered:**
- Valid credentials → sets session, updates last_login
- Invalid credentials → doesn't set session, doesn't update last_login
- **SECURITY BUG:** Passwords stored in plaintext!

**Now you can fix safely:**

```python
# Add password hashing
def authenticate_user(username, password, session):
    user = db.query(User).filter_by(username=username).first()
    if user and verify_password(password, user.password_hash):  # Changed
        session['user_id'] = user.id
        user.last_login = datetime.now()
        db.commit()
        return True
    return False
```

**Update characterization test:**

```python
def test_authenticate_hashes_password():
    user = User(username='alice')
    user.set_password('secret123')  # New helper method

    # New behavior: passwords are hashed
    assert user.password_hash != 'secret123'
    assert user.password_hash.startswith('$2b$')  # bcrypt hash
```

## Anti-Patterns

**DON'T:**
- ❌ Write tests for what the code "should" do
- ❌ Skip weird behaviors ("I'll fix that later")
- ❌ Mock everything (you need real behavior)
- ❌ Assume the code is correct

**DO:**
- ✅ Write tests for what the code actually does
- ✅ Capture weird behaviors explicitly
- ✅ Use real dependencies when possible
- ✅ Treat unexpected behavior as discoveries

## When You're Done

You should be able to answer:
- What are the entry points?
- What are valid inputs?
- What does it return for each input type?
- What are the side effects?
- What are the edge cases?
- What are the bugs?

**If you can't answer these, write more characterization tests.**

## Integration with Other Skills

**After characterization testing:**
- Use @superpowers:systematic-debugging to fix discovered bugs
- Use @superpowers:strangler-fig-pattern to refactor safely
- Use @superpowers:test-driven-development for new features

**Before refactoring:**
- Always write characterization tests first
- Then refactor
- Tests tell you what broke
