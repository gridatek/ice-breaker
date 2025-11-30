# Shared Libraries

This directory contains shared libraries used across the IceBreaker applications.

## Structure

### `features/`
Feature-specific libraries that encapsulate complete features (e.g., game-room, voice-call).

### `shared/`
Shared utilities, helpers, and common functionality used across multiple features.

### `data-access/`
Data access libraries for API clients, Supabase integration, and state management.

### `ui/`
Shared UI component libraries and design system components.

## Creating a New Library

Each library should be a separate npm package with its own `package.json` and can be imported by the apps using workspace protocol:

```json
{
  "dependencies": {
    "@ice-breaker/feature-name": "workspace:*"
  }
}
```

## Naming Convention

Libraries should follow the naming pattern: `@ice-breaker/<category>-<name>`

Examples:
- `@ice-breaker/feature-game`
- `@ice-breaker/ui-components`
- `@ice-breaker/data-access-supabase`
- `@ice-breaker/shared-utils`
