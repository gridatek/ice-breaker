-- Row Level Security (RLS) Policies
-- Defines access control for all tables

-- Enable RLS on all tables
ALTER TABLE question_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_history ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- QUESTION CATEGORIES POLICIES
-- ============================================================================

-- Everyone can read question categories
CREATE POLICY "Question categories are viewable by everyone"
  ON question_categories FOR SELECT
  USING (true);

-- Only authenticated users can create categories (admin functionality)
CREATE POLICY "Only authenticated users can create question categories"
  ON question_categories FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Only authenticated users can update categories
CREATE POLICY "Only authenticated users can update question categories"
  ON question_categories FOR UPDATE
  TO authenticated
  USING (true);

-- ============================================================================
-- QUESTIONS POLICIES
-- ============================================================================

-- Everyone can view active questions
CREATE POLICY "Active questions are viewable by everyone"
  ON questions FOR SELECT
  USING (is_active = true);

-- Authenticated users can view all questions (including inactive)
CREATE POLICY "Authenticated users can view all questions"
  ON questions FOR SELECT
  TO authenticated
  USING (true);

-- Only authenticated users can create questions
CREATE POLICY "Authenticated users can create questions"
  ON questions FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Users can update their own questions, or any if they're admin
CREATE POLICY "Users can update their own questions"
  ON questions FOR UPDATE
  TO authenticated
  USING (created_by = auth.uid());

-- ============================================================================
-- ROOMS POLICIES
-- ============================================================================

-- Users can view rooms they created or are participating in
CREATE POLICY "Users can view their own rooms"
  ON rooms FOR SELECT
  USING (
    creator_id = auth.uid()
    OR id IN (
      SELECT room_id FROM participants WHERE user_id = auth.uid()
    )
  );

-- Anyone can view rooms by code (for joining)
CREATE POLICY "Anyone can view rooms by code"
  ON rooms FOR SELECT
  USING (true);

-- Authenticated users can create rooms
CREATE POLICY "Authenticated users can create rooms"
  ON rooms FOR INSERT
  TO authenticated
  WITH CHECK (creator_id = auth.uid());

-- Room creators can update their rooms
CREATE POLICY "Room creators can update their rooms"
  ON rooms FOR UPDATE
  TO authenticated
  USING (creator_id = auth.uid());

-- Room creators can delete their rooms
CREATE POLICY "Room creators can delete their rooms"
  ON rooms FOR DELETE
  TO authenticated
  USING (creator_id = auth.uid());

-- ============================================================================
-- PARTICIPANTS POLICIES
-- ============================================================================

-- Participants can view other participants in the same room
CREATE POLICY "Participants can view others in their room"
  ON participants FOR SELECT
  USING (
    room_id IN (
      SELECT room_id FROM participants WHERE user_id = auth.uid() OR id = auth.uid()
    )
  );

-- Anyone can insert themselves as a participant (for joining rooms)
CREATE POLICY "Anyone can join as participant"
  ON participants FOR INSERT
  WITH CHECK (true);

-- Users can update their own participant record
CREATE POLICY "Users can update their own participant record"
  ON participants FOR UPDATE
  USING (
    user_id = auth.uid()
    OR (user_id IS NULL AND id = auth.uid())
  );

-- Users can delete their own participant record (leave room)
CREATE POLICY "Users can leave rooms"
  ON participants FOR DELETE
  USING (
    user_id = auth.uid()
    OR (user_id IS NULL AND id = auth.uid())
  );

-- ============================================================================
-- GAME SESSIONS POLICIES
-- ============================================================================

-- Participants can view game sessions for their rooms
CREATE POLICY "Participants can view their game sessions"
  ON game_sessions FOR SELECT
  USING (
    room_id IN (
      SELECT room_id FROM participants WHERE user_id = auth.uid()
    )
  );

-- Room creators can create game sessions
CREATE POLICY "Room creators can create game sessions"
  ON game_sessions FOR INSERT
  TO authenticated
  WITH CHECK (
    room_id IN (
      SELECT id FROM rooms WHERE creator_id = auth.uid()
    )
  );

-- Participants can update game sessions in their room
CREATE POLICY "Participants can update their game sessions"
  ON game_sessions FOR UPDATE
  USING (
    room_id IN (
      SELECT room_id FROM participants WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- QUESTION HISTORY POLICIES
-- ============================================================================

-- Participants can view question history for their game sessions
CREATE POLICY "Participants can view their question history"
  ON question_history FOR SELECT
  USING (
    game_session_id IN (
      SELECT gs.id FROM game_sessions gs
      INNER JOIN participants p ON gs.room_id = p.room_id
      WHERE p.user_id = auth.uid()
    )
  );

-- Participants can insert question history
CREATE POLICY "Participants can add to question history"
  ON question_history FOR INSERT
  WITH CHECK (
    game_session_id IN (
      SELECT gs.id FROM game_sessions gs
      INNER JOIN participants p ON gs.room_id = p.room_id
      WHERE p.user_id = auth.uid()
    )
  );
