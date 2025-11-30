# @ice-breaker/data-access-supabase

Supabase client library for the IceBreaker game with full TypeScript support.

## Overview

This package provides:
- Configured Supabase client
- Type-safe game API functions
- Realtime subscription helpers
- Authentication services
- Error handling utilities

## Installation

```bash
# In your app's package.json
pnpm add @ice-breaker/data-access-supabase@workspace:*
```

## Setup

### 1. Initialize Supabase Client

```typescript
import { initializeSupabase } from '@ice-breaker/data-access-supabase';

// In your app initialization (e.g., Angular app.config.ts)
const supabase = initializeSupabase({
  url: environment.supabaseUrl,
  anonKey: environment.supabaseAnonKey,
});
```

### 2. Environment Variables

Create environment files:

```typescript
// environment.ts
export const environment = {
  supabaseUrl: 'https://your-project.supabase.co',
  supabaseAnonKey: 'your-anon-key',
};
```

## Usage

### Game Functions

#### Create a Game

```typescript
import { createGame } from '@ice-breaker/data-access-supabase';
import { GameMode } from '@ice-breaker/shared-models';

const { data, error } = await createGame({
  name: 'Friday Fun',
  gameMode: GameMode.PARTY,
  maxPlayers: 4,
  totalRounds: 10,
  settings: {
    categories_enabled: ['laugh', 'flirt'],
    allow_skip: true,
    round_timer_seconds: 300,
    auto_next_round: false,
  },
});

if (error) {
  console.error('Failed to create game:', error.message);
} else {
  console.log('Game created:', data.code);
}
```

#### Join a Game

```typescript
import { joinGame } from '@ice-breaker/data-access-supabase';

const { data, error } = await joinGame({
  gameCode: 'ABC123',
  displayName: 'John Doe',
  avatarUrl: 'https://example.com/avatar.jpg',
});

if (error) {
  console.error('Failed to join:', error.message);
} else {
  console.log('Joined as:', data.display_name);
}
```

#### Start a Game

```typescript
import { startGame } from '@ice-breaker/data-access-supabase';

const { data, error } = await startGame(gameId);

if (error) {
  console.error('Failed to start game:', error.message);
} else {
  console.log('Game started!', data.status);
}
```

#### Draw a Card

```typescript
import { drawCard } from '@ice-breaker/data-access-supabase';

// Random card from any category
const { data: card, error } = await drawCard({
  gameId: gameId,
});

// Card from specific category
const { data: laughCard } = await drawCard({
  gameId: gameId,
  categoryName: 'laugh',
});
```

#### Play a Card

```typescript
import { playCard } from '@ice-breaker/data-access-supabase';

const { data: nextRound, error } = await playCard({
  gameId: gameId,
  cardId: card.id,
  wasSkipped: false,
  timeSpentSeconds: 180,
});
```

#### Add a Reaction

```typescript
import { addReaction } from '@ice-breaker/data-access-supabase';
import { ReactionType } from '@ice-breaker/shared-models';

const { data, error } = await addReaction({
  cardPlayId: cardPlayId,
  reactionType: ReactionType.LOVE,
});
```

#### Leave a Game

```typescript
import { leaveGame } from '@ice-breaker/data-access-supabase';

const { data, error } = await leaveGame(gameId);
```

### Query Functions

#### Get Game by Code

```typescript
import { getGameByCode } from '@ice-breaker/data-access-supabase';

const { data: game, error } = await getGameByCode('ABC123');
```

#### Get Game Players

```typescript
import { getGamePlayers } from '@ice-breaker/data-access-supabase';

const { data: players, error } = await getGamePlayers(gameId);
```

#### Get Current Round

```typescript
import { getCurrentRound } from '@ice-breaker/data-access-supabase';

const { data: round, error } = await getCurrentRound(gameId);
```

### Realtime Subscriptions

#### Subscribe to Player Changes

```typescript
import { subscribeToPlayers, unsubscribe } from '@ice-breaker/data-access-supabase';

const channel = subscribeToPlayers(gameId, {
  onJoined: (event) => {
    console.log('Player joined:', event.player.display_name);
  },
  onLeft: (event) => {
    console.log('Player left:', event.playerId);
  },
  onUpdated: (player) => {
    console.log('Player updated:', player);
  },
});

// Later, unsubscribe
await unsubscribe(channel);
```

#### Subscribe to Game Changes

```typescript
import { subscribeToGame } from '@ice-breaker/data-access-supabase';

const channel = subscribeToGame(gameId, {
  onStarted: (event) => {
    console.log('Game started!', event.game);
  },
  onFinished: (game) => {
    console.log('Game finished!', game);
  },
  onUpdated: (game) => {
    console.log('Game updated:', game);
  },
});
```

#### Subscribe to Rounds

```typescript
import { subscribeToRounds } from '@ice-breaker/data-access-supabase';

const channel = subscribeToRounds(gameId, {
  onRoundChanged: (event) => {
    console.log('New round:', event.round.round_number);
    console.log('Next player:', event.nextPlayer.display_name);
  },
  onRoundCompleted: (round) => {
    console.log('Round completed:', round.round_number);
  },
});
```

#### Subscribe to Reactions

```typescript
import { subscribeToReactions } from '@ice-breaker/data-access-supabase';

const channel = subscribeToReactions(gameId, (event) => {
  console.log(`${event.player.display_name} reacted with ${event.reaction.reaction_type}`);
});
```

### Authentication (for Game Hosts)

```typescript
import { signUp, signIn, signOut, getUser, onAuthStateChange } from '@ice-breaker/data-access-supabase';

// Sign up
const { data, error } = await signUp({
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
});

// Sign in
const { data, error } = await signIn({
  email: 'user@example.com',
  password: 'password123',
});

// Sign out
await signOut();

// Get current user
const user = await getUser();

// Listen to auth changes
const subscription = onAuthStateChange((user) => {
  if (user) {
    console.log('User signed in:', user.email);
  } else {
    console.log('User signed out');
  }
});

// Unsubscribe later
subscription.unsubscribe();
```

### Error Handling

```typescript
import { mapSupabaseError, isNetworkError, isAuthError } from '@ice-breaker/data-access-supabase';

const { data, error } = await createGame(params);

if (error) {
  const friendlyError = mapSupabaseError(error);

  if (isNetworkError(error)) {
    console.error('Network error:', friendlyError.message);
  } else if (isAuthError(error)) {
    console.error('Authentication error:', friendlyError.message);
  } else {
    console.error('Error:', friendlyError.message);
  }
}
```

## Angular Integration Example

```typescript
// game.service.ts
import { Injectable, inject } from '@angular/core';
import {
  createGame,
  joinGame,
  getGamePlayers,
  subscribeToPlayers,
  type CreateGameParams
} from '@ice-breaker/data-access-supabase';
import { BehaviorSubject } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class GameService {
  private playersSubject = new BehaviorSubject<Player[]>([]);
  players$ = this.playersSubject.asObservable();

  async createGame(params: CreateGameParams) {
    const { data, error } = await createGame(params);
    if (error) throw new Error(error.message);
    return data;
  }

  async joinGame(code: string, name: string) {
    const { data, error } = await joinGame({
      gameCode: code,
      displayName: name
    });
    if (error) throw new Error(error.message);
    return data;
  }

  subscribeToPlayers(gameId: string) {
    return subscribeToPlayers(gameId, {
      onJoined: () => this.refreshPlayers(gameId),
      onLeft: () => this.refreshPlayers(gameId),
      onUpdated: () => this.refreshPlayers(gameId),
    });
  }

  private async refreshPlayers(gameId: string) {
    const { data } = await getGamePlayers(gameId);
    if (data) {
      this.playersSubject.next(data);
    }
  }
}
```

## Type Safety

All functions use types from `@ice-breaker/shared-models`:

```typescript
import type {
  Game,
  Player,
  QuestionCard,
  GameMode,
  ReactionType
} from '@ice-breaker/shared-models';
```

This ensures:
- ✅ Autocomplete in your IDE
- ✅ Compile-time type checking
- ✅ Consistent types across frontend and backend

## API Reference

### Configuration
- `initializeSupabase(config)` - Initialize Supabase client
- `getSupabase()` - Get initialized client
- `isSupabaseInitialized()` - Check if initialized

### Game Functions
- `createGame(params)` - Create new game
- `joinGame(params)` - Join existing game
- `startGame(gameId)` - Start game (host only)
- `drawCard(params)` - Draw question card
- `playCard(params)` - Play card and advance round
- `addReaction(params)` - React to card play
- `leaveGame(gameId)` - Leave game

### Query Functions
- `getGame(gameId)` - Get game by ID
- `getGameByCode(code)` - Get game by join code
- `getGamePlayers(gameId)` - Get players in game
- `getCurrentRound(gameId)` - Get active round

### Realtime
- `subscribeToPlayers(gameId, handlers)` - Subscribe to player changes
- `subscribeToGame(gameId, handlers)` - Subscribe to game changes
- `subscribeToRounds(gameId, handlers)` - Subscribe to round changes
- `subscribeToReactions(gameId, handler)` - Subscribe to reactions
- `unsubscribe(channel)` - Unsubscribe from channel
- `unsubscribeAll()` - Unsubscribe from all

### Auth
- `signUp(params)` - Register new user
- `signIn(params)` - Sign in user
- `signOut()` - Sign out current user
- `getSession()` - Get current session
- `getUser()` - Get current user
- `onAuthStateChange(callback)` - Listen to auth changes

### Utilities
- `mapSupabaseError(error)` - Map error to friendly message
- `isNetworkError(error)` - Check if network error
- `isAuthError(error)` - Check if auth error
- `isValidationError(error)` - Check if validation error

## License

Private - Part of IceBreaker monorepo
