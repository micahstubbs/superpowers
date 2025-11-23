# Defense-in-Depth - Go Examples

## Layer 1: API Input Validation

```go
// api/handlers.go
package api

import (
    "encoding/json"
    "net/http"
    "github.com/go-playground/validator/v10"
)

type CreateUserRequest struct {
    Name  string `json:"name" validate:"required,min=1,max=100"`
    Email string `json:"email" validate:"required,email"`
    Age   *int   `json:"age" validate:"omitempty,min=0,max=150"`
}

var validate = validator.New()

func (h *Handler) CreateUser(w http.ResponseWriter, r *http.Request) {
    var req CreateUserRequest

    // Layer 1: Validate at entry point
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    if err := validate.Struct(req); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    user, err := h.service.Create(req.Name, req.Email, req.Age)
    if err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    json.NewEncoder(w).Encode(user)
}
```

## Layer 2: Service-Level Validation

```go
// service/user_service.go
package service

import (
    "errors"
    "regexp"
)

type UserService struct {
    repo Repository
}

func (s *UserService) Create(name, email string, age *int) (*User, error) {
    // Layer 2: Business rule validation
    if !isValidEmail(email) {
        return nil, errors.New("invalid email format")
    }

    exists, err := s.repo.EmailExists(email)
    if err != nil {
        return nil, err
    }
    if exists {
        return nil, errors.New("email already registered")
    }

    return s.repo.Save(name, email, age)
}

func isValidEmail(email string) bool {
    re := regexp.MustCompile(`^[^\s@]+@[^\s@]+\.[^\s@]+$`)
    return re.MatchString(email)
}
```

## Layer 3: Repository-Level Validation

```go
// repository/user_repository.go
package repository

import "errors"

type UserRepository struct {
    db *sql.DB
}

func (r *UserRepository) Save(name, email string, age *int) (*User, error) {
    // Layer 3: Data integrity validation
    if name == "" || email == "" {
        return nil, errors.New("name and email are required")
    }

    if len(name) > 100 {
        return nil, errors.New("name too long")
    }

    // Save to database
    result, err := r.db.Exec(
        "INSERT INTO users (name, email, age) VALUES (?, ?, ?)",
        name, email, age,
    )
    if err != nil {
        return nil, err
    }

    id, _ := result.LastInsertId()
    return &User{ID: int(id), Name: name, Email: email, Age: age}, nil
}
```

## Why Three Layers?

**Scenario:** Handler validation gets refactored incorrectly

```go
func (h *Handler) CreateUser(w http.ResponseWriter, r *http.Request) {
    var req CreateUserRequest
    json.NewDecoder(r.Body).Decode(&req)

    // Validation accidentally removed during refactor!
    user, _ := h.service.Create(req.Name, req.Email, req.Age)
    json.NewEncoder(w).Encode(user)
}
```

**Result:**
- Layer 2 catches: invalid email format, duplicate emails
- Layer 3 catches: missing required fields, length violations

**Single-layer validation:** Refactoring bug reaches production.
**Defense-in-depth:** Bug is contained.
