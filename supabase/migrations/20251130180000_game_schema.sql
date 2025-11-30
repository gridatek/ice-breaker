-- IceBreaker Game Schema - Fun & Engaging Edition! 🎮
-- Built for maximum fun, engagement, and memorable conversations

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- CARD CATEGORIES (Question Types)
-- ============================================================================
CREATE TABLE card_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  description TEXT,
  icon TEXT, -- emoji or icon name
  color TEXT, -- hex color for UI
  is_active BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE card_categories IS 'Categories of question cards (Laugh, Think, Flirt, Wild)';

-- ============================================================================
-- QUESTION CARDS (The actual questions)
-- ============================================================================
CREATE TABLE question_cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  text TEXT NOT NULL,
  category_id UUID REFERENCES card_categories(id) ON DELETE SET NULL,
  difficulty INTEGER CHECK (difficulty BETWEEN 1 AND 5) DEFAULT 3,
  spice_level INTEGER CHECK (spice_level BETWEEN 1 AND 5) DEFAULT 3,
  is_active BOOLEAN NOT NULL DEFAULT true,
  uses_count INTEGER NOT NULL DEFAULT 0, -- track popularity
  average_rating NUMERIC(3,2) CHECK (average_rating BETWEEN 0 AND 5),
  tags TEXT[], -- for filtering: 'first-date', 'deep-dive', 'party', etc.
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

CREATE INDEX idx_cards_active ON question_cards(is_active) WHERE is_active = true;
CREATE INDEX idx_cards_category ON question_cards(category_id);
CREATE INDEX idx_cards_difficulty ON question_cards(difficulty);
CREATE INDEX idx_cards_tags ON question_cards USING gin(tags);

COMMENT ON TABLE question_cards IS 'Pool of conversation starter cards';
COMMENT ON COLUMN question_cards.spice_level IS 'How bold/daring the question is (1=safe, 5=spicy)';

-- ============================================================================
-- GAMES (Game Sessions)
-- ============================================================================
CREATE TABLE games (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT NOT NULL UNIQUE, -- 6-char join code
  name TEXT, -- optional game name
  host_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'lobby' CHECK (status IN ('lobby', 'playing', 'paused', 'finished', 'abandoned')),
  game_mode TEXT NOT NULL DEFAULT 'classic' CHECK (game_mode IN ('classic', 'speed', 'deep-dive', 'party')),
  max_players INTEGER NOT NULL DEFAULT 2 CHECK (max_players BETWEEN 2 AND 10),
  current_round INTEGER NOT NULL DEFAULT 0,
  total_rounds INTEGER CHECK (total_rounds > 0),

  -- Game Settings
  settings JSONB NOT NULL DEFAULT '{
    "categories_enabled": ["laugh", "think", "flirt", "wild"],
    "allow_skip": true,
    "round_timer_seconds": 300,
    "auto_next_round": false,
    "show_player_stats": true
  }'::jsonb,

  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  finished_at TIMESTAMPTZ,

  -- Stats
  total_cards_played INTEGER NOT NULL DEFAULT 0,
  total_reactions INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_games_code ON games(code);
CREATE INDEX idx_games_status ON games(status);
CREATE INDEX idx_games_host ON games(host_id);

COMMENT ON TABLE games IS 'Individual game sessions';
COMMENT ON COLUMN games.game_mode IS 'Different game modes with unique rules';

-- ============================================================================
-- PLAYERS (Game Participants)
-- ============================================================================
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  display_name TEXT NOT NULL,
  avatar_url TEXT,
  is_host BOOLEAN NOT NULL DEFAULT false,
  is_guest BOOLEAN NOT NULL DEFAULT true,

  -- Connection & Status
  connection_status TEXT NOT NULL DEFAULT 'offline' CHECK (connection_status IN ('online', 'offline', 'away')),
  peer_id TEXT, -- WebRTC peer ID

  -- Game Stats (per game)
  cards_drawn INTEGER NOT NULL DEFAULT 0,
  reactions_given INTEGER NOT NULL DEFAULT 0,
  reactions_received INTEGER NOT NULL DEFAULT 0,
  favorite_cards TEXT[] DEFAULT ARRAY[]::TEXT[], -- array of card IDs they favorited

  -- Timestamps
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(game_id, display_name),
  CHECK(left_at IS NULL OR left_at >= joined_at)
);

CREATE INDEX idx_players_game ON players(game_id);
CREATE INDEX idx_players_user ON players(user_id);
CREATE INDEX idx_players_status ON players(connection_status) WHERE left_at IS NULL;

COMMENT ON TABLE players IS 'Participants in a game (host + guests)';
COMMENT ON COLUMN players.is_guest IS 'No auth required - jump right in!';

-- ============================================================================
-- ROUNDS (Structured Gameplay)
-- ============================================================================
CREATE TABLE rounds (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  round_number INTEGER NOT NULL,
  current_player_id UUID REFERENCES players(id) ON DELETE SET NULL,
  current_card_id UUID REFERENCES question_cards(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'skipped')),

  -- Round Data
  card_category_id UUID REFERENCES card_categories(id),
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,

  UNIQUE(game_id, round_number)
);

CREATE INDEX idx_rounds_game ON rounds(game_id);
CREATE INDEX idx_rounds_status ON rounds(status);

COMMENT ON TABLE rounds IS 'Individual rounds within a game';

-- ============================================================================
-- CARD PLAYS (Track which cards were played)
-- ============================================================================
CREATE TABLE card_plays (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  round_id UUID NOT NULL REFERENCES rounds(id) ON DELETE CASCADE,
  card_id UUID NOT NULL REFERENCES question_cards(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id) ON DELETE SET NULL,

  -- Play Details
  was_skipped BOOLEAN NOT NULL DEFAULT false,
  time_spent_seconds INTEGER, -- how long they discussed

  -- Timestamps
  played_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(game_id, card_id) -- can't play same card twice in one game
);

CREATE INDEX idx_card_plays_game ON card_plays(game_id);
CREATE INDEX idx_card_plays_round ON card_plays(round_id);
CREATE INDEX idx_card_plays_card ON card_plays(card_id);

COMMENT ON TABLE card_plays IS 'History of cards played in games';

-- ============================================================================
-- REACTIONS (Express yourself!)
-- ============================================================================
CREATE TABLE reactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  card_play_id UUID NOT NULL REFERENCES card_plays(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  reaction_type TEXT NOT NULL CHECK (reaction_type IN ('love', 'laugh', 'mind_blown', 'fire', 'skip', 'save')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(card_play_id, player_id, reaction_type)
);

CREATE INDEX idx_reactions_card_play ON reactions(card_play_id);
CREATE INDEX idx_reactions_player ON reactions(player_id);
CREATE INDEX idx_reactions_type ON reactions(reaction_type);

COMMENT ON TABLE reactions IS 'Player reactions to cards (love it, funny, deep, etc.)';

-- ============================================================================
-- PLAYER PROFILES (Cross-game stats & achievements)
-- ============================================================================
CREATE TABLE player_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  bio TEXT,
  avatar_url TEXT,

  -- Lifetime Stats
  total_games_played INTEGER NOT NULL DEFAULT 0,
  total_games_hosted INTEGER NOT NULL DEFAULT 0,
  total_cards_played INTEGER NOT NULL DEFAULT 0,
  total_reactions_given INTEGER NOT NULL DEFAULT 0,
  total_reactions_received INTEGER NOT NULL DEFAULT 0,
  favorite_category_id UUID REFERENCES card_categories(id),

  -- Achievements
  achievements JSONB NOT NULL DEFAULT '[]'::jsonb,

  -- Preferences
  preferences JSONB NOT NULL DEFAULT '{
    "default_game_mode": "classic",
    "preferred_categories": [],
    "notification_settings": {}
  }'::jsonb,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_username ON player_profiles(username);

COMMENT ON TABLE player_profiles IS 'Persistent player profiles with stats and achievements';

-- ============================================================================
-- ACHIEVEMENTS (Unlock the fun!)
-- ============================================================================
CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code TEXT NOT NULL UNIQUE, -- e.g., 'icebreaker_master', 'deep_thinker'
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT, -- emoji or icon name
  category TEXT NOT NULL CHECK (category IN ('social', 'conversation', 'host', 'engagement', 'special')),
  rarity TEXT NOT NULL CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')) DEFAULT 'common',

  -- Unlock Criteria (stored as JSONB for flexibility)
  criteria JSONB NOT NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_achievements_code ON achievements(code);
CREATE INDEX idx_achievements_category ON achievements(category);

COMMENT ON TABLE achievements IS 'Available achievements players can unlock';
COMMENT ON COLUMN achievements.criteria IS 'JSON defining unlock requirements';

-- ============================================================================
-- PLAYER ACHIEVEMENTS (Unlocked achievements)
-- ============================================================================
CREATE TABLE player_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  player_profile_id UUID NOT NULL REFERENCES player_profiles(user_id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  game_id UUID REFERENCES games(id) ON DELETE SET NULL, -- which game unlocked it

  UNIQUE(player_profile_id, achievement_id)
);

CREATE INDEX idx_player_achievements_profile ON player_achievements(player_profile_id);
CREATE INDEX idx_player_achievements_achievement ON player_achievements(achievement_id);

COMMENT ON TABLE player_achievements IS 'Achievements unlocked by players';

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Generate unique 6-character game code
CREATE OR REPLACE FUNCTION generate_game_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- no confusing chars
  result TEXT := '';
  i INTEGER;
  code_exists BOOLEAN;
BEGIN
  LOOP
    result := '';
    FOR i IN 1..6 LOOP
      result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
    END LOOP;

    SELECT EXISTS(SELECT 1 FROM games WHERE code = result) INTO code_exists;
    EXIT WHEN NOT code_exists;
  END LOOP;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for player_profiles
CREATE TRIGGER update_player_profiles_updated_at
  BEFORE UPDATE ON player_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Update card uses count when played
CREATE OR REPLACE FUNCTION increment_card_uses()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE question_cards
  SET uses_count = uses_count + 1
  WHERE id = NEW.card_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increment_card_uses_trigger
  AFTER INSERT ON card_plays
  FOR EACH ROW
  EXECUTE FUNCTION increment_card_uses();

-- Update player last_seen_at on activity
CREATE OR REPLACE FUNCTION update_player_last_seen()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_seen_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_player_last_seen_trigger
  BEFORE UPDATE ON players
  FOR EACH ROW
  WHEN (OLD.connection_status IS DISTINCT FROM NEW.connection_status)
  EXECUTE FUNCTION update_player_last_seen();
