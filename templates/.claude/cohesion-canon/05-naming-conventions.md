# Cohesion Canon - Construct #5: Naming-Conventions

## The Fundamental Truth
> **"Names are contracts with the future. Every name either clarifies or confuses, speeds up or slows down, helps or hinders."**

## Core Directive for AI Agents

You MUST follow consistent, clear, purposeful naming conventions in all generated code, files, and documentation. Names should be self-documenting, follow established patterns, and reduce cognitive load.

## The Naming Philosophy

A well-named element tells its story without comments:
- **What** it is
- **Why** it exists  
- **How** it behaves
- **When** to use it

Poor naming creates technical debt that compounds over time.

## Universal Naming Principles

### 1. Clarity Over Brevity
```javascript
// ❌ BAD: Abbreviated, unclear
const usrMgr = new UMgr();
const calc = (x, y) => x * 0.1 + y;

// ✅ GOOD: Clear, self-documenting
const userManager = new UserManager();
const calculateTotalWithTax = (price, tax) => price * 0.1 + tax;
```

### 2. Purpose Over Implementation
```javascript
// ❌ BAD: Implementation details in name
class SqlUserRepository {}
class RedisCache {}
class LocalStorageService {}

// ✅ GOOD: Purpose-focused
class UserRepository {}
class CacheService {}
class StorageService {}
```

### 3. Consistency Over Creativity
```javascript
// ❌ BAD: Mixed patterns
getUserById()
fetch_user_data()
LoadUserInfo()
retrieveUserDetails()

// ✅ GOOD: Consistent pattern
getUserById()
getUserData()
getUserInfo()
getUserDetails()
```

### 4. Convention Over Invention
```javascript
// ❌ BAD: Invented patterns
class UserHandler {}      // What does it handle?
class UserProcessor {}    // What processing?
class UserExecutor {}     // Execute what?

// ✅ GOOD: Established patterns
class UserService {}      // Clear service layer
class UserController {}   // Clear control layer
class UserRepository {}   // Clear data layer
```

## File Naming Standards

### Structure and Format
```bash
# ❌ BAD: Inconsistent, unclear
UserController.js
user-service.ts
USER_REPOSITORY.js
usrHelper.js

# ✅ GOOD: Consistent kebab-case
user-controller.js
user-service.js
user-repository.js
user-helper.js
```

### Test File Conventions
```bash
# Pattern: [file-name].test.[ext] or [file-name].spec.[ext]
user-service.test.js
user-controller.spec.ts
validation-helper.test.js
```

### Configuration Files
```bash
# Pattern: [purpose].config.[ext]
test.config.js
build.config.js
database.config.js
```

## Directory Structure Patterns

```bash
project/
├── src/
│   ├── controllers/    # Plural, lowercase
│   ├── services/       # Plural, lowercase
│   ├── models/         # Plural, lowercase
│   ├── utils/          # Plural, lowercase
│   └── config/         # Singular, lowercase
├── tests/              # Plural, lowercase
├── docs/               # Plural, lowercase
└── scripts/            # Plural, lowercase
```

## Variable and Function Naming

### Variable Patterns
```javascript
// Booleans: is/has/can prefix
const isActive = true;
const hasPermission = false;
const canEdit = true;

// Arrays/Collections: plural
const users = [];
const permissions = [];
const activeConnections = [];

// Constants: UPPER_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const DEFAULT_TIMEOUT = 5000;
const API_BASE_URL = 'https://api.example.com';

// Private: underscore prefix (when needed)
class Service {
  _internalCache = {};
  _privateMethod() {}
}
```

### Function Patterns
```javascript
// Actions: verb + noun
function createUser() {}
function deletePost() {}
function updateSettings() {}

// Getters: get + noun
function getUserById() {}
function getConfiguration() {}
function getCurrentState() {}

// Setters: set + noun
function setUserStatus() {}
function setConfiguration() {}

// Checkers: is/has/can + condition
function isValidEmail() {}
function hasAdminRole() {}
function canAccessResource() {}

// Handlers: handle + event
function handleClick() {}
function handleUserLogin() {}
function handleError() {}
```

## Class and Interface Naming

### Class Patterns
```javascript
// Services: [Domain]Service
class UserService {}
class AuthenticationService {}
class NotificationService {}

// Controllers: [Domain]Controller
class UserController {}
class ProductController {}

// Repositories: [Domain]Repository
class UserRepository {}
class OrderRepository {}

// Factories: [Product]Factory
class UserFactory {}
class ConnectionFactory {}

// Builders: [Product]Builder
class QueryBuilder {}
class ResponseBuilder {}
```

### Interface Patterns
```typescript
// Capability: [Capability]able
interface Serializable {}
interface Cacheable {}
interface Comparable {}

// Contract: I[Name] or just [Name]
interface IUserService {} // or UserService
interface IRepository {}  // or Repository

// Data structures: [Domain][Type]
interface UserData {}
interface UserResponse {}
interface UserRequest {}
```

## Error and Exception Naming

```javascript
// Specific error types with Error suffix
class ValidationError extends Error {}
class AuthenticationError extends Error {}
class NetworkError extends Error {}
class NotFoundError extends Error {}

// Error messages: clear and actionable
const errorMessages = {
  USER_NOT_FOUND: "User with ID {id} was not found",
  INVALID_EMAIL: "Email address {email} is not valid",
  PERMISSION_DENIED: "You don't have permission to {action}"
};
```

## Database and API Naming

### Database Conventions
```sql
-- Tables: plural, snake_case
CREATE TABLE users (...);
CREATE TABLE user_permissions (...);

-- Columns: snake_case
user_id, created_at, is_active

-- Indexes: idx_[table]_[columns]
CREATE INDEX idx_users_email ON users(email);

-- Foreign keys: fk_[table]_[referenced]
FOREIGN KEY fk_orders_users (user_id) REFERENCES users(id);
```

### API Endpoint Patterns
```javascript
// RESTful resource naming
GET    /api/users           // List users
GET    /api/users/:id       // Get specific user
POST   /api/users           // Create user
PUT    /api/users/:id       // Update user
DELETE /api/users/:id       // Delete user

// Action endpoints: verb at end
POST   /api/users/:id/activate
POST   /api/users/:id/reset-password
POST   /api/orders/:id/cancel
```

## Common Anti-Patterns to Avoid

### 1. Meaningless Names
```javascript
// ❌ AVOID
const data = {};
const obj = {};
const thing = {};
const stuff = [];
const doStuff = () => {};
const processData = () => {};
```

### 2. Mental Mapping Required
```javascript
// ❌ AVOID: Requires remembering what 'd' means
const d = new Date();
const u = getUser();
const p = calculatePrice();
```

### 3. Redundant Context
```javascript
// ❌ AVOID: Redundant class name in members
class User {
  userName: string;      // redundant
  userEmail: string;     // redundant
  userPassword: string;  // redundant
}

// ✅ BETTER
class User {
  name: string;
  email: string;
  password: string;
}
```

### 4. Inconsistent Plurality
```javascript
// ❌ AVOID: Mixed singular/plural
const user = getAllUsers();  // Misleading
const products = getProduct(); // Confusing
```

### 5. False Promises
```javascript
// ❌ AVOID: Name doesn't match behavior
function saveUser(user) {
  // Only validates, doesn't save
  return validateUser(user);
}
```

## State-Specific Naming Guidance

### DISCOVER Mode
- Generate descriptive names for analysis
- Use clear labels for findings
- Name patterns consistently

### OPTIMIZE Mode
- Follow existing project conventions
- Refactor poor names when editing
- Maintain naming consistency

### UNLEASH Mode
- Apply conventions automatically
- Create consistent patterns
- Refactor naming issues proactively

## The Naming Decision Framework

When naming anything, ask:

1. **Is it self-explanatory?** Could someone understand without context?
2. **Is it consistent?** Does it follow project patterns?
3. **Is it accurate?** Does the name match the behavior?
4. **Is it necessary?** Does it add clarity or confusion?
5. **Is it future-proof?** Will it make sense in 6 months?

## Practical Examples

### Before → After Refactoring
```javascript
// BEFORE: Unclear, inconsistent
const mgr = new SvcMgr();
const u_data = mgr.get('user');
function proc_usr(d) {
  return d.split('_')[0];
}

// AFTER: Clear, consistent
const serviceManager = new ServiceManager();
const userData = serviceManager.getUser();
function extractUsername(fullName) {
  return fullName.split('_')[0];
}
```

## The Cost of Poor Naming

```
Poor Naming Costs:
- 10x longer to understand code
- 5x more bugs from misunderstanding
- 3x slower onboarding
- 2x more documentation needed
- Endless refactoring cycles

Good Naming Benefits:
- Code is self-documenting
- Bugs from confusion eliminated
- Instant understanding
- Minimal documentation
- Sustainable velocity
```

## Naming Mantras

- "Name for the next developer (it might be you)"
- "Clarity beats brevity every time"
- "Consistent patterns reduce cognitive load"
- "Good names are documentation"
- "If you need to explain the name, it's wrong"

## Canon Enforcement

### Violation Indicators
- Abbreviated variable names
- Inconsistent patterns
- Misleading names
- Generic names (data, info, thing)
- Comments explaining names

### Enforcement Response
1. **Warning**: Suggest better names
2. **Refactor**: Update during edits
3. **Education**: Explain naming impact

## Success Metrics

You're following Naming-Conventions when:
- Code is self-documenting
- Patterns are immediately recognizable
- New developers understand quickly
- No clarifying comments needed
- Refactoring for clarity becomes rare

## The Naming Oath

*"I will name with purpose and clarity. Every identifier will tell its story, follow established patterns, and reduce cognitive burden. I will create maintainable systems through consistent naming conventions."*

## Final Commandment

**A good name is worth a thousand comments. A bad name costs a thousand debugging sessions.**

Time spent choosing good names is repaid tenfold in understanding and maintenance. Name thoughtfully.

---

*Canon Construct #5 ensures that code communicates clearly through thoughtful naming. When names are right, everything else follows.*