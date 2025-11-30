# @ice-breaker/shared-models

TypeScript models and types for the IceBreaker game application.

## Overview

This package provides type-safe interfaces for:
- Database tables
- API requests/responses
- UI view models
- Enums and constants

## Installation

```bash
# In workspace root or app directory
pnpm add @ice-breaker/shared-models@workspace:*
```

## Usage

### Import Database Types

```typescript
import { Game, Player, QuestionCard } from '@ice-breaker/shared-models';

const game: Game = {
  id: '123',
  code: 'ABC123',
  status: GameStatus.LOBBY,
  // ... other fields
};
```

### Import Enums

```typescript
import { GameStatus, ReactionType, REACTION_EMOJIS } from '@ice-breaker/shared-models';

if (game.status === GameStatus.PLAYING) {
  console.log('Game is active!');
}

const emoji = REACTION_EMOJIS[ReactionType.LOVE]; // ❤️
```

### Import API Types

```typescript
import { CreateGameParams, CreateGameResponse } from '@ice-breaker/shared-models';

const params: CreateGameParams = {
  name: 'Friday Fun',
  gameMode: GameMode.CLASSIC,
  maxPlayers: 4,
};

const response: CreateGameResponse = await createGame(params);
```

### Import UI Types

```typescript
import { GameWithPlayers, ActiveGameView } from '@ice-breaker/shared-models';

const gameView: GameWithPlayers = {
  ...game,
  players: [...],
  current_round_data: {...},
};
```

## Structure

### `enums.ts`
Enums matching database constraints:
- `GameStatus` - lobby, playing, paused, finished, abandoned
- `GameMode` - classic, speed, deep-dive, party
- `PlayerConnectionStatus` - online, offline, away
- `RoundStatus` - active, completed, skipped
- `ReactionType` - love, laugh, mind_blown, fire, skip, save
- `CardCategoryName` - laugh, think, flirt, wild
- `AchievementCategory` - social, conversation, host, engagement, special
- `AchievementRarity` - common, rare, epic, legendary

Helper constants:
- `CATEGORY_EMOJIS` - Emoji for each category
- `REACTION_EMOJIS` - Emoji for each reaction
- `REACTION_LABELS` - Display labels for reactions

### `database.types.ts`
Interfaces matching database tables:
- `CardCategory` - Question card categories
- `QuestionCard` - Individual question cards
- `Game` - Game sessions
- `Player` - Players in games
- `Round` - Individual rounds
- `CardPlay` - Card play history
- `Reaction` - Player reactions
- `PlayerProfile` - Cross-game player data
- `Achievement` - Available achievements
- `PlayerAchievement` - Unlocked achievements

JSONB type interfaces:
- `GameSettings` - Game configuration
- `PlayerPreferences` - User preferences
- `AchievementCriteria` - Unlock requirements

### `api.types.ts`
Request/response types for database functions:
- `CreateGameParams` / `CreateGameResponse`
- `JoinGameParams` / `JoinGameResponse`
- `StartGameParams` / `StartGameResponse`
- `DrawCardParams` / `DrawCardResponse`
- `PlayCardParams` / `PlayCardResponse`
- `AddReactionParams` / `AddReactionResponse`
- `LeaveGameParams` / `LeaveGameResponse`

Generic wrappers:
- `ApiResponse<T>` - Standard response format
- `GameError` - Error response

### `ui.types.ts`
UI-specific view models:
- `GameWithPlayers` - Game with populated players
- `PlayerWithStats` - Player with calculated stats
- `RoundWithDetails` - Round with card and player info
- `CardPlayWithDetails` - Card play with reactions
- `GameLobbyView` - Lobby screen data
- `ActiveGameView` - Active game screen data
- `GameSummary` - Game results summary

Realtime event types:
- `PlayerJoinedEvent`
- `PlayerLeftEvent`
- `GameStartedEvent`
- `RoundChangedEvent`
- `CardDrawnEvent`
- `ReactionAddedEvent`

Form data types:
- `CreateGameFormData`
- `JoinGameFormData`

Filter types:
- `CardFilter`
- `GameFilter`

## Type Safety

All types are strictly typed and match the database schema exactly. This ensures:
- ✅ Compile-time type checking
- ✅ IntelliSense autocomplete
- ✅ Refactoring safety
- ✅ Documentation through types

## Examples

### Creating a Game

```typescript
import { Game, GameStatus, GameMode } from '@ice-breaker/shared-models';

const newGame: Partial<Game> = {
  code: 'ABC123',
  name: 'Friday Fun',
  status: GameStatus.LOBBY,
  game_mode: GameMode.PARTY,
  max_players: 4,
  settings: {
    categories_enabled: ['laugh', 'wild'],
    allow_skip: true,
    round_timer_seconds: 300,
    auto_next_round: false,
  },
};
```

### Checking Player Status

```typescript
import { Player, PlayerConnectionStatus } from '@ice-breaker/shared-models';

function isPlayerActive(player: Player): boolean {
  return (
    player.connection_status === PlayerConnectionStatus.ONLINE &&
    player.left_at === null
  );
}
```

### Displaying Reactions

```typescript
import { REACTION_EMOJIS, REACTION_LABELS, ReactionType } from '@ice-breaker/shared-models';

function displayReaction(type: ReactionType) {
  const emoji = REACTION_EMOJIS[type];
  const label = REACTION_LABELS[type];
  return `${emoji} ${label}`;
}

// Usage
displayReaction(ReactionType.LOVE); // "❤️ Love it!"
```

## Development

This is a TypeScript-only package - no build step required. Apps import the TypeScript source directly.

## License

Private - Part of IceBreaker monorepo
