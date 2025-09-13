# Naming That Works: Code That Explains Itself

## The Daily Confusion Tax...

```javascript
// Monday: You write this
const d = new Date();
const mgr = new UserManager();
const proc = (u) => { /* ... */ };

// Friday: You read this
// "What's d? What's mgr? What does proc process?"
// 10 minutes just figuring out your own code

// Next month: New developer reads this
// "I have no idea what any of this does"
// 2 hours onboarding turns into 2 days
```

We're all paying the confusion tax. Here's how to stop.

## The Simple Truth

> **"Good names eliminate confusion. Bad names create bugs."**

Every name in your code is either helping or hurting. This methodology ensures every name helps.

## 📊 What You'll Gain

| Bad Naming | Good Naming |
|------------|------------|
| 10+ minutes per confusion | Instant understanding |
| Constant "what does this do?" | Self-documenting code |
| Bugs from misunderstanding | Clear intent prevents bugs |
| Slow onboarding | New devs productive day 1 |
| Comments everywhere | Code explains itself |
| **Mental Load: Maximum** | **Mental Load: Minimal** |

## The Real Cost of Bad Names

### Time Lost to Confusion
```javascript
// Bad naming
const d = new Date();
const u = getU();
const calc = (x, y) => x * 0.1 + y;

// Developer thinks: "What's d? What's u? What's being calculated?"
// Time wasted: 5-10 minutes per confusion
// Multiplied by every developer, every time
```

### Bugs From Misunderstanding
```javascript
// Misleading name
function saveUser(user) {
  validateUser(user);  // Doesn't actually save!
}

// Developer uses it thinking it saves
// Bug discovered in production
// Debug time: 2+ hours
```

## What Good Naming Looks Like

### Clear Intent
```javascript
// ❌ Bad: What does this do?
const process = (data) => {/*...*/}
const mg = new Manager();
const flag = true;

// ✅ Good: Intent is obvious
const validateEmailFormat = (email) => {/*...*/}
const userAccountManager = new UserAccountManager();
const isEmailVerified = true;
```

### Consistent Patterns
```javascript
// ❌ Bad: Mixed patterns confuse
getUserById()
fetch_user_data()
LoadUserInfo()

// ✅ Good: Consistent pattern
getUserById()
getUserData()
getUserInfo()
```

### Self-Documenting
```javascript
// ❌ Bad: Needs comments to explain
const t = 5000; // timeout in milliseconds
function check() {} // checks if user is valid

// ✅ Good: Names explain themselves
const TIMEOUT_IN_MS = 5000;
function isUserValid() {}
```

## The Naming Rules That Matter

### Rule 1: Be Specific
```javascript
// ❌ Too Generic
data, info, thing, stuff, obj, item, element

// ✅ Specific
userData, accountInfo, cartItem, productElement
```

### Rule 2: Use Full Words
```javascript
// ❌ Abbreviated
usrMgr, calcPrc, procOrd, retVal

// ✅ Full Words
userManager, calculatePrice, processOrder, returnValue
```

### Rule 3: Match Type to Name

**Booleans: Start with is/has/can**
```javascript
isActive, hasPermission, canEdit, shouldUpdate
```

**Arrays: Use plurals**
```javascript
users, products, activeConnections, errorMessages
```

**Functions: Start with verbs**
```javascript
createUser(), deletePost(), updateSettings(), validateEmail()
```

**Classes: Use nouns**
```javascript
UserService, ProductController, DatabaseConnection
```

### Rule 4: Avoid Redundancy
```javascript
// ❌ Redundant context
class User {
  userName: string;     // 'user' is redundant
  userEmail: string;    // we know it's a user
  userPassword: string; // from the class name
}

// ✅ Clean
class User {
  name: string;
  email: string;
  password: string;
}
```

## Common Naming Patterns

### File Names
```bash
# ❌ Inconsistent
UserController.js
user-service.js
USER_REPOSITORY.JS

# ✅ Consistent (kebab-case)
user-controller.js
user-service.js
user-repository.js
```

### API Endpoints
```bash
# ❌ Unclear
GET /api/getUsers
POST /api/new-user
PUT /api/USER_UPDATE

# ✅ RESTful and clear
GET /api/users
POST /api/users
PUT /api/users/:id
```

### Database Tables
```sql
-- ❌ Mixed conventions
CREATE TABLE User;
CREATE TABLE products_table;
CREATE TABLE ORDER_ITEMS;

-- ✅ Consistent (plural, snake_case)
CREATE TABLE users;
CREATE TABLE products;
CREATE TABLE order_items;
```

## Real-World Impact

### Before Good Naming
```javascript
// Actual code found in production
const d = getD();
const p = calc(d);
if (p > th) {
  proc(d);
}
// Time to understand: 10+ minutes
// Bugs from misunderstanding: Common
```

### After Good Naming
```javascript
// Same logic, clear names
const orderData = getOrderData();
const totalPrice = calculatePrice(orderData);
if (totalPrice > DISCOUNT_THRESHOLD) {
  applyDiscount(orderData);
}
// Time to understand: 10 seconds
// Bugs from misunderstanding: Rare
```

## The 5-Second Rule

If you can't understand what something does from its name in 5 seconds, the name is wrong.

Test your names:
```javascript
// Can you tell what these do in 5 seconds?

// ❌ No
function proc() {}
const mgr = {};
let flag = true;

// ✅ Yes
function processPayment() {}
const accountManager = {};
let isPaymentComplete = true;
```

## Naming Anti-Patterns to Avoid

### The Mystery Abbreviation
```javascript
// ❌ What do these mean?
const usr = {};
const prc = 100;
const calc = () => {};
```

### The Lying Name
```javascript
// ❌ Name doesn't match behavior
function getUser() {
  // Actually creates a user
  return createNewUser();
}
```

### The And/Or Function
```javascript
// ❌ Doing too much
function saveUserAndSendEmailAndLogEvent() {}

// ✅ Better: Separate concerns
function saveUser() {}
function sendWelcomeEmail() {}
function logUserCreation() {}
```

### The Number Suffix
```javascript
// ❌ Meaningless numbers
let data1, data2, data3;

// ✅ Meaningful names
let rawData, processedData, validatedData;
```

## How Cohesion Eliminates the Confusion Tax

**The Relief**: Your AI assistant is a naming expert built-in.

### Your AI Names Everything Perfectly

When working with Cohesion, your AI:

1. **Follows your patterns** - Learns from your codebase
2. **Never abbreviates** - Full, clear names always
3. **Applies conventions** - isActive, getUserById, UserService
4. **Refuses generic names** - No more data, info, thing
5. **Refactors bad names** - Improves naming automatically

**You never have to think** "what should I call this?" again.

### The System Enforces Clarity
- **New code**: Named correctly from the start
- **Existing code**: Bad names flagged for refactoring
- **Reviews**: Naming issues caught automatically
- **Result**: Confusion tax eliminated

## The Naming Transformation

### Week 1: Awareness
Start noticing bad names. Ask: "What does this actually do?"

### Week 2: Practice
For every new variable/function, spend 30 seconds on the name.

### Week 3: Refactoring
Start renaming unclear code as you work with it.

### Week 4: Habit
Good naming becomes automatic. Code becomes self-documenting.

## Quick Naming Checklist

Before finalizing any name, ask:

- [ ] **Is it specific?** Not generic like 'data' or 'info'
- [ ] **Is it accurate?** Name matches behavior
- [ ] **Is it complete?** Full words, not abbreviations
- [ ] **Is it consistent?** Follows project patterns
- [ ] **Is it clear?** New developer would understand

## The ROI of Good Names

### Bad Naming Costs
- 10 minutes per confusion × multiple times daily
- Bugs from misunderstanding
- Slow onboarding
- Constant "what does this do?" questions

### Good Naming Saves
- Instant understanding
- Self-documenting code
- Fast onboarding
- Fewer bugs
- Less documentation needed

## 🎯 Try This Now

**The 5-Second Test**:
```javascript
// Look at each name for 5 seconds:

// Test 1:
const p = calcPrice(items);
// Can you tell what 'p' is? No? Bad name.

// Test 2:
const totalPrice = calculatePrice(items);
// Can you tell what it is? Yes? Good name.

// Your turn: Check your latest code
// Any names fail the 5-second test?
// Refactor them now. Future you will thank you.
```

## How Good Naming Amplifies Other Methodologies

- **Think-First** + Good Names = Clear mental models
- **Always-Works** + Good Names = Tests explain themselves
- **Reality-Check** + Good Names = Clear expected vs actual
- **Approval-Criteria** + Good Names = Clear what needs permission

Good naming is the foundation that makes everything else easier.

## Your Naming Challenge

Next time you code:

1. **Stop** before naming anything
2. **Think** what it really does
3. **Choose** a name that explains itself
4. **Test** with the 5-second rule
5. **Refactor** if unclear

## Common Transformations

| Bad | Good | Why Better |
|-----|------|------------|
| `d` | `currentDate` | Clear purpose |
| `process()` | `validateOrder()` | Specific action |
| `flag` | `isProcessing` | Boolean clarity |
| `mgr` | `userManager` | Full words |
| `data1` | `rawInput` | Meaningful distinction |
| `getUser()` | `fetchUserById()` | Precise behavior |

## The Naming Promise

When you name things well:
- Your code explains itself
- Comments become unnecessary
- Bugs from confusion disappear
- New developers understand instantly
- Maintenance becomes easy

Remember: Every good name is a gift to your future self.

---

*Code is read 10x more than it's written. Make those reads count with great names.*