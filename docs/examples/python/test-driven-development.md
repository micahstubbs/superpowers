# Test-Driven Development - Python Examples

## Example 1: Testing a Function

**Test (tests/test_math.py):**

```python
import pytest
from src.math import add

def test_add_positive_numbers():
    assert add(2, 3) == 5

def test_add_negative_numbers():
    assert add(-1, 1) == 0

def test_add_zero():
    assert add(5, 0) == 5
```

**Run test (should fail):**
```bash
pytest tests/test_math.py
# Expected: ModuleNotFoundError: No module named 'src.math'
```

**Implementation (src/math.py):**

```python
def add(a: int, b: int) -> int:
    return a + b
```

**Run test (should pass):**
```bash
pytest tests/test_math.py
# Expected: 3 passed
```

## Example 2: Testing a Class

**Test (tests/test_user.py):**

```python
import pytest
from src.user import User, UserRepository

def test_user_creation():
    user = User(name="Alice", email="alice@example.com")
    assert user.name == "Alice"
    assert user.email == "alice@example.com"
    assert user.id is None

def test_repository_save():
    repo = UserRepository()
    user = User(name="Bob", email="bob@example.com")

    saved = repo.save(user)

    assert saved.id is not None
    assert saved.name == "Bob"

def test_repository_find_by_id():
    repo = UserRepository()
    user = repo.save(User(name="Charlie", email="charlie@example.com"))

    found = repo.find_by_id(user.id)

    assert found is not None
    assert found.name == "Charlie"

def test_repository_find_by_id_not_found():
    repo = UserRepository()
    assert repo.find_by_id(999) is None
```

**Run test (should fail):**
```bash
pytest tests/test_user.py
# Expected: ModuleNotFoundError: No module named 'src.user'
```

**Implementation (src/user.py):**

```python
from dataclasses import dataclass
from typing import Optional

@dataclass
class User:
    name: str
    email: str
    id: Optional[int] = None

class UserRepository:
    def __init__(self):
        self._users = {}
        self._next_id = 1

    def save(self, user: User) -> User:
        user.id = self._next_id
        self._users[user.id] = user
        self._next_id += 1
        return user

    def find_by_id(self, user_id: int) -> Optional[User]:
        return self._users.get(user_id)
```

**Run test (should pass):**
```bash
pytest tests/test_user.py
# Expected: 4 passed
```
