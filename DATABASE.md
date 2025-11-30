# IceBreaker Database Schema 🎮

Welcome to the IceBreaker game database! This schema is designed for **maximum fun** and engagement.

## Overview

The database is built on Supabase (PostgreSQL) with:
- 🎮 **10 tables** for complete game functionality
- 🔒 **Row Level Security** for data protection
- 🎯 **7 game functions** for easy API interactions
- ⭐ **Achievement system** for player progression
- 💬 **Reaction system** for engagement
- 📊 **Stats tracking** across games

## Core Concept

**Games, not Rooms!** We use game-focused terminology:
- `games` instead of rooms - each session is a game
- `players` instead of participants - you're playing a game!
- `rounds` instead of turns - structured gameplay
- `question_cards` instead of questions - feels like a card game
- **Reactions** - express yourself during gameplay
- **Achievements** - unlock as you play

---

## Tables

### 1. `card_categories` 🎴
Categories of question cards.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| name | TEXT | Unique name (laugh, think, flirt, wild) |
| display_name | TEXT | UI display name with emoji |
| description | TEXT | Category description |
| icon | TEXT | Emoji or icon name |
| color | TEXT | Hex color for UI |
| is_active | BOOLEAN | Whether category is available |
| sort_order | INTEGER | Display order |

**Default Categories:**
- 😂 **Laugh** - Light, funny questions
- 🤔 **Think** - Deep, thought-provoking
- 😍 **Flirt** - Playful, romantic
- 🎲 **Wild** - Completely random

---

### 2. `question_cards` 🃏
The actual question cards players draw.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| text | TEXT | The question |
| category_id | UUID | Card category |
| difficulty | INTEGER | 1-5 difficulty rating |
| spice_level | INTEGER | 1-5 boldness rating |
| is_active | BOOLEAN | Available for play |
| uses_count | INTEGER | How many times played |
| average_rating | NUMERIC | Player ratings |
| tags | TEXT[] | Filter tags |
| created_at | TIMESTAMPTZ | Creation time |
| created_by | UUID | Creator |

**Tags examples:** `'first-date'`, `'deep-dive'`, `'party'`, `'spicy'`

---

### 3. `games` 🎮
Game sessions (previously "rooms").

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | TEXT | 6-char join code (e.g., "ABC123") |
| name | TEXT | Optional game name |
| host_id | UUID | Game host (creator) |
| status | TEXT | lobby, playing, paused, finished, abandoned |
| game_mode | TEXT | classic, speed, deep-dive, party |
| max_players | INTEGER | 2-10 players |
| current_round | INTEGER | Current round number |
| total_rounds | INTEGER | Max rounds (NULL = unlimited) |
| settings | JSONB | Game configuration |
| created_at | TIMESTAMPTZ | Creation time |
| started_at | TIMESTAMPTZ | When game started |
| finished_at | TIMESTAMPTZ | When game ended |
| total_cards_played | INTEGER | Cards played this game |
| total_reactions | INTEGER | Reactions given this game |

**Game Modes:**
- **Classic** - Standard gameplay
- **Speed** - Quick rounds
- **Deep-Dive** - Only deep questions
- **Party** - Fun & wild only

**Settings Example:**
```json
{
  "categories_enabled": ["laugh", "think", "flirt"],
  "allow_skip": true,
  "round_timer_seconds": 300,
  "auto_next_round": false
}
```

---

### 4. `players` 👥
Participants in a game.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| game_id | UUID | The game they're in |
| user_id | UUID | User (NULL for guests) |
| display_name | TEXT | Name shown in game |
| avatar_url | TEXT | Profile picture |
| is_host | BOOLEAN | Is the game host |
| is_guest | BOOLEAN | No account required! |
| connection_status | TEXT | online, offline, away |
| peer_id | TEXT | WebRTC peer ID |
| cards_drawn | INTEGER | Cards drawn this game |
| reactions_given | INTEGER | Reactions given |
| reactions_received | INTEGER | Reactions received |
| favorite_cards | TEXT[] | Saved favorite cards |
| joined_at | TIMESTAMPTZ | When joined |
| left_at | TIMESTAMPTZ | When left (NULL if active) |
| last_seen_at | TIMESTAMPTZ | Last activity |

**Note:** Guests can play without authentication! 🎉

---

### 5. `rounds` 🔄
Individual rounds within a game.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| game_id | UUID | The game |
| round_number | INTEGER | Round # in game |
| current_player_id | UUID | Whose turn it is |
| current_card_id | UUID | Card being played |
| card_category_id | UUID | Category of card |
| status | TEXT | active, completed, skipped |
| started_at | TIMESTAMPTZ | Round start |
| completed_at | TIMESTAMPTZ | Round end |

---

### 6. `card_plays` 📝
History of cards played.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| game_id | UUID | The game |
| round_id | UUID | The round |
| card_id | UUID | Card that was played |
| player_id | UUID | Who played it |
| was_skipped | BOOLEAN | Did they skip? |
| time_spent_seconds | INTEGER | Discussion time |
| played_at | TIMESTAMPTZ | When played |

**Unique constraint:** Can't play same card twice in one game!

---

### 7. `reactions` 💕
Express yourself during gameplay!

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| card_play_id | UUID | Which card play |
| player_id | UUID | Who reacted |
| reaction_type | TEXT | Type of reaction |
| created_at | TIMESTAMPTZ | When reacted |

**Reaction Types:**
- ❤️ `love` - Loved it!
- 😂 `laugh` - Hilarious
- 🤯 `mind_blown` - Deep!
- 🔥 `fire` - Spicy!
- ⏭️ `skip` - Pass
- 💾 `save` - Favorite

---

### 8. `player_profiles` 👤
Persistent player data across games.

| Column | Type | Description |
|--------|------|-------------|
| user_id | UUID | Primary key |
| username | TEXT | Unique username |
| bio | TEXT | Player bio |
| avatar_url | TEXT | Profile picture |
| total_games_played | INTEGER | Lifetime games |
| total_games_hosted | INTEGER | Games hosted |
| total_cards_played | INTEGER | Cards drawn |
| total_reactions_given | INTEGER | Reactions given |
| total_reactions_received | INTEGER | Reactions received |
| favorite_category_id | UUID | Preferred category |
| achievements | JSONB | Unlocked achievements |
| preferences | JSONB | User preferences |
| created_at | TIMESTAMPTZ | Profile creation |
| updated_at | TIMESTAMPTZ | Last update |

---

### 9. `achievements` 🏆
Unlockable achievements.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | TEXT | Unique code |
| name | TEXT | Achievement name |
| description | TEXT | What it's for |
| icon | TEXT | Emoji/icon |
| category | TEXT | social, conversation, host, engagement, special |
| rarity | TEXT | common, rare, epic, legendary |
| criteria | JSONB | Unlock requirements |

**Example Achievements:**
- 🎮 **Icebreaker Master** - Host your first game
- 🦋 **Social Butterfly** - Play with 10 different people
- 🧠 **Deep Thinker** - Play 25 Think cards
- 👑 **Legendary Connector** - Play 50 games

---

### 10. `player_achievements` ⭐
Achievements unlocked by players.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| player_profile_id | UUID | Player who unlocked |
| achievement_id | UUID | Which achievement |
| unlocked_at | TIMESTAMPTZ | When unlocked |
| game_id | UUID | Game where unlocked |

---

## Game Functions (The Fun API!)

### `create_game(...)` 🎮
Create a new game!

**Parameters:**
- `p_name` (TEXT, optional) - Game name
- `p_game_mode` (TEXT, default: 'classic') - Game mode
- `p_max_players` (INTEGER, default: 2) - Max players (2-10)
- `p_total_rounds` (INTEGER, optional) - Max rounds
- `p_settings` (JSONB, optional) - Game settings

**Returns:** `games` record

**Example:**
```sql
SELECT * FROM create_game('Friday Night Fun', 'party', 4, 10);
```

---

### `join_game(...)` 🚪
Join an existing game!

**Parameters:**
- `p_game_code` (TEXT) - 6-char game code
- `p_display_name` (TEXT) - Your name
- `p_avatar_url` (TEXT, optional) - Profile pic

**Returns:** `players` record

**Raises:**
- Game not found
- Game already started
- Game is full
- Display name taken

**Example:**
```sql
SELECT * FROM join_game('ABC123', 'John Doe');
```

---

### `start_game(...)` ▶️
Start the game! (Host only)

**Parameters:**
- `p_game_id` (UUID) - The game to start

**Returns:** `games` record (updated)

**Raises:**
- Not the host
- Already started
- Need at least 2 players

**Example:**
```sql
SELECT * FROM start_game('game-uuid-here');
```

---

### `draw_card(...)` 🎴
Draw a random card for your turn!

**Parameters:**
- `p_game_id` (UUID) - The game
- `p_category_name` (TEXT, optional) - Filter by category

**Returns:** `question_cards` record

**Raises:**
- No active round
- Not your turn
- No cards available

**Example:**
```sql
-- Random card from any category
SELECT * FROM draw_card('game-uuid');

-- Specific category
SELECT * FROM draw_card('game-uuid', 'laugh');
```

---

### `play_card(...)` ✅
Complete the round and move to next player!

**Parameters:**
- `p_game_id` (UUID) - The game
- `p_card_id` (UUID) - Card that was played
- `p_was_skipped` (BOOLEAN, default: false) - Did they skip?
- `p_time_spent_seconds` (INTEGER, optional) - Discussion time

**Returns:** `rounds` record (next round)

**Example:**
```sql
SELECT * FROM play_card('game-uuid', 'card-uuid', false, 180);
```

---

### `add_reaction(...)` 💕
React to a card play!

**Parameters:**
- `p_card_play_id` (UUID) - The card play
- `p_reaction_type` (TEXT) - love, laugh, mind_blown, fire, skip, save

**Returns:** `reactions` record

**Example:**
```sql
SELECT * FROM add_reaction('card-play-uuid', 'love');
```

---

### `leave_game(...)` 👋
Leave the game.

**Parameters:**
- `p_game_id` (UUID) - The game to leave

**Returns:** BOOLEAN (true if successful)

**Example:**
```sql
SELECT leave_game('game-uuid');
```

---

## Realtime Subscriptions

Subscribe to live updates:

```typescript
// Listen for players joining/leaving
supabase
  .channel('game-players')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'players',
    filter: `game_id=eq.${gameId}`
  }, handlePlayerUpdate)
  .subscribe();

// Listen for round changes
supabase
  .channel('game-rounds')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'rounds',
    filter: `game_id=eq.${gameId}`
  }, handleRoundUpdate)
  .subscribe();

// Listen for reactions
supabase
  .channel('game-reactions')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'reactions'
  }, handleNewReaction)
  .subscribe();
```

---

## Migrations

Located in `supabase/migrations/`:

1. **20251130180000_game_schema.sql** - Core tables and structure
2. **20251130180100_seed_game_data.sql** - Categories, cards, achievements
3. **20251130180200_rls_policies.sql** - Security policies
4. **20251130180300_game_functions.sql** - Game API functions

### Apply Locally
```bash
supabase start
supabase db reset
```

### Apply to Production
Automatic via GitHub Actions deploy workflow.

---

## Game Flow Example

```sql
-- 1. Host creates game
SELECT * FROM create_game('Friday Fun', 'classic', 4);
-- Returns: { code: 'ABC123', ... }

-- 2. Players join
SELECT * FROM join_game('ABC123', 'Alice');
SELECT * FROM join_game('ABC123', 'Bob');
SELECT * FROM join_game('ABC123', 'Charlie');

-- 3. Host starts game
SELECT * FROM start_game('game-uuid');

-- 4. Player 1 draws card
SELECT * FROM draw_card('game-uuid', 'laugh');

-- 5. Other players react
SELECT * FROM add_reaction('card-play-uuid', 'laugh');
SELECT * FROM add_reaction('card-play-uuid', 'love');

-- 6. Complete round and move to next player
SELECT * FROM play_card('game-uuid', 'card-uuid', false, 120);

-- 7. Repeat steps 4-6 until game ends!
```

---

## Security

✅ Row Level Security enabled on all tables
✅ Guests can play without authentication
✅ Players can only see their own game data
✅ Hosts control game settings
✅ No duplicate cards per game

---

## What Makes This Fun? 🎉

1. **Game Language** - Everything uses game terminology
2. **Reactions** - Express yourself with emojis!
3. **Achievements** - Unlock as you play
4. **Stats Tracking** - See your progress
5. **Multiple Game Modes** - Different ways to play
6. **Guest Access** - No barriers to entry
7. **Round Structure** - Clear progression
8. **Spice Levels** - Control how bold questions get
9. **Favorite Cards** - Save the best ones
10. **Popularity Tracking** - See which cards are loved

Ready to build something awesome? Let's go! 🚀
