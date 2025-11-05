# Inavor Shuttle - Shopify Product Import Application

**Company**: Rovani Projects, Inc.
**Repository**: https://github.com/rovaniprojects/inavor-shuttle
**Purpose**: Learning project & proof of concept for Shopify App Store publication
**Primary Goal**: AWS platform mastery through production-grade Shopify app development

## Project Overview

Inavor Shuttle enables merchants to import product catalogs into Shopify with advanced metafield and metaobject support. The application provides:

- **JSON-based import templates** with schema validation
- **Dry-run capabilities** for safe testing before committing changes
- **Multiple import modes**: overwrite existing, new only, new + draft overwrites, wipe & restore
- **Metafield & metaobject management** with "shopify" namespace support
- **Async job processing** with real-time progress tracking and detailed reporting
- **Feature-gated plans** with usage limits (per import, daily, per storefront)
- **Multi-tenant architecture** supporting unlimited Shopify storefronts

This app is built using [React Router](https://reactrouter.com/) with a serverless-first AWS architecture for scalability and cost efficiency.

## Technology Stack

### Frontend & Backend
- **Framework**: React Router (Node.js 20.x LTS)
- **Language**: TypeScript (strict mode)
- **UI Library**: Shopify Polaris + Tailwind CSS
- **State Management**: React Router loaders/actions (server), React hooks (client)

### AWS Infrastructure (Production)
- **Compute**: AWS App Runner (main app) + AWS Lambda (async jobs)
- **Database**: DynamoDB (serverless, auto-scaling)
- **Storage**: S3 (imports, logs, exports)
- **Queues**: SQS (async job processing)
- **Monitoring**: CloudWatch + X-Ray (distributed tracing)
- **Infrastructure as Code**: AWS CDK (TypeScript)

### Local Development
- Docker Compose (local DynamoDB)
- Shopify CLI (tunneling, webhooks)
- Vitest (unit + integration tests)
- Playwright (E2E testing)

## Upgrading from Remix

If you have an existing Remix app that you want to upgrade to React Router, please follow the [upgrade guide](https://github.com/Shopify/shopify-app-template-react-router/wiki/Upgrading-from-Remix).  Otherwise, please follow the quick start guide below.

## Quick Start

### Prerequisites

Before you begin, you'll need the following:

1. **Node.js**: Version 20.19+ or 22.12+ ([Download](https://nodejs.org/en/download/))
2. **Shopify Partner Account**: [Create an account](https://partners.shopify.com/signup) if you don't have one
3. **Test Store**: Set up a [development store](https://help.shopify.com/en/partners/dashboard/development-stores#create-a-development-store) for testing
4. **Shopify CLI**: [Download and install](https://shopify.dev/docs/apps/tools/cli/getting-started)
   ```shell
   npm install -g @shopify/cli@latest
   ```
5. **Docker Desktop**: For local DynamoDB development (optional but recommended)
6. **AWS Account**: For production deployments with AWS CDK

### Setup

Clone the repository:
```shell
git clone https://github.com/rovaniprojects/inavor-shuttle.git
cd inavor-shuttle
npm install
```

Initialize the database:
```shell
npm run setup
```

This runs Prisma migrations and generates the Prisma client.

### Local Development

Start the development server:
```shell
npm run dev
```

This command:
- Starts the React Router dev server
- Creates a tunnel to Shopify (via Shopify CLI)
- Watches for changes and hot-reloads
- Syncs environment variables from your Shopify app config

Press **P** to open the app URL. Click "Install" to install on your test store and begin development.

### Project Structure

```
inavor-shuttle/
├── app/                          # React Router application
│   ├── routes/                   # Route handlers & pages
│   │   ├── _index.tsx           # Dashboard
│   │   ├── import.upload.tsx    # File upload page
│   │   ├── import.jobs.tsx      # Job list & management
│   │   ├── config.tsx           # Settings & configuration
│   │   └── api/                 # API endpoints
│   ├── components/               # Reusable React components
│   ├── lib/                      # Utilities
│   │   ├── shopify.server.ts    # Shopify API client
│   │   ├── db.server.ts         # Database layer
│   │   ├── validation.ts        # Schema validation
│   │   └── ...
│   └── root.tsx                  # App root layout
├── prisma/
│   ├── schema.prisma            # Database schema
│   └── migrations/              # Migration files
├── public/                       # Static assets
├── infrastructure/               # AWS CDK (for production)
├── tests/                        # Test files
├── docs/                         # Documentation
│   └── comprehensive-implementation-plan.md  # Full architectural guide
└── package.json
```

For detailed implementation architecture, see [docs/comprehensive-implementation-plan.md](./docs/comprehensive-implementation-plan.md).

### Authenticating and querying data

To authenticate and query data you can use the `shopify` const that is exported from `/app/shopify.server.js`:

```js
export async function loader({ request }) {
  const { admin } = await shopify.authenticate.admin(request);

  const response = await admin.graphql(`
    {
      products(first: 25) {
        nodes {
          title
          description
        }
      }
    }`);

  const {
    data: {
      products: { nodes },
    },
  } = await response.json();

  return nodes;
}
```

This template comes pre-configured with examples of:

1. Setting up your Shopify app in [/app/shopify.server.ts](https://github.com/Shopify/shopify-app-template-react-router/blob/main/app/shopify.server.ts)
2. Querying data using Graphql. Please see: [/app/routes/app.\_index.tsx](https://github.com/Shopify/shopify-app-template-react-router/blob/main/app/routes/app._index.tsx).
3. Responding to webhooks. Please see [/app/routes/webhooks.tsx](https://github.com/Shopify/shopify-app-template-react-router/blob/main/app/routes/webhooks.app.uninstalled.tsx).

Please read the [documentation for @shopify/shopify-app-react-router](https://shopify.dev/docs/api/shopify-app-react-router) to see what other API's are available.

## Shopify Dev MCP

This template is configured with the Shopify Dev MCP. This instructs [Cursor](https://cursor.com/), [GitHub Copilot](https://github.com/features/copilot) and [Claude Code](https://claude.com/product/claude-code) and [Google Gemini CLI](https://github.com/google-gemini/gemini-cli) to use the Shopify Dev MCP.  

For more information on the Shopify Dev MCP please read [the  documentation](https://shopify.dev/docs/apps/build/devmcp).

## Deployment

### Application Storage

This template uses [Prisma](https://www.prisma.io/) to store session data, by default using an [SQLite](https://www.sqlite.org/index.html) database.
The database is defined as a Prisma schema in `prisma/schema.prisma`.

This use of SQLite works in production if your app runs as a single instance.
The database that works best for you depends on the data your app needs and how it is queried.
Here’s a short list of databases providers that provide a free tier to get started:

| Database   | Type             | Hosters                                                                                                                                                                                                                               |
| ---------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MySQL      | SQL              | [Digital Ocean](https://www.digitalocean.com/products/managed-databases-mysql), [Planet Scale](https://planetscale.com/), [Amazon Aurora](https://aws.amazon.com/rds/aurora/), [Google Cloud SQL](https://cloud.google.com/sql/docs/mysql) |
| PostgreSQL | SQL              | [Digital Ocean](https://www.digitalocean.com/products/managed-databases-postgresql), [Amazon Aurora](https://aws.amazon.com/rds/aurora/), [Google Cloud SQL](https://cloud.google.com/sql/docs/postgres)                                   |
| Redis      | Key-value        | [Digital Ocean](https://www.digitalocean.com/products/managed-databases-redis), [Amazon MemoryDB](https://aws.amazon.com/memorydb/)                                                                                                        |
| MongoDB    | NoSQL / Document | [Digital Ocean](https://www.digitalocean.com/products/managed-databases-mongodb), [MongoDB Atlas](https://www.mongodb.com/atlas/database)                                                                                                  |

To use one of these, you can use a different [datasource provider](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference#datasource) in your `schema.prisma` file, or a different [SessionStorage adapter package](https://github.com/Shopify/shopify-api-js/blob/main/packages/shopify-api/docs/guides/session-storage.md).

### Build

Build the app by running the command below with the package manager of your choice:

Using yarn:

```shell
yarn build
```

Using npm:

```shell
npm run build
```

Using pnpm:

```shell
pnpm run build
```

## Hosting

When you're ready to set up your app in production, you can follow [our deployment documentation](https://shopify.dev/docs/apps/deployment/web) to host your app on a cloud provider like [Heroku](https://www.heroku.com/) or [Fly.io](https://fly.io/).

When you reach the step for [setting up environment variables](https://shopify.dev/docs/apps/deployment/web#set-env-vars), you also need to set the variable `NODE_ENV=production`.


## Gotchas / Troubleshooting

### Database tables don't exist

If you get an error like:

```
The table `main.Session` does not exist in the current database.
```

Create the database for Prisma. Run the `setup` script in `package.json` using `npm`, `yarn` or `pnpm`.

### Navigating/redirecting breaks an embedded app

Embedded apps must maintain the user session, which can be tricky inside an iFrame. To avoid issues:

1. Use `Link` from `react-router` or `@shopify/polaris`. Do not use `<a>`.
2. Use `redirect` returned from `authenticate.admin`. Do not use `redirect` from `react-router`
3. Use `useSubmit` from `react-router`.

This only applies if your app is embedded, which it will be by default.

### Webhooks: shop-specific webhook subscriptions aren't updated

If you are registering webhooks in the `afterAuth` hook, using `shopify.registerWebhooks`, you may find that your subscriptions aren't being updated.  

Instead of using the `afterAuth` hook declare app-specific webhooks in the `shopify.app.toml` file.  This approach is easier since Shopify will automatically sync changes every time you run `deploy` (e.g: `npm run deploy`).  Please read these guides to understand more:

1. [app-specific vs shop-specific webhooks](https://shopify.dev/docs/apps/build/webhooks/subscribe#app-specific-subscriptions)
2. [Create a subscription tutorial](https://shopify.dev/docs/apps/build/webhooks/subscribe/get-started?deliveryMethod=https)

If you do need shop-specific webhooks, keep in mind that the package calls `afterAuth` in 2 scenarios:

- After installing the app
- When an access token expires

During normal development, the app won't need to re-authenticate most of the time, so shop-specific subscriptions aren't updated. To force your app to update the subscriptions, uninstall and reinstall the app. Revisiting the app will call the `afterAuth` hook.

### Webhooks: Admin created webhook failing HMAC validation

Webhooks subscriptions created in the [Shopify admin](https://help.shopify.com/en/manual/orders/notifications/webhooks) will fail HMAC validation. This is because the webhook payload is not signed with your app's secret key.  

The recommended solution is to use [app-specific webhooks](https://shopify.dev/docs/apps/build/webhooks/subscribe#app-specific-subscriptions) defined in your toml file instead.  Test your webhooks by triggering events manually in the Shopify admin(e.g. Updating the product title to trigger a `PRODUCTS_UPDATE`).

### Webhooks: Admin object undefined on webhook events triggered by the CLI

When you trigger a webhook event using the Shopify CLI, the `admin` object will be `undefined`. This is because the CLI triggers an event with a valid, but non-existent, shop. The `admin` object is only available when the webhook is triggered by a shop that has installed the app.  This is expected.

Webhooks triggered by the CLI are intended for initial experimentation testing of your webhook configuration. For more information on how to test your webhooks, see the [Shopify CLI documentation](https://shopify.dev/docs/apps/tools/cli/commands#webhook-trigger).

### Incorrect GraphQL Hints

By default the [graphql.vscode-graphql](https://marketplace.visualstudio.com/items?itemName=GraphQL.vscode-graphql) extension for will assume that GraphQL queries or mutations are for the [Shopify Admin API](https://shopify.dev/docs/api/admin). This is a sensible default, but it may not be true if:

1. You use another Shopify API such as the storefront API.
2. You use a third party GraphQL API.

If so, please update [.graphqlrc.ts](https://github.com/Shopify/shopify-app-template-react-router/blob/main/.graphqlrc.ts).

### Using Defer & await for streaming responses

By default the CLI uses a cloudflare tunnel. Unfortunately  cloudflare tunnels wait for the Response stream to finish, then sends one chunk.  This will not affect production.

To test [streaming using await](https://reactrouter.com/api/components/Await#await) during local development we recommend [localhost based development](https://shopify.dev/docs/apps/build/cli-for-apps/networking-options#localhost-based-development).

### "nbf" claim timestamp check failed

This is because a JWT token is expired.  If you  are consistently getting this error, it could be that the clock on your machine is not in sync with the server.  To fix this ensure you have enabled "Set time and date automatically" in the "Date and Time" settings on your computer.

### Using MongoDB and Prisma

If you choose to use MongoDB with Prisma, there are some gotchas in Prisma's MongoDB support to be aware of. Please see the [Prisma SessionStorage README](https://www.npmjs.com/package/@shopify/shopify-app-session-storage-prisma#mongodb).

## Core Features

### Phase 1: MVP (In Development)
- Shopify OAuth & multi-tenant support
- JSON schema validation for product imports
- Metafield & metaobject validation & introspection
- Dry-run validation before import
- Async job processing via SQS + Lambda
- Multiple import modes (new, overwrite, wipe & restore)
- Feature-gated plans with usage tracking
- Real-time job progress tracking
- Job management UI & reporting

### Phase 2: Enhanced Features (Planned)
- API endpoint for programmatic imports
- Advanced metafield type support
- Catalog export functionality
- Import templates library
- Shopify Billing API integration
- Advanced analytics & cost tracking

### Phase 3: Enterprise (Future)
- Team collaboration & RBAC
- Job scheduling & automation
- External system integrations (Zapier, webhooks)
- Performance optimization for large catalogs

## Development Guidelines

### Code Standards
- **TypeScript**: Strict mode enabled, no `any` types
- **Testing**: Aim for >80% coverage on critical paths
- **Linting**: ESLint + Prettier (auto-formatted on commit)
- **Commits**: Follow [Conventional Commits](https://www.conventionalcommits.org/)

### Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature development
- `fix/*` - Bug fixes

### Running Tests
```shell
# Unit & integration tests
npm run test

# E2E tests
npm run test:e2e

# Type checking
npm run typecheck

# Linting
npm run lint
```

### Building for Production
```shell
npm run build
npm start
```

## Deployment

### Local Development
Uses Shopify CLI for local tunneling and webhooks. Database uses SQLite by default.

### Production (AWS)
See [docs/comprehensive-implementation-plan.md](./docs/comprehensive-implementation-plan.md#deployment-strategy) for detailed AWS CDK deployment instructions.

- **Compute**: AWS App Runner for Remix app
- **Jobs**: AWS Lambda for async processing
- **Database**: DynamoDB (single-table design)
- **Storage**: S3 with lifecycle policies
- **CI/CD**: GitHub Actions (test → staging → production)

## Resources

### Shopify
- [Intro to Shopify apps](https://shopify.dev/docs/apps/getting-started)
- [Shopify App React Router docs](https://shopify.dev/docs/api/shopify-app-react-router)
- [Shopify Admin API](https://shopify.dev/api/admin-graphql)
- [Shopify Polaris UI](https://polaris.shopify.com/)
- [Shopify CLI](https://shopify.dev/docs/apps/tools/cli)

### AWS
- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

### Frameworks & Tools
- [React Router docs](https://reactrouter.com/home)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [Vitest Documentation](https://vitest.dev/)
- [Playwright Documentation](https://playwright.dev/)

## Architecture Highlights

- **Serverless-First**: DynamoDB, Lambda, SQS for cost efficiency and auto-scaling
- **Multi-Tenant**: Secure data isolation using shop domain partitioning
- **Event-Driven**: SQS queues + Lambda for decoupled async processing
- **Observable**: CloudWatch metrics, X-Ray tracing, structured logging
- **Secure**: Encrypted tokens, IAM least-privilege, GDPR compliant
- **Scalable**: Horizontal scaling without server management

## Contributing

1. Create a feature branch from `develop`
2. Make your changes with descriptive commits
3. Ensure tests pass: `npm run test`
4. Run typecheck: `npm run typecheck`
5. Submit a pull request with a clear description
6. Code review required before merge

## Support & Questions

For architectural decisions and implementation details, refer to [docs/comprehensive-implementation-plan.md](./docs/comprehensive-implementation-plan.md).

**Project Owner**: David Rovani (david@rovaniprojects.com)
**Company**: Rovani Projects, Inc.
**Website**: https://rovaniprojects.com
