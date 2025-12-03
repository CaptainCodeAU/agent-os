## Tech stack

**NOTE FOR AGENTS:** This is a template file with placeholder examples. The actual product tech stack is defined in `agent-os/product/tech-stack.md` (created by the `/plan-product` command). Always reference `agent-os/product/tech-stack.md` for implementation guidance.

---

## How This Works

**This File (standards/global/tech-stack.md):**
- Your **default tech stack** preferences across all projects
- Used as a foundation when creating product-specific tech stacks via `/plan-product`
- Injected into agents via `{{standards/*}}` (but agents should prefer product version)

**Product-Specific Tech Stack (agent-os/product/tech-stack.md):**
- Created by the `/plan-product` command for each specific product
- Combines your defaults here + product-specific choices + user input
- The **actual tech stack** that agents use during implementation
- This is the source of truth for the current product being built

**Instructions for Users:**
Replace the placeholder examples below with your actual default technology choices. These will serve as defaults when you create new products. Leave as placeholders if you want to specify tech stack on a per-product basis.

### Framework & Runtime
- **Application Framework:** [e.g., Rails, Django, Next.js, Express]
- **Language/Runtime:** [e.g., Ruby, Python, Node.js, Java]
- **Package Manager:** [e.g., bundler, pip, npm, yarn]

### Frontend
- **JavaScript Framework:** [e.g., React, Vue, Svelte, Alpine, vanilla JS]
- **CSS Framework:** [e.g., Tailwind CSS, Bootstrap, custom]
- **UI Components:** [e.g., shadcn/ui, Material UI, custom library]

### Database & Storage
- **Database:** [e.g., PostgreSQL, MySQL, MongoDB]
- **ORM/Query Builder:** [e.g., ActiveRecord, Prisma, Sequelize]
- **Caching:** [e.g., Redis, Memcached]

### Testing & Quality
- **Test Framework:** [e.g., Jest, RSpec, pytest]
- **Linting/Formatting:** [e.g., ESLint, Prettier, RuboCop]

### Deployment & Infrastructure
- **Hosting:** [e.g., Heroku, AWS, Vercel, Railway]
- **CI/CD:** [e.g., GitHub Actions, CircleCI]

### Third-Party Services
- **Authentication:** [e.g., Auth0, Devise, NextAuth]
- **Email:** [e.g., SendGrid, Postmark]
- **Monitoring:** [e.g., Sentry, Datadog]
