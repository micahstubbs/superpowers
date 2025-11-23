# Test-Driven Development - Go Examples

## Example 1: Testing a Function

**Test (math_test.go):**

```go
package math

import "testing"

func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, 1, 0},
        {"with zero", 5, 0, 5},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.want {
                t.Errorf("Add(%d, %d) = %d; want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

**Run test (should fail):**
```bash
go test -v
# Expected: undefined: Add
```

**Implementation (math.go):**

```go
package math

func Add(a, b int) int {
    return a + b
}
```

**Run test (should pass):**
```bash
go test -v
# Expected: PASS
```

## Example 2: Testing with Dependencies

**Test (user_test.go):**

```go
package user

import (
    "testing"
)

func TestUserCreation(t *testing.T) {
    u := User{Name: "Alice", Email: "alice@example.com"}

    if u.Name != "Alice" {
        t.Errorf("expected Name=Alice, got %s", u.Name)
    }
    if u.Email != "alice@example.com" {
        t.Errorf("expected Email=alice@example.com, got %s", u.Email)
    }
}

func TestRepositorySave(t *testing.T) {
    repo := NewRepository()
    u := &User{Name: "Bob", Email: "bob@example.com"}

    saved, err := repo.Save(u)
    if err != nil {
        t.Fatalf("Save failed: %v", err)
    }

    if saved.ID == 0 {
        t.Error("expected ID to be set")
    }
    if saved.Name != "Bob" {
        t.Errorf("expected Name=Bob, got %s", saved.Name)
    }
}

func TestRepositoryFindByID(t *testing.T) {
    repo := NewRepository()
    u := &User{Name: "Charlie", Email: "charlie@example.com"}

    saved, _ := repo.Save(u)
    found, err := repo.FindByID(saved.ID)

    if err != nil {
        t.Fatalf("FindByID failed: %v", err)
    }
    if found.Name != "Charlie" {
        t.Errorf("expected Name=Charlie, got %s", found.Name)
    }
}

func TestRepositoryFindByIDNotFound(t *testing.T) {
    repo := NewRepository()

    _, err := repo.FindByID(999)
    if err == nil {
        t.Error("expected error for non-existent ID")
    }
}
```

**Run test (should fail):**
```bash
go test -v
# Expected: undefined: User, Repository
```

**Implementation (user.go):**

```go
package user

import "errors"

type User struct {
    ID    int
    Name  string
    Email string
}

type Repository struct {
    users  map[int]*User
    nextID int
}

func NewRepository() *Repository {
    return &Repository{
        users:  make(map[int]*User),
        nextID: 1,
    }
}

func (r *Repository) Save(u *User) (*User, error) {
    u.ID = r.nextID
    r.users[u.ID] = u
    r.nextID++
    return u, nil
}

func (r *Repository) FindByID(id int) (*User, error) {
    u, ok := r.users[id]
    if !ok {
        return nil, errors.New("user not found")
    }
    return u, nil
}
```

**Run test (should pass):**
```bash
go test -v
# Expected: PASS
```
