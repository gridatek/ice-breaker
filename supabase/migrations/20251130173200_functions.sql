-- Helper Functions for IceBreaker Game Logic

-- ============================================================================
-- CREATE ROOM FUNCTION
-- ============================================================================
-- Helper function to create a room with a unique code
CREATE OR REPLACE FUNCTION create_room(
  p_name TEXT DEFAULT NULL,
  p_max_participants INTEGER DEFAULT 2,
  p_settings JSONB DEFAULT '{}'::jsonb
)
RETURNS rooms AS $$
DECLARE
  v_room rooms;
  v_code TEXT;
BEGIN
  -- Generate unique room code
  v_code := generate_room_code();

  -- Create the room
  INSERT INTO rooms (code, name, creator_id, max_participants, settings)
  VALUES (v_code, p_name, auth.uid(), p_max_participants, p_settings)
  RETURNING * INTO v_room;

  -- Add creator as first participant
  INSERT INTO participants (room_id, user_id, display_name, is_creator, is_guest)
  VALUES (
    v_room.id,
    auth.uid(),
    COALESCE(
      (SELECT raw_user_meta_data->>'display_name' FROM auth.users WHERE id = auth.uid()),
      'Host'
    ),
    true,
    false
  );

  RETURN v_room;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- JOIN ROOM FUNCTION
-- ============================================================================
-- Helper function to join a room as guest or authenticated user
CREATE OR REPLACE FUNCTION join_room(
  p_room_code TEXT,
  p_display_name TEXT
)
RETURNS participants AS $$
DECLARE
  v_room rooms;
  v_participant participants;
  v_participant_count INTEGER;
BEGIN
  -- Find room by code
  SELECT * INTO v_room FROM rooms WHERE code = p_room_code AND status = 'waiting';

  IF v_room IS NULL THEN
    RAISE EXCEPTION 'Room not found or not accepting participants';
  END IF;

  -- Check if room is full
  SELECT COUNT(*) INTO v_participant_count
  FROM participants
  WHERE room_id = v_room.id AND left_at IS NULL;

  IF v_participant_count >= v_room.max_participants THEN
    RAISE EXCEPTION 'Room is full';
  END IF;

  -- Check if display name is already taken in this room
  IF EXISTS (
    SELECT 1 FROM participants
    WHERE room_id = v_room.id
    AND display_name = p_display_name
    AND left_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Display name already taken in this room';
  END IF;

  -- Add participant
  INSERT INTO participants (
    room_id,
    user_id,
    display_name,
    is_creator,
    is_guest
  ) VALUES (
    v_room.id,
    auth.uid(),
    p_display_name,
    false,
    auth.uid() IS NULL
  )
  RETURNING * INTO v_participant;

  RETURN v_participant;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- START GAME SESSION FUNCTION
-- ============================================================================
-- Function to start a game session for a room
CREATE OR REPLACE FUNCTION start_game_session(
  p_room_id UUID,
  p_settings JSONB DEFAULT '{}'::jsonb
)
RETURNS game_sessions AS $$
DECLARE
  v_room rooms;
  v_session game_sessions;
  v_first_participant UUID;
BEGIN
  -- Verify room exists and user is creator
  SELECT * INTO v_room FROM rooms WHERE id = p_room_id;

  IF v_room IS NULL THEN
    RAISE EXCEPTION 'Room not found';
  END IF;

  IF v_room.creator_id != auth.uid() THEN
    RAISE EXCEPTION 'Only room creator can start the game';
  END IF;

  -- Check if session already exists
  IF EXISTS (SELECT 1 FROM game_sessions WHERE room_id = p_room_id) THEN
    RAISE EXCEPTION 'Game session already exists for this room';
  END IF;

  -- Get first participant (creator goes first)
  SELECT id INTO v_first_participant
  FROM participants
  WHERE room_id = p_room_id AND is_creator = true
  LIMIT 1;

  -- Create game session
  INSERT INTO game_sessions (
    room_id,
    current_turn_participant_id,
    settings
  ) VALUES (
    p_room_id,
    v_first_participant,
    p_settings
  )
  RETURNING * INTO v_session;

  -- Update room status
  UPDATE rooms
  SET status = 'active', started_at = NOW()
  WHERE id = p_room_id;

  RETURN v_session;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- DRAW QUESTION FUNCTION
-- ============================================================================
-- Function to draw a random question that hasn't been used in this session
CREATE OR REPLACE FUNCTION draw_question(
  p_game_session_id UUID,
  p_category_name TEXT DEFAULT NULL
)
RETURNS questions AS $$
DECLARE
  v_question questions;
  v_category_id UUID;
BEGIN
  -- Get category ID if specified
  IF p_category_name IS NOT NULL THEN
    SELECT id INTO v_category_id
    FROM question_categories
    WHERE name = p_category_name;
  END IF;

  -- Select a random question that hasn't been used in this session
  SELECT q.* INTO v_question
  FROM questions q
  WHERE q.is_active = true
    AND (v_category_id IS NULL OR q.category_id = v_category_id)
    AND q.id NOT IN (
      SELECT question_id
      FROM question_history
      WHERE game_session_id = p_game_session_id
    )
  ORDER BY RANDOM()
  LIMIT 1;

  IF v_question IS NULL THEN
    RAISE EXCEPTION 'No available questions found';
  END IF;

  RETURN v_question;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- NEXT TURN FUNCTION
-- ============================================================================
-- Function to advance to next turn in a game session
CREATE OR REPLACE FUNCTION next_turn(
  p_game_session_id UUID,
  p_question_id UUID
)
RETURNS game_sessions AS $$
DECLARE
  v_session game_sessions;
  v_current_participant UUID;
  v_next_participant UUID;
  v_room_id UUID;
BEGIN
  -- Get current session
  SELECT * INTO v_session FROM game_sessions WHERE id = p_game_session_id;

  IF v_session IS NULL THEN
    RAISE EXCEPTION 'Game session not found';
  END IF;

  v_current_participant := v_session.current_turn_participant_id;
  v_room_id := v_session.room_id;

  -- Record question in history
  INSERT INTO question_history (
    game_session_id,
    question_id,
    participant_id,
    turn_number
  ) VALUES (
    p_game_session_id,
    p_question_id,
    v_current_participant,
    v_session.turn_number
  );

  -- Get next participant (round-robin)
  SELECT p.id INTO v_next_participant
  FROM participants p
  WHERE p.room_id = v_room_id
    AND p.left_at IS NULL
    AND p.id != v_current_participant
  ORDER BY p.joined_at
  LIMIT 1;

  -- If no next participant found, wrap back to first
  IF v_next_participant IS NULL THEN
    SELECT p.id INTO v_next_participant
    FROM participants p
    WHERE p.room_id = v_room_id AND p.left_at IS NULL
    ORDER BY p.joined_at
    LIMIT 1;
  END IF;

  -- Update session
  UPDATE game_sessions
  SET
    current_turn_participant_id = v_next_participant,
    current_question_id = NULL,
    turn_number = turn_number + 1,
    updated_at = NOW()
  WHERE id = p_game_session_id
  RETURNING * INTO v_session;

  RETURN v_session;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION create_room TO authenticated;
GRANT EXECUTE ON FUNCTION join_room TO anon, authenticated;
GRANT EXECUTE ON FUNCTION start_game_session TO authenticated;
GRANT EXECUTE ON FUNCTION draw_question TO authenticated, anon;
GRANT EXECUTE ON FUNCTION next_turn TO authenticated, anon;
