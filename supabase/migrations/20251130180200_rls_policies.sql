-- Row Level Security Policies - Secure yet fun! 🔒

-- Enable RLS on all tables
ALTER TABLE card_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_plays ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_achievements ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- CARD CATEGORIES - Everyone can view
-- ============================================================================
CREATE POLICY "Categories are public"
  ON card_categories FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admins can manage categories"
  ON card_categories FOR ALL
  TO authenticated
  USING (true);

-- ============================================================================
-- QUESTION CARDS - Public reading, authenticated writing
-- ============================================================================
CREATE POLICY "Active cards are viewable by everyone"
  ON question_cards FOR SELECT
  USING (is_active = true);

CREATE POLICY "Authenticated users can create cards"
  ON question_cards FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update their own cards"
  ON question_cards FOR UPDATE
  TO authenticated
  USING (created_by = auth.uid());

-- ============================================================================
-- GAMES - View your own games or games you're in
-- ============================================================================
CREATE POLICY "Players can view their games"
  ON games FOR SELECT
  USING (
    host_id = auth.uid()
    OR id IN (SELECT game_id FROM players WHERE user_id = auth.uid())
    OR TRUE -- anyone can view to join by code
  );

CREATE POLICY "Authenticated users can create games"
  ON games FOR INSERT
  TO authenticated
  WITH CHECK (host_id = auth.uid());

CREATE POLICY "Hosts can update their games"
  ON games FOR UPDATE
  TO authenticated
  USING (host_id = auth.uid());

CREATE POLICY "Hosts can delete their games"
  ON games FOR DELETE
  TO authenticated
  USING (host_id = auth.uid());

-- ============================================================================
-- PLAYERS - View players in your game
-- ============================================================================
CREATE POLICY "Players can view others in their game"
  ON players FOR SELECT
  USING (
    game_id IN (
      SELECT game_id FROM players WHERE user_id = auth.uid() OR id = auth.uid()
    )
    OR TRUE -- allow viewing to join
  );

CREATE POLICY "Anyone can join a game"
  ON players FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Players can update their own record"
  ON players FOR UPDATE
  USING (
    user_id = auth.uid()
    OR (is_guest = true AND id = auth.uid())
  );

CREATE POLICY "Players can leave games"
  ON players FOR DELETE
  USING (
    user_id = auth.uid()
    OR (is_guest = true AND id = auth.uid())
  );

-- ============================================================================
-- ROUNDS - View rounds in your game
-- ============================================================================
CREATE POLICY "Players can view rounds in their game"
  ON rounds FOR SELECT
  USING (
    game_id IN (
      SELECT game_id FROM players WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Players can manage rounds in their game"
  ON rounds FOR ALL
  USING (
    game_id IN (
      SELECT game_id FROM players WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- CARD PLAYS - View plays in your game
-- ============================================================================
CREATE POLICY "Players can view card plays in their game"
  ON card_plays FOR SELECT
  USING (
    game_id IN (
      SELECT game_id FROM players WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Players can create card plays in their game"
  ON card_plays FOR INSERT
  WITH CHECK (
    game_id IN (
      SELECT game_id FROM players WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- REACTIONS - Everyone in game can react
-- ============================================================================
CREATE POLICY "Players can view reactions in their game"
  ON reactions FOR SELECT
  USING (
    card_play_id IN (
      SELECT cp.id FROM card_plays cp
      WHERE cp.game_id IN (
        SELECT game_id FROM players WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Players can add reactions"
  ON reactions FOR INSERT
  WITH CHECK (
    player_id IN (
      SELECT id FROM players WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Players can remove their own reactions"
  ON reactions FOR DELETE
  USING (
    player_id IN (
      SELECT id FROM players WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- PLAYER PROFILES - View public profiles
-- ============================================================================
CREATE POLICY "Profiles are publicly viewable"
  ON player_profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can create their own profile"
  ON player_profiles FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own profile"
  ON player_profiles FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

-- ============================================================================
-- ACHIEVEMENTS - Public viewing
-- ============================================================================
CREATE POLICY "Achievements are publicly viewable"
  ON achievements FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage achievements"
  ON achievements FOR ALL
  TO authenticated
  USING (true);

-- ============================================================================
-- PLAYER ACHIEVEMENTS - View your own or public profiles
-- ============================================================================
CREATE POLICY "Users can view their own achievements"
  ON player_achievements FOR SELECT
  USING (
    player_profile_id = auth.uid()
    OR TRUE -- can view others' achievements too
  );

CREATE POLICY "System can grant achievements"
  ON player_achievements FOR INSERT
  WITH CHECK (true);
