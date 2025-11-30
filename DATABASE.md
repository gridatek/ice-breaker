# Database Schema Documentation

This document describes the database schema for the IceBreaker application.

## Overview

The IceBreaker database is built on Supabase (PostgreSQL) and includes:
- 6 main tables with relationships
- Row Level Security (RLS) policies for access control
- Helper functions for common operations
- Automated triggers for timestamps
- Seed data for question categories

## Tables

### `question_categories`
Stores the different types of questions available.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| name | TEXT | Unique category name (fun, deep, flirty, random) |
| description | TEXT | Category description |
| color | TEXT | Hex color code for UI |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |

**RLS Policies:**
- Everyone can read categories
- Only authenticated users can create/update

---

### `questions`
Pool of conversation starter questions.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| text | TEXT | The question text |
| category_id | UUID | Foreign key to question_categories |
| is_active | BOOLEAN | Whether question is available for use |
| difficulty_level | INTEGER | Difficulty rating (1-5) |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| created_by | UUID | Foreign key to auth.users |

**Indexes:**
- `idx_questions_active` - For filtering active questions
- `idx_questions_category` - For category-based queries

**RLS Policies:**
- Everyone can view active questions
- Authenticated users can view all questions
- Authenticated users can create questions
- Users can update their own questions

---

### `rooms`
Game rooms where participants meet and play.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | TEXT | Unique 6-character join code |
| name | TEXT | Optional room name |
| creator_id | UUID | Foreign key to auth.users |
| status | TEXT | Room status (waiting, active, completed, cancelled) |
| max_participants | INTEGER | Maximum number of participants (2-10) |
| settings | JSONB | Room configuration (question preferences, etc.) |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |
| started_at | TIMESTAMPTZ | When game started |
| ended_at | TIMESTAMPTZ | When game ended |

**Indexes:**
- `idx_rooms_code` - For fast code lookups
- `idx_rooms_status` - For filtering by status
- `idx_rooms_creator` - For creator queries

**RLS Policies:**
- Users can view rooms they created or are participating in
- Anyone can view rooms by code (for joining)
- Authenticated users can create rooms
- Creators can update/delete their rooms

---

### `participants`
People in a room (creators with auth, guests without).

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| room_id | UUID | Foreign key to rooms |
| user_id | UUID | Foreign key to auth.users (NULL for guests) |
| display_name | TEXT | Name shown in room |
| is_creator | BOOLEAN | Whether this is the room creator |
| is_guest | BOOLEAN | Whether this is a guest (no auth) |
| connection_status | TEXT | WebRTC connection status |
| peer_id | TEXT | WebRTC peer ID |
| joined_at | TIMESTAMPTZ | When participant joined |
| left_at | TIMESTAMPTZ | When participant left (NULL if still present) |

**Constraints:**
- Unique (room_id, user_id)
- Unique (room_id, display_name)

**Indexes:**
- `idx_participants_room` - For room-based queries
- `idx_participants_user` - For user-based queries

**RLS Policies:**
- Participants can view others in their room
- Anyone can join as participant
- Users can update/delete their own participant record

---

### `game_sessions`
Active game state for a room.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| room_id | UUID | Foreign key to rooms (unique) |
| current_turn_participant_id | UUID | Foreign key to participants |
| current_question_id | UUID | Foreign key to questions |
| turn_number | INTEGER | Current turn number |
| status | TEXT | Session status (active, paused, completed) |
| settings | JSONB | Game settings |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |

**Constraints:**
- One game session per room

**Indexes:**
- `idx_game_sessions_room` - For room-based queries

**RLS Policies:**
- Participants can view game sessions for their rooms
- Room creators can create sessions
- Participants can update sessions

---

### `question_history`
Tracks which questions have been asked in a session.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| game_session_id | UUID | Foreign key to game_sessions |
| question_id | UUID | Foreign key to questions |
| participant_id | UUID | Foreign key to participants |
| turn_number | INTEGER | Turn when question was asked |
| asked_at | TIMESTAMPTZ | When question was asked |

**Constraints:**
- Unique (game_session_id, question_id) - Prevents duplicate questions

**Indexes:**
- `idx_question_history_session` - For session-based queries
- `idx_question_history_turn` - For turn-based queries

**RLS Policies:**
- Participants can view history for their sessions
- Participants can add to history

## Helper Functions

### `generate_room_code()`
Generates a unique 6-character room code.

**Returns:** `TEXT`

**Usage:**
```sql
SELECT generate_room_code();
-- Returns: 'ABC123'
```

---

### `create_room(p_name, p_max_participants, p_settings)`
Creates a new room with a unique code and adds creator as first participant.

**Parameters:**
- `p_name` (TEXT, optional) - Room name
- `p_max_participants` (INTEGER, default: 2) - Maximum participants
- `p_settings` (JSONB, default: {}) - Room settings

**Returns:** `rooms` record

**Usage:**
```sql
SELECT * FROM create_room('My Room', 4, '{"categories": ["fun", "deep"]}'::jsonb);
```

---

### `join_room(p_room_code, p_display_name)`
Joins a room as guest or authenticated user.

**Parameters:**
- `p_room_code` (TEXT) - The room code
- `p_display_name` (TEXT) - Display name for participant

**Returns:** `participants` record

**Raises:**
- Exception if room not found
- Exception if room is full
- Exception if display name already taken

**Usage:**
```sql
SELECT * FROM join_room('ABC123', 'John Doe');
```

---

### `start_game_session(p_room_id, p_settings)`
Starts a game session for a room.

**Parameters:**
- `p_room_id` (UUID) - The room ID
- `p_settings` (JSONB, default: {}) - Game settings

**Returns:** `game_sessions` record

**Raises:**
- Exception if room not found
- Exception if user is not creator
- Exception if session already exists

**Usage:**
```sql
SELECT * FROM start_game_session('room-uuid-here');
```

---

### `draw_question(p_game_session_id, p_category_name)`
Draws a random question that hasn't been used in the session.

**Parameters:**
- `p_game_session_id` (UUID) - The game session ID
- `p_category_name` (TEXT, optional) - Filter by category

**Returns:** `questions` record

**Raises:**
- Exception if no available questions found

**Usage:**
```sql
-- Random question from any category
SELECT * FROM draw_question('session-uuid-here');

-- Random question from specific category
SELECT * FROM draw_question('session-uuid-here', 'fun');
```

---

### `next_turn(p_game_session_id, p_question_id)`
Advances to next turn and records question in history.

**Parameters:**
- `p_game_session_id` (UUID) - The game session ID
- `p_question_id` (UUID) - The question that was asked

**Returns:** `game_sessions` record (updated)

**Usage:**
```sql
SELECT * FROM next_turn('session-uuid-here', 'question-uuid-here');
```

## Migrations

Migrations are located in `supabase/migrations/` and are applied in order:

1. `20251130172934_initial_schema.sql` - Core tables and indexes
2. `20251130173000_seed_categories.sql` - Question categories and sample questions
3. `20251130173100_rls_policies.sql` - Row Level Security policies
4. `20251130173200_functions.sql` - Helper functions

### Applying Migrations Locally

```bash
# Start local Supabase
supabase start

# Apply migrations
supabase db reset

# Or push to remote
supabase db push
```

### Applying Migrations to Production

Migrations are automatically applied via GitHub Actions deploy workflow when:
1. You push to main branch (if auto-deploy enabled)
2. You manually trigger the deploy workflow

## Realtime Subscriptions

The following tables support Supabase Realtime subscriptions:

- `rooms` - Listen for room status changes
- `participants` - Listen for participants joining/leaving
- `game_sessions` - Listen for turn changes
- `question_history` - Listen for new questions being asked

**Example subscription:**
```typescript
supabase
  .channel('room-changes')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'participants',
    filter: `room_id=eq.${roomId}`
  }, (payload) => {
    console.log('Participant update:', payload);
  })
  .subscribe();
```

## Security Considerations

1. **RLS Policies**: All tables have Row Level Security enabled
2. **Guest Access**: Guests can participate without authentication
3. **Room Codes**: 6-character codes use unambiguous characters (no O/0, I/1)
4. **Creator Control**: Only room creators can start games and modify room settings
5. **No Duplicate Questions**: Enforced at database level per session
