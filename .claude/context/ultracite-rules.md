# Ultracite Code Standards for Claude Code

> **Automated Workflow:** This project uses Ultracite (a zero-config Biome preset) for automated formatting and linting. A hook automatically runs `npx ultracite fix` after you edit or write files matching the applicable file types below.

## Applicable File Types

**These rules apply ONLY to files matching these patterns:**

- **TypeScript/JavaScript:** `*.{ts,tsx,js,jsx}`
- **Configuration:** `*.{json,jsonc}`
- **Markup/Templates:** `*.{html,vue,svelte,astro,md,mdx}`
- **Styles:** `*.css`
- **Data/Query:** `*.{yaml,yml,graphql,gql,grit}`

**When working with these file types, follow all Ultracite standards below.**
For other file types (Python, Go, Rust, etc.), these rules do not apply.

---

## Quick Reference Commands

- **Format code:** `npx ultracite fix`
- **Check for issues:** `npx ultracite check`
- **Diagnose setup:** `npx ultracite doctor`

Biome (the underlying engine) provides extremely fast Rust-based linting and formatting. Most issues are automatically fixable.

---

## Your Role as Claude Code

Biome will automatically handle formatting and catch many common issues. **Focus your attention on:**

1. **Business logic correctness** - Biome can't validate your algorithms or logic flow
2. **Meaningful naming** - Use descriptive names for functions, variables, and types
3. **Architecture decisions** - Component structure, data flow, and API design
4. **Edge cases** - Handle boundary conditions and error states thoughtfully
5. **User experience** - Accessibility, performance, and usability considerations
6. **Documentation** - Add comments for complex logic, but prefer self-documenting code

**What Biome handles automatically:**
- Code formatting (indentation, spacing, semicolons)
- Simple syntax issues
- Import organization
- Basic code smells

**What you should focus on:**
- Writing clear, maintainable code from the start
- Following the principles below
- Making intelligent architectural decisions

---

## Core Principles

Write code that is **accessible, performant, type-safe, and maintainable**. Focus on clarity and explicit intent over brevity.

### Type Safety & Explicitness

- Use explicit types for function parameters and return values when they enhance clarity
- Prefer `unknown` over `any` when the type is genuinely unknown
- Use const assertions (`as const`) for immutable values and literal types
- Leverage TypeScript's type narrowing instead of type assertions
- Use meaningful variable names instead of magic numbers - extract constants with descriptive names

**Example:**
```typescript
// Good - explicit and clear
function calculateTotal(items: CartItem[], taxRate: number): number {
  const subtotal = items.reduce((sum, item) => sum + item.price, 0);
  return subtotal * (1 + taxRate);
}

// Avoid - implicit types and magic numbers
function calculateTotal(items, rate) {
  return items.reduce((s, i) => s + i.price, 0) * 1.08;
}
```

### Modern JavaScript/TypeScript

- Use arrow functions for callbacks and short functions
- Prefer `for...of` loops over `.forEach()` and indexed `for` loops
- Use optional chaining (`?.`) and nullish coalescing (`??`) for safer property access
- Prefer template literals over string concatenation
- Use destructuring for object and array assignments
- Use `const` by default, `let` only when reassignment is needed, never `var`

**Example:**
```typescript
// Good - modern patterns
const userName = user?.profile?.name ?? 'Guest';
for (const item of items) {
  console.log(`Processing ${item.id}`);
}

// Avoid - older patterns
var userName = user && user.profile && user.profile.name || 'Guest';
items.forEach(function(item, i) {
  console.log('Processing ' + item.id);
});
```

### Async & Promises

- Always `await` promises in async functions - don't forget to use the return value
- Use `async/await` syntax instead of promise chains for better readability
- Handle errors appropriately in async code with try-catch blocks
- Don't use async functions as Promise executors

**Example:**
```typescript
// Good - clean async/await with error handling
async function fetchUserData(userId: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${userId}`);
    if (!response.ok) {
      throw new Error(`Failed to fetch user: ${response.statusText}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching user:', error);
    throw error;
  }
}

// Avoid - promise chains and missing error handling
function fetchUserData(userId) {
  return fetch(`/api/users/${userId}`)
    .then(r => r.json())
    .then(data => data);
}
```

### React & JSX

- Use function components over class components
- Call hooks at the top level only, never conditionally
- Specify all dependencies in hook dependency arrays correctly
- Use the `key` prop for elements in iterables (prefer unique IDs over array indices)
- Nest children between opening and closing tags instead of passing as props
- Don't define components inside other components
- Use semantic HTML and ARIA attributes for accessibility:
  - Provide meaningful alt text for images
  - Use proper heading hierarchy
  - Add labels for form inputs
  - Include keyboard event handlers alongside mouse events
  - Use semantic elements (`<button>`, `<nav>`, etc.) instead of divs with roles

**Example:**
```typescript
// Good - proper hooks, accessibility, and structure
function UserList({ users }: { users: User[] }) {
  const [filter, setFilter] = useState('');

  const filteredUsers = useMemo(
    () => users.filter(u => u.name.includes(filter)),
    [users, filter]
  );

  return (
    <div>
      <label htmlFor="filter">Filter users:</label>
      <input
        id="filter"
        type="text"
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        aria-label="Filter users by name"
      />
      <ul>
        {filteredUsers.map(user => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Error Handling & Debugging

- Avoid adding `console.log`, `debugger`, and `alert` statements (Biome will flag these)
- Throw `Error` objects with descriptive messages, not strings or other values
- Use `try-catch` blocks meaningfully - don't catch errors just to rethrow them
- Prefer early returns over nested conditionals for error cases

**Example:**
```typescript
// Good - proper error handling with early returns
function processPayment(amount: number, account: Account): PaymentResult {
  if (amount <= 0) {
    throw new Error('Payment amount must be positive');
  }

  if (!account.isActive) {
    return { success: false, error: 'Account is inactive' };
  }

  if (account.balance < amount) {
    return { success: false, error: 'Insufficient funds' };
  }

  // Process payment
  return { success: true, transactionId: generateId() };
}

// Avoid - nested conditionals and poor error handling
function processPayment(amount, account) {
  if (amount > 0) {
    if (account.isActive) {
      if (account.balance >= amount) {
        return { success: true };
      } else {
        throw 'not enough money';
      }
    }
  }
}
```

### Code Organization

- Keep functions focused and under reasonable cognitive complexity limits
- Extract complex conditions into well-named boolean variables
- Use early returns to reduce nesting
- Prefer simple conditionals over nested ternary operators
- Group related code together and separate concerns

**Example:**
```typescript
// Good - clear, focused function with extracted conditions
function canUserAccessResource(user: User, resource: Resource): boolean {
  const isOwner = resource.ownerId === user.id;
  const isAdmin = user.role === 'admin';
  const hasSharedAccess = resource.sharedWith.includes(user.id);

  return isOwner || isAdmin || hasSharedAccess;
}

// Avoid - complex nested ternary
function canUserAccessResource(user, resource) {
  return resource.ownerId === user.id ? true :
         user.role === 'admin' ? true :
         resource.sharedWith.includes(user.id) ? true : false;
}
```

### Security

- Add `rel="noopener"` when using `target="_blank"` on links
- Avoid `dangerouslySetInnerHTML` unless absolutely necessary
- Don't use `eval()` or assign directly to `document.cookie`
- Validate and sanitize user input

**Example:**
```typescript
// Good - secure external link
<a href="https://example.com" target="_blank" rel="noopener noreferrer">
  External Link
</a>

// Good - input validation
function updateUsername(input: string): string {
  const sanitized = input.trim().slice(0, 50);
  if (!/^[a-zA-Z0-9_-]+$/.test(sanitized)) {
    throw new Error('Username contains invalid characters');
  }
  return sanitized;
}
```

### Performance

- Avoid spread syntax in accumulators within loops
- Use top-level regex literals instead of creating them in loops
- Prefer specific imports over namespace imports
- Avoid barrel files (index files that re-export everything)
- Use proper image components (e.g., Next.js `<Image>`) over `<img>` tags

**Example:**
```typescript
// Good - efficient accumulation
const result = items.reduce((acc, item) => {
  acc.push(item.value);
  return acc;
}, [] as string[]);

// Avoid - spread in accumulator (creates new array each iteration)
const result = items.reduce((acc, item) => [...acc, item.value], []);

// Good - top-level regex
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
function validateEmails(emails: string[]): boolean[] {
  return emails.map(email => EMAIL_PATTERN.test(email));
}

// Avoid - regex in loop
function validateEmails(emails) {
  return emails.map(email => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email));
}
```

### Framework-Specific Guidance

#### Next.js
- Use Next.js `<Image>` component for images
- Use `next/head` or App Router metadata API for head elements
- Use Server Components for async data fetching instead of async Client Components

#### React 19+
- Use ref as a prop instead of `React.forwardRef`

#### Solid/Svelte/Vue/Qwik
- Use `class` and `for` attributes (not `className` or `htmlFor`)

---

## Testing

- Write assertions inside `it()` or `test()` blocks
- Avoid done callbacks in async tests - use async/await instead
- Don't use `.only` or `.skip` in committed code
- Keep test suites reasonably flat - avoid excessive `describe` nesting

**Example:**
```typescript
// Good - clean async test
test('fetches user data successfully', async () => {
  const user = await fetchUser('123');
  expect(user.id).toBe('123');
  expect(user.name).toBeDefined();
});

// Avoid - done callback
test('fetches user data', (done) => {
  fetchUser('123').then(user => {
    expect(user.id).toBe('123');
    done();
  });
});
```

---

## Workflow Integration

**When you write or edit files:**
1. Follow the principles above as you write code
2. After saving, the hook automatically runs `npx ultracite fix`
3. Biome handles formatting and fixes simple issues
4. You focus on logic, architecture, and maintainability

**If you need to check manually:**
- Run `npx ultracite check` to see issues without fixing
- Run `npx ultracite fix` to format and auto-fix issues
- Run `npx ultracite doctor` if something seems wrong

---

## Remember

Most formatting and common issues are automatically fixed by Biome. Your value as Claude Code is in:
- Writing clear, maintainable code from the start
- Making good architectural decisions
- Handling edge cases thoughtfully
- Ensuring accessibility and security
- Creating self-documenting code with meaningful names

Let Biome handle the formatting. You handle the thinking.

