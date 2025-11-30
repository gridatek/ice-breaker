# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**IceBreaker** is a web application designed to help people meet, converse, and get to know each other through a turn-based card game over a live voice call. The application supports a creator + guest flow where only the room creator needs an account while joiners can participate as guests.

### Key Features
- Turn-based card game with conversation prompts
- Real-time voice calls using WebRTC (peer-to-peer)
- Customizable question types (fun, deep, flirty, random)
- Real-time synchronization via Supabase Realtime
- Creator authentication, guest access without accounts

### Tech Stack
- **Frontend**: Angular 21 with standalone components
- **Backend & Realtime**: Supabase (Auth, Realtime Database)
- **Voice Communication**: WebRTC
- **Styling**: Tailwind CSS 4.x
- **Package Manager**: pnpm
- **Testing**: Vitest

## Repository Structure

This is a **pnpm workspace monorepo** containing two Angular applications and shared libraries:

```
ice-breaker/
├── apps/
│   ├── web-app/          # Main user-facing application
│   │   ├── src/
│   │   │   ├── app/      # Angular app components and routes
│   │   │   ├── main.ts
│   │   │   └── styles.css
│   │   ├── package.json
│   │   └── angular.json
│   └── admin-app/        # Administrative dashboard
│       ├── src/
│       │   ├── app/
│       │   ├── main.ts
│       │   └── styles.css
│       ├── package.json
│       └── angular.json
├── libs/                 # Shared libraries
│   ├── features/         # Feature-specific libraries
│   ├── shared/           # Shared utilities and helpers
│   ├── data-access/      # API clients and data access
│   └── ui/               # Shared UI components
├── package.json          # Root package.json with workspace scripts
├── pnpm-workspace.yaml   # pnpm workspace configuration
├── .gitignore            # Root-level gitignore
└── README.md
```

**Important**: This is configured as a pnpm workspace where:
- Each app has its own `package.json` with independent dependencies
- The root `package.json` provides convenience scripts to run commands across apps
- Each app has its own `angular.json` configuration and `tsconfig.json` files
- Dependencies are shared when possible via pnpm's workspace feature
- Shared libraries in `libs/` can be imported using workspace protocol (`@ice-breaker/lib-name`)
- Libraries are organized by type: features, shared utilities, data-access, and UI components

## Common Development Commands

### Root-Level Commands (Recommended)

From the repository root, you can use these convenience scripts:

**Web App:**
```bash
pnpm web-app:start    # Start web-app dev server
pnpm web-app:build    # Build web-app
pnpm web-app:test     # Run web-app tests
```

**Admin App:**
```bash
pnpm admin-app:start  # Start admin-app dev server
pnpm admin-app:build  # Build admin-app
pnpm admin-app:test   # Run admin-app tests
```

**All Apps:**
```bash
pnpm build:all        # Build all apps
pnpm test:all         # Run tests for all apps
pnpm install:all      # Install dependencies for all apps
```

### Working Directly in App Directories

You can also navigate to specific app directories and use Angular CLI directly:

**Navigate to app:**
```bash
cd apps/web-app
# or
cd apps/admin-app
```

**Development server:**
```bash
ng serve
# or
pnpm start
```
Server runs at `http://localhost:4200/`

**Build:**
```bash
ng build              # Production build
ng build --configuration development  # Dev build
```

**Watch mode:**
```bash
ng watch
# or
pnpm watch
```

**Testing:**
```bash
ng test
# or
pnpm test
```

**Code generation:**
```bash
ng generate component component-name
ng generate service service-name
ng generate --help    # See all available schematics
```

### Installing Dependencies

**From root (recommended):**
```bash
pnpm install          # Installs all workspace dependencies
```

**From individual app directory:**
```bash
cd apps/web-app
pnpm install
```

## Angular Configuration

Both applications use Angular 21 with the following configuration:

### Schematics Defaults
- **Components**: Inline templates, inline styles, tests disabled by default
- **Services/Pipes/Guards/etc**: Tests disabled by default
- **Component prefix**: `app`

### Build Configuration
- **Production**: Output hashing enabled, budgets enforced (500kB warning, 1MB error for initial bundle)
- **Development**: Optimization off, source maps enabled, no license extraction

### Code Style
Both apps use Prettier with these settings:
- Print width: 100 characters
- Single quotes: enabled
- HTML parser: Angular-specific parser

## Architecture Notes

### Angular Standalone Components
Both applications use Angular's standalone components architecture (no NgModules). Components are self-contained and declare their own imports.

### Routing
Routes are defined in `src/app/app.routes.ts` for each app. Currently minimal routing is configured.

### Application Bootstrap
Applications bootstrap via:
- `src/main.ts` - Entry point
- `src/app/app.config.ts` - Application configuration with providers
- `src/app/app.ts` - Root component

### Real-time Architecture
The application will integrate with Supabase for:
- User authentication (room creators only)
- Real-time database updates for game state
- WebRTC signaling coordination

### WebRTC Integration
Voice communication will be peer-to-peer using WebRTC. The Supabase realtime database will likely be used for signaling and peer discovery.

## Development Workflow

### Option 1: Using Root Scripts (Recommended for Quick Tasks)
1. From the repository root, run `pnpm install` to install all dependencies
2. Start the desired app: `pnpm web-app:start` or `pnpm admin-app:start`
3. Make changes - the app will auto-reload
4. Build for production: `pnpm web-app:build` or `pnpm build:all`

### Option 2: Working in App Directory (Recommended for Extended Development)
1. Navigate to the specific app: `cd apps/web-app` or `cd apps/admin-app`
2. Ensure dependencies are installed with `pnpm install` from root
3. Start the dev server with `ng serve` or `pnpm start`
4. Make changes - the app will auto-reload
5. Generate new components/services with `ng generate`
6. Build for production with `ng build`

### First Time Setup
```bash
# From repository root
pnpm install          # Install all workspace dependencies
pnpm web-app:start    # Start developing
```

## Testing

Both apps use Vitest as the test runner. Run tests from within the app directory:
```bash
cd apps/web-app
ng test
```

Note: Test generation is disabled by default in schematics configuration.
