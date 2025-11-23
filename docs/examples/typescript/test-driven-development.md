# Test-Driven Development - TypeScript Examples

## Example 1: Testing a Function

**Test (tests/math.test.ts):**

```typescript
import { describe, it, expect } from 'vitest';
import { add } from '../src/math';

describe('add', () => {
  it('adds two numbers', () => {
    expect(add(2, 3)).toBe(5);
  });

  it('handles negative numbers', () => {
    expect(add(-1, 1)).toBe(0);
  });
});
```

**Run test (should fail):**
```bash
npm test -- math.test.ts
# Expected: Error: Cannot find module '../src/math'
```

**Implementation (src/math.ts):**

```typescript
export function add(a: number, b: number): number {
  return a + b;
}
```

**Run test (should pass):**
```bash
npm test -- math.test.ts
# Expected: ✓ 2 tests passed
```

## Example 2: Testing an API Endpoint

**Test (tests/api.test.ts):**

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { app, server } from '../src/app';

describe('POST /users', () => {
  afterAll(() => server.close());

  it('creates a new user', async () => {
    const response = await request(app)
      .post('/users')
      .send({ name: 'Alice', email: 'alice@example.com' });

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      name: 'Alice',
      email: 'alice@example.com'
    });
    expect(response.body.id).toBeDefined();
  });

  it('validates required fields', async () => {
    const response = await request(app)
      .post('/users')
      .send({ name: 'Bob' });

    expect(response.status).toBe(400);
    expect(response.body.error).toContain('email');
  });
});
```

**Run test (should fail):**
```bash
npm test -- api.test.ts
# Expected: Error: Cannot find module '../src/app'
```

**Implementation (src/app.ts):**

```typescript
import express from 'express';

export const app = express();
app.use(express.json());

const users: Array<{id: number, name: string, email: string}> = [];
let nextId = 1;

app.post('/users', (req, res) => {
  const { name, email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'email is required' });
  }

  const user = { id: nextId++, name, email };
  users.push(user);
  res.status(201).json(user);
});

export const server = app.listen(3000);
```

**Run test (should pass):**
```bash
npm test -- api.test.ts
# Expected: ✓ 2 tests passed
```
