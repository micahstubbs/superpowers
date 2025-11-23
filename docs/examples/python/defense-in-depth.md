# Defense-in-Depth - Python Examples

## Layer 1: API Input Validation

```python
# api/users.py
from flask import Flask, request, jsonify
from pydantic import BaseModel, EmailStr, Field, ValidationError

class CreateUserRequest(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    age: int = Field(ge=0, le=150, default=None)

@app.route('/users', methods=['POST'])
def create_user():
    try:
        # Layer 1: Validate at entry point
        data = CreateUserRequest(**request.json)
    except ValidationError as e:
        return jsonify({'error': e.errors()}), 400

    user = user_service.create(data.dict())
    return jsonify(user), 201
```

## Layer 2: Service-Level Validation

```python
# services/user_service.py
from typing import Dict, Any
import re

class UserService:
    def create(self, data: Dict[str, Any]) -> Dict[str, Any]:
        # Layer 2: Business rule validation
        if not self._is_valid_email(data['email']):
            raise ValueError('Invalid email format')

        if self._email_exists(data['email']):
            raise ValueError('Email already registered')

        return self.repository.save(data)

    def _is_valid_email(self, email: str) -> bool:
        pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
        return re.match(pattern, email) is not None

    def _email_exists(self, email: str) -> bool:
        return self.repository.find_by_email(email) is not None
```

## Layer 3: Repository-Level Validation

```python
# repositories/user_repository.py
from typing import Dict, Any

class UserRepository:
    def save(self, data: Dict[str, Any]) -> Dict[str, Any]:
        # Layer 3: Data integrity validation
        if not data.get('name') or not data.get('email'):
            raise ValueError('Name and email are required')

        if len(data['name']) > 100:
            raise ValueError('Name too long')

        # Save to database
        user = self.db.users.insert_one(data)
        return {**data, 'id': user.inserted_id}
```

## Why Three Layers?

**Scenario:** Flask validation gets bypassed

```python
# Direct call to service (e.g., from background job)
user_service.create({'name': 'Alice'})  # Missing email!
```

**Result:**
- Layer 2 would catch missing email (if it checks)
- Layer 3 definitely catches it: `ValueError('Name and email are required')`

**Single-layer validation:** Background jobs could create invalid data.
**Defense-in-depth:** Invalid data is impossible.
