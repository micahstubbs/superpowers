# Defense-in-Depth - TypeScript Examples

## Layer 1: API Input Validation

```typescript
// src/api/users.ts
import { z } from 'zod';

const CreateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150).optional(),
});

app.post('/users', async (req, res) => {
  // Layer 1: Validate at entry point
  const result = CreateUserSchema.safeParse(req.body);

  if (!result.success) {
    return res.status(400).json({ error: result.error });
  }

  const user = await userService.create(result.data);
  res.status(201).json(user);
});
```

## Layer 2: Service-Level Validation

```typescript
// src/services/user-service.ts
type CreateUserData = {
  name: string;
  email: string;
  age?: number;
};

class UserService {
  async create(data: CreateUserData): Promise<User> {
    // Layer 2: Business rule validation
    if (!this.isValidEmail(data.email)) {
      throw new Error('Invalid email format');
    }

    if (await this.emailExists(data.email)) {
      throw new Error('Email already registered');
    }

    return this.repository.save(data);
  }

  private isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  private async emailExists(email: string): Promise<boolean> {
    return (await this.repository.findByEmail(email)) !== null;
  }
}
```

## Layer 3: Repository-Level Validation

```typescript
// src/repositories/user-repository.ts
class UserRepository {
  async save(data: CreateUserData): Promise<User> {
    // Layer 3: Data integrity validation
    if (!data.name || !data.email) {
      throw new Error('Name and email are required');
    }

    if (data.name.length > 100) {
      throw new Error('Name too long');
    }

    // Save to database
    const user = await db.users.create({ data });
    return user;
  }
}
```

## Why Three Layers?

**Scenario:** API validation gets disabled during debugging

```typescript
// Someone comments out validation temporarily
// app.post('/users', async (req, res) => {
//   const result = CreateUserSchema.safeParse(req.body);
//   ...
// });
app.post('/users', async (req, res) => {
  const user = await userService.create(req.body);
  res.json(user);
});
```

**Result:** Service-level and repository-level validation still prevent invalid data!

- Layer 2 catches: duplicate emails, business rule violations
- Layer 3 catches: missing required fields, data integrity issues

**Single-layer validation:** Bug would reach production.
**Defense-in-depth:** Bug is contained.
