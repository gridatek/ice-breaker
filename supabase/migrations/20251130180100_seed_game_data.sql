-- Seed Game Data - Categories, Cards & Achievements! 🎮

-- ============================================================================
-- CARD CATEGORIES
-- ============================================================================
INSERT INTO card_categories (name, display_name, description, icon, color, sort_order) VALUES
  ('laugh', '😂 Laugh', 'Light, funny questions to break the ice', '😂', '#10B981', 1),
  ('think', '🤔 Think', 'Deep, thought-provoking conversations', '🤔', '#6366F1', 2),
  ('flirt', '😍 Flirt', 'Playful, romantic vibes', '😍', '#EC4899', 3),
  ('wild', '🎲 Wild', 'Completely unexpected randomness', '🎲', '#F59E0B', 4)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- QUESTION CARDS - Laugh Category 😂
-- ============================================================================
INSERT INTO question_cards (text, category_id, difficulty, spice_level, tags) VALUES
  (
    'If you could have any superpower but it only works on Tuesdays, what would it be?',
    (SELECT id FROM card_categories WHERE name = 'laugh'),
    1, 1, ARRAY['icebreaker', 'silly']
  ),
  (
    'What''s the most embarrassing thing in your search history?',
    (SELECT id FROM card_categories WHERE name = 'laugh'),
    2, 2, ARRAY['funny', 'revealing']
  ),
  (
    'If animals could talk, which one would be the biggest gossip?',
    (SELECT id FROM card_categories WHERE name = 'laugh'),
    1, 1, ARRAY['silly', 'creative']
  ),
  (
    'What''s your most useless talent?',
    (SELECT id FROM card_categories WHERE name = 'laugh'),
    1, 1, ARRAY['fun', 'show-off']
  ),
  (
    'If you had to survive a zombie apocalypse with only what''s in this room, how screwed are you?',
    (SELECT id FROM card_categories WHERE name = 'laugh'),
    2, 2, ARRAY['scenario', 'creative']
  ),
  (
    'What''s your go-to karaoke song when you want to embarrass yourself?',
    (SELECT id FROM card_categories WHERE name = 'laugh'),
    1, 1, ARRAY['music', 'party']
  ),
  (
    'If you could only eat one food for the rest of your life but it had to be a weird combo, what would it be?',
    (SELECT id FROM card_categories WHERE name = 'laugh'),
    1, 2, ARRAY['food', 'silly']
  );

-- ============================================================================
-- QUESTION CARDS - Think Category 🤔
-- ============================================================================
INSERT INTO question_cards (text, category_id, difficulty, spice_level, tags) VALUES
  (
    'What''s a belief you held for years that turned out to be completely wrong?',
    (SELECT id FROM card_categories WHERE name = 'think'),
    3, 2, ARRAY['deep', 'growth']
  ),
  (
    'If you could ask one question and get the absolute truth, what would you ask?',
    (SELECT id FROM card_categories WHERE name = 'think'),
    4, 2, ARRAY['philosophical', 'deep']
  ),
  (
    'What''s the biggest risk you''ve ever taken?',
    (SELECT id FROM card_categories WHERE name = 'think'),
    3, 3, ARRAY['personal', 'brave']
  ),
  (
    'What do you think is your purpose in life?',
    (SELECT id FROM card_categories WHERE name = 'think'),
    5, 2, ARRAY['existential', 'deep']
  ),
  (
    'If you could relive one day of your life knowing what you know now, which day would it be?',
    (SELECT id FROM card_categories WHERE name = 'think'),
    4, 3, ARRAY['nostalgia', 'regrets']
  ),
  (
    'What''s something everyone should experience at least once?',
    (SELECT id FROM card_categories WHERE name = 'think'),
    2, 1, ARRAY['wisdom', 'life-advice']
  ),
  (
    'What would you do if you found out you only had one year left to live?',
    (SELECT id FROM card_categories WHERE name = 'think'),
    5, 3, ARRAY['mortality', 'priorities']
  );

-- ============================================================================
-- QUESTION CARDS - Flirt Category 😍
-- ============================================================================
INSERT INTO question_cards (text, category_id, difficulty, spice_level, tags) VALUES
  (
    'What''s your idea of a perfect first date?',
    (SELECT id FROM card_categories WHERE name = 'flirt'),
    2, 2, ARRAY['romance', 'date-ideas']
  ),
  (
    'What''s the most romantic thing someone has done for you?',
    (SELECT id FROM card_categories WHERE name = 'flirt'),
    2, 2, ARRAY['romance', 'sweet']
  ),
  (
    'On a scale of 1-10, how good of a kisser do you think you are?',
    (SELECT id FROM card_categories WHERE name = 'flirt'),
    3, 4, ARRAY['spicy', 'confidence']
  ),
  (
    'What''s something that instantly attracts you to someone?',
    (SELECT id FROM card_categories WHERE name = 'flirt'),
    2, 2, ARRAY['attraction', 'preferences']
  ),
  (
    'Do you believe in love at first sight, or should I walk by again?',
    (SELECT id FROM card_categories WHERE name = 'flirt'),
    1, 3, ARRAY['pickup-line', 'cheesy']
  ),
  (
    'What''s your love language?',
    (SELECT id FROM card_categories WHERE name = 'flirt'),
    2, 1, ARRAY['compatibility', 'emotional']
  ),
  (
    'If we were in a movie together, what genre would it be?',
    (SELECT id FROM card_categories WHERE name = 'flirt'),
    2, 2, ARRAY['creative', 'cute']
  );

-- ============================================================================
-- QUESTION CARDS - Wild Category 🎲
-- ============================================================================
INSERT INTO question_cards (text, category_id, difficulty, spice_level, tags) VALUES
  (
    'Would you rather fight 100 duck-sized horses or 1 horse-sized duck?',
    (SELECT id FROM card_categories WHERE name = 'wild'),
    1, 1, ARRAY['classic', 'would-you-rather']
  ),
  (
    'If you were a vegetable, what vegetable would you be and why?',
    (SELECT id FROM card_categories WHERE name = 'wild'),
    1, 1, ARRAY['absurd', 'creative']
  ),
  (
    'What conspiracy theory do you secretly think might be true?',
    (SELECT id FROM card_categories WHERE name = 'wild'),
    2, 2, ARRAY['conspiracy', 'controversial']
  ),
  (
    'If you had to get a face tattoo right now, what would it be?',
    (SELECT id FROM card_categories WHERE name = 'wild'),
    2, 3, ARRAY['commitment', 'bold']
  ),
  (
    'You''re now the ruler of a small island nation. What''s your first ridiculous law?',
    (SELECT id FROM card_categories WHERE name = 'wild'),
    2, 2, ARRAY['power', 'creative']
  ),
  (
    'If you could swap lives with any fictional character for a week, who and why?',
    (SELECT id FROM card_categories WHERE name = 'wild'),
    2, 1, ARRAY['fantasy', 'creative']
  ),
  (
    'What''s the weirdest thing you believed as a child?',
    (SELECT id FROM card_categories WHERE name = 'wild'),
    1, 1, ARRAY['nostalgia', 'funny']
  );

-- ============================================================================
-- ACHIEVEMENTS
-- ============================================================================
INSERT INTO achievements (code, name, description, icon, category, rarity, criteria) VALUES
  -- Social Achievements
  (
    'icebreaker_master',
    'Icebreaker Master',
    'Hosted your first game!',
    '🎮',
    'host',
    'common',
    '{"games_hosted": 1}'::jsonb
  ),
  (
    'social_butterfly',
    'Social Butterfly',
    'Played with 10 different people',
    '🦋',
    'social',
    'rare',
    '{"unique_players": 10}'::jsonb
  ),
  (
    'party_starter',
    'Party Starter',
    'Hosted 10 games',
    '🎉',
    'host',
    'epic',
    '{"games_hosted": 10}'::jsonb
  ),

  -- Conversation Achievements
  (
    'deep_thinker',
    'Deep Thinker',
    'Played 25 Think cards',
    '🧠',
    'conversation',
    'rare',
    '{"category_plays": {"think": 25}}'::jsonb
  ),
  (
    'smooth_talker',
    'Smooth Talker',
    'Played 25 Flirt cards',
    '💕',
    'conversation',
    'rare',
    '{"category_plays": {"flirt": 25}}'::jsonb
  ),
  (
    'comedian',
    'Comedian',
    'Played 25 Laugh cards',
    '🎭',
    'conversation',
    'rare',
    '{"category_plays": {"laugh": 25}}'::jsonb
  ),
  (
    'wild_one',
    'Wild One',
    'Played 25 Wild cards',
    '🌪️',
    'conversation',
    'rare',
    '{"category_plays": {"wild": 25}}'::jsonb
  ),

  -- Engagement Achievements
  (
    'heart_giver',
    'Heart Giver',
    'Gave 50 love reactions',
    '❤️',
    'engagement',
    'common',
    '{"reactions_given": {"love": 50}}'::jsonb
  ),
  (
    'conversation_veteran',
    'Conversation Veteran',
    'Played 100 total cards',
    '🏆',
    'conversation',
    'epic',
    '{"total_cards_played": 100}'::jsonb
  ),
  (
    'popular',
    'Popular',
    'Received 100 reactions total',
    '⭐',
    'engagement',
    'rare',
    '{"reactions_received": 100}'::jsonb
  ),

  -- Special Achievements
  (
    'night_owl',
    'Night Owl',
    'Played a game after midnight',
    '🦉',
    'special',
    'common',
    '{"played_after_hour": 0}'::jsonb
  ),
  (
    'speed_demon',
    'Speed Demon',
    'Completed a round in under 1 minute',
    '⚡',
    'special',
    'rare',
    '{"round_time_seconds": 60}'::jsonb
  ),
  (
    'marathon_player',
    'Marathon Player',
    'Played a game lasting over 2 hours',
    '🏃',
    'special',
    'epic',
    '{"game_duration_minutes": 120}'::jsonb
  ),
  (
    'legendary_connector',
    'Legendary Connector',
    'Played 50 games',
    '👑',
    'engagement',
    'legendary',
    '{"total_games_played": 50}'::jsonb
  );
