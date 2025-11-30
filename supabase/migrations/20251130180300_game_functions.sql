-- Game Functions - The Fun API! 🎮

-- ============================================================================
-- CREATE GAME
-- ============================================================================
CREATE OR REPLACE FUNCTION create_game(
  p_name TEXT DEFAULT NULL,
  p_game_mode TEXT DEFAULT 'classic',
  p_max_players INTEGER DEFAULT 2,
  p_total_rounds INTEGER DEFAULT NULL,
  p_settings JSONB DEFAULT NULL
)
RETURNS games AS $$
DECLARE
  v_game games;
  v_code TEXT;
  v_settings JSONB;
BEGIN
  -- Generate unique game code
  v_code := generate_game_code();

  -- Merge settings
  v_settings := COALESCE(p_settings, '{}'::jsonb);

  -- Create the game
  INSERT INTO games (
    code,
    name,
    host_id,
    game_mode,
    max_players,
    total_rounds,
    settings
  ) VALUES (
    v_code,
    p_name,
    auth.uid(),
    p_game_mode,
    p_max_players,
    p_total_rounds,
    v_settings
  )
  RETURNING * INTO v_game;

  -- Add host as first player
  PERFORM join_game(v_code, COALESCE(
    (SELECT raw_user_meta_data->>'display_name' FROM auth.users WHERE id = auth.uid()),
    'Host'
  ));

  -- Initialize player profile if doesn't exist
  INSERT INTO player_profiles (user_id)
  VALUES (auth.uid())
  ON CONFLICT (user_id) DO UPDATE
  SET total_games_hosted = player_profiles.total_games_hosted + 1;

  RETURN v_game;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- JOIN GAME
-- ============================================================================
CREATE OR REPLACE FUNCTION join_game(
  p_game_code TEXT,
  p_display_name TEXT,
  p_avatar_url TEXT DEFAULT NULL
)
RETURNS players AS $$
DECLARE
  v_game games;
  v_player players;
  v_player_count INTEGER;
  v_is_host BOOLEAN;
BEGIN
  -- Find game by code
  SELECT * INTO v_game FROM games WHERE code = p_game_code;

  IF v_game IS NULL THEN
    RAISE EXCEPTION 'Game not found with code: %', p_game_code;
  END IF;

  IF v_game.status != 'lobby' THEN
    RAISE EXCEPTION 'Game has already started or finished';
  END IF;

  -- Check if game is full
  SELECT COUNT(*) INTO v_player_count
  FROM players
  WHERE game_id = v_game.id AND left_at IS NULL;

  IF v_player_count >= v_game.max_players THEN
    RAISE EXCEPTION 'Game is full (max % players)', v_game.max_players;
  END IF;

  -- Check if display name is taken
  IF EXISTS (
    SELECT 1 FROM players
    WHERE game_id = v_game.id
    AND display_name = p_display_name
    AND left_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Display name "%" is already taken', p_display_name;
  END IF;

  -- Determine if this is the host rejoining
  v_is_host := (v_game.host_id = auth.uid());

  -- Add player
  INSERT INTO players (
    game_id,
    user_id,
    display_name,
    avatar_url,
    is_host,
    is_guest,
    connection_status
  ) VALUES (
    v_game.id,
    auth.uid(),
    p_display_name,
    p_avatar_url,
    v_is_host,
    auth.uid() IS NULL,
    'online'
  )
  RETURNING * INTO v_player;

  -- Update profile stats if authenticated
  IF auth.uid() IS NOT NULL THEN
    INSERT INTO player_profiles (user_id, total_games_played)
    VALUES (auth.uid(), 1)
    ON CONFLICT (user_id) DO UPDATE
    SET total_games_played = player_profiles.total_games_played + 1;
  END IF;

  RETURN v_player;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- START GAME
-- ============================================================================
CREATE OR REPLACE FUNCTION start_game(
  p_game_id UUID
)
RETURNS games AS $$
DECLARE
  v_game games;
  v_player_count INTEGER;
  v_first_player UUID;
BEGIN
  -- Get game and verify host
  SELECT * INTO v_game FROM games WHERE id = p_game_id;

  IF v_game IS NULL THEN
    RAISE EXCEPTION 'Game not found';
  END IF;

  IF v_game.host_id != auth.uid() THEN
    RAISE EXCEPTION 'Only the host can start the game';
  END IF;

  IF v_game.status != 'lobby' THEN
    RAISE EXCEPTION 'Game has already started';
  END IF;

  -- Check minimum players
  SELECT COUNT(*) INTO v_player_count
  FROM players
  WHERE game_id = p_game_id AND left_at IS NULL;

  IF v_player_count < 2 THEN
    RAISE EXCEPTION 'Need at least 2 players to start';
  END IF;

  -- Get first player (host goes first)
  SELECT id INTO v_first_player
  FROM players
  WHERE game_id = p_game_id AND is_host = true
  LIMIT 1;

  -- Create first round
  INSERT INTO rounds (game_id, round_number, current_player_id)
  VALUES (p_game_id, 1, v_first_player);

  -- Update game status
  UPDATE games
  SET
    status = 'playing',
    started_at = NOW(),
    current_round = 1
  WHERE id = p_game_id
  RETURNING * INTO v_game;

  RETURN v_game;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- DRAW CARD
-- ============================================================================
CREATE OR REPLACE FUNCTION draw_card(
  p_game_id UUID,
  p_category_name TEXT DEFAULT NULL
)
RETURNS question_cards AS $$
DECLARE
  v_card question_cards;
  v_category_id UUID;
  v_round rounds;
  v_player players;
BEGIN
  -- Get current round
  SELECT * INTO v_round
  FROM rounds
  WHERE game_id = p_game_id
  AND status = 'active'
  ORDER BY round_number DESC
  LIMIT 1;

  IF v_round IS NULL THEN
    RAISE EXCEPTION 'No active round found';
  END IF;

  -- Get current player
  SELECT * INTO v_player
  FROM players
  WHERE id = v_round.current_player_id;

  -- Verify it's the current player's turn
  IF v_player.user_id != auth.uid() AND NOT v_player.is_guest THEN
    RAISE EXCEPTION 'Not your turn!';
  END IF;

  -- Get category ID if specified
  IF p_category_name IS NOT NULL THEN
    SELECT id INTO v_category_id
    FROM card_categories
    WHERE name = p_category_name;
  END IF;

  -- Draw random card that hasn't been played in this game
  SELECT qc.* INTO v_card
  FROM question_cards qc
  WHERE qc.is_active = true
    AND (v_category_id IS NULL OR qc.category_id = v_category_id)
    AND qc.id NOT IN (
      SELECT card_id FROM card_plays WHERE game_id = p_game_id
    )
  ORDER BY RANDOM()
  LIMIT 1;

  IF v_card IS NULL THEN
    RAISE EXCEPTION 'No more cards available!';
  END IF;

  -- Update round with current card
  UPDATE rounds
  SET
    current_card_id = v_card.id,
    card_category_id = v_card.category_id
  WHERE id = v_round.id;

  RETURN v_card;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PLAY CARD (Complete the round)
-- ============================================================================
CREATE OR REPLACE FUNCTION play_card(
  p_game_id UUID,
  p_card_id UUID,
  p_was_skipped BOOLEAN DEFAULT false,
  p_time_spent_seconds INTEGER DEFAULT NULL
)
RETURNS rounds AS $$
DECLARE
  v_round rounds;
  v_next_player UUID;
  v_new_round rounds;
  v_game games;
  v_player_count INTEGER;
  v_current_player_index INTEGER;
BEGIN
  -- Get current round
  SELECT * INTO v_round
  FROM rounds
  WHERE game_id = p_game_id
  AND status = 'active'
  ORDER BY round_number DESC
  LIMIT 1;

  IF v_round IS NULL THEN
    RAISE EXCEPTION 'No active round found';
  END IF;

  -- Get game info
  SELECT * INTO v_game FROM games WHERE id = p_game_id;

  -- Record the card play
  INSERT INTO card_plays (
    game_id,
    round_id,
    card_id,
    player_id,
    was_skipped,
    time_spent_seconds
  ) VALUES (
    p_game_id,
    v_round.id,
    p_card_id,
    v_round.current_player_id,
    p_was_skipped,
    p_time_spent_seconds
  );

  -- Mark round as completed
  UPDATE rounds
  SET
    status = CASE WHEN p_was_skipped THEN 'skipped' ELSE 'completed' END,
    completed_at = NOW()
  WHERE id = v_round.id;

  -- Update game stats
  UPDATE games
  SET total_cards_played = total_cards_played + 1
  WHERE id = p_game_id;

  -- Update player stats
  UPDATE players
  SET cards_drawn = cards_drawn + 1
  WHERE id = v_round.current_player_id;

  -- Get next player (round-robin)
  WITH player_list AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY joined_at) as player_index
    FROM players
    WHERE game_id = p_game_id AND left_at IS NULL
  )
  SELECT player_index INTO v_current_player_index
  FROM player_list
  WHERE id = v_round.current_player_id;

  SELECT COUNT(*) INTO v_player_count
  FROM players
  WHERE game_id = p_game_id AND left_at IS NULL;

  -- Get next player (wrap around if needed)
  WITH player_list AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY joined_at) as player_index
    FROM players
    WHERE game_id = p_game_id AND left_at IS NULL
  )
  SELECT id INTO v_next_player
  FROM player_list
  WHERE player_index = CASE
    WHEN v_current_player_index >= v_player_count THEN 1
    ELSE v_current_player_index + 1
  END;

  -- Check if game should end
  IF v_game.total_rounds IS NOT NULL AND v_round.round_number >= v_game.total_rounds THEN
    UPDATE games
    SET status = 'finished', finished_at = NOW()
    WHERE id = p_game_id;

    RETURN v_round;
  END IF;

  -- Create next round
  INSERT INTO rounds (game_id, round_number, current_player_id)
  VALUES (p_game_id, v_round.round_number + 1, v_next_player)
  RETURNING * INTO v_new_round;

  -- Update game current round
  UPDATE games
  SET current_round = v_new_round.round_number
  WHERE id = p_game_id;

  RETURN v_new_round;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- ADD REACTION
-- ============================================================================
CREATE OR REPLACE FUNCTION add_reaction(
  p_card_play_id UUID,
  p_reaction_type TEXT
)
RETURNS reactions AS $$
DECLARE
  v_reaction reactions;
  v_card_play card_plays;
  v_player players;
BEGIN
  -- Get card play info
  SELECT * INTO v_card_play FROM card_plays WHERE id = p_card_play_id;

  IF v_card_play IS NULL THEN
    RAISE EXCEPTION 'Card play not found';
  END IF;

  -- Get current player
  SELECT * INTO v_player
  FROM players
  WHERE game_id = v_card_play.game_id
  AND (user_id = auth.uid() OR (is_guest = true AND id = auth.uid()));

  IF v_player IS NULL THEN
    RAISE EXCEPTION 'You are not in this game';
  END IF;

  -- Add reaction
  INSERT INTO reactions (card_play_id, player_id, reaction_type)
  VALUES (p_card_play_id, v_player.id, p_reaction_type)
  ON CONFLICT (card_play_id, player_id, reaction_type) DO NOTHING
  RETURNING * INTO v_reaction;

  -- Update player stats
  UPDATE players
  SET reactions_given = reactions_given + 1
  WHERE id = v_player.id;

  -- Update the player who played the card
  UPDATE players
  SET reactions_received = reactions_received + 1
  WHERE id = v_card_play.player_id;

  -- Update game stats
  UPDATE games
  SET total_reactions = total_reactions + 1
  WHERE id = v_card_play.game_id;

  RETURN v_reaction;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- LEAVE GAME
-- ============================================================================
CREATE OR REPLACE FUNCTION leave_game(
  p_game_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  v_player players;
BEGIN
  -- Find player
  SELECT * INTO v_player
  FROM players
  WHERE game_id = p_game_id
  AND (user_id = auth.uid() OR (is_guest = true AND id = auth.uid()))
  AND left_at IS NULL;

  IF v_player IS NULL THEN
    RAISE EXCEPTION 'Player not found in this game';
  END IF;

  -- Mark as left
  UPDATE players
  SET
    left_at = NOW(),
    connection_status = 'offline'
  WHERE id = v_player.id;

  -- If host left and game is in lobby, cancel game
  IF v_player.is_host THEN
    UPDATE games
    SET status = 'abandoned'
    WHERE id = p_game_id AND status IN ('lobby', 'playing');
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION create_game TO authenticated;
GRANT EXECUTE ON FUNCTION join_game TO anon, authenticated;
GRANT EXECUTE ON FUNCTION start_game TO authenticated;
GRANT EXECUTE ON FUNCTION draw_card TO anon, authenticated;
GRANT EXECUTE ON FUNCTION play_card TO anon, authenticated;
GRANT EXECUTE ON FUNCTION add_reaction TO anon, authenticated;
GRANT EXECUTE ON FUNCTION leave_game TO anon, authenticated;
