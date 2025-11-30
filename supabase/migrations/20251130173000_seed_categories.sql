-- Seed Question Categories
-- Inserts the default question categories for IceBreaker

INSERT INTO question_categories (name, description, color) VALUES
  ('fun', 'Light-hearted and entertaining questions', '#10B981'),
  ('deep', 'Thought-provoking and meaningful questions', '#6366F1'),
  ('flirty', 'Playful and romantic questions', '#EC4899'),
  ('random', 'Completely random and unexpected questions', '#F59E0B')
ON CONFLICT (name) DO NOTHING;

-- Seed some initial questions for each category
INSERT INTO questions (text, category_id) VALUES
  -- Fun questions
  (
    'If you could have any superpower for a day, what would it be and why?',
    (SELECT id FROM question_categories WHERE name = 'fun')
  ),
  (
    'What''s the most embarrassing song on your playlist?',
    (SELECT id FROM question_categories WHERE name = 'fun')
  ),
  (
    'If you could only eat one food for the rest of your life, what would it be?',
    (SELECT id FROM question_categories WHERE name = 'fun')
  ),
  (
    'What''s your go-to karaoke song?',
    (SELECT id FROM question_categories WHERE name = 'fun')
  ),
  (
    'If you could be any fictional character for a week, who would you choose?',
    (SELECT id FROM question_categories WHERE name = 'fun')
  ),

  -- Deep questions
  (
    'What''s a belief you held strongly that you''ve completely changed your mind about?',
    (SELECT id FROM question_categories WHERE name = 'deep')
  ),
  (
    'If you could know the absolute truth to one question, what would you ask?',
    (SELECT id FROM question_categories WHERE name = 'deep')
  ),
  (
    'What do you think is your greatest strength, and how has it shaped your life?',
    (SELECT id FROM question_categories WHERE name = 'deep')
  ),
  (
    'What experience has most shaped who you are today?',
    (SELECT id FROM question_categories WHERE name = 'deep')
  ),
  (
    'If you could give your younger self one piece of advice, what would it be?',
    (SELECT id FROM question_categories WHERE name = 'deep')
  ),

  -- Flirty questions
  (
    'What''s your idea of a perfect date?',
    (SELECT id FROM question_categories WHERE name = 'flirty')
  ),
  (
    'What''s the most romantic gesture someone could do for you?',
    (SELECT id FROM question_categories WHERE name = 'flirty')
  ),
  (
    'Do you believe in love at first sight, or should I walk by again?',
    (SELECT id FROM question_categories WHERE name = 'flirty')
  ),
  (
    'What''s something that instantly makes you attracted to someone?',
    (SELECT id FROM question_categories WHERE name = 'flirty')
  ),
  (
    'What''s your love language?',
    (SELECT id FROM question_categories WHERE name = 'flirty')
  ),

  -- Random questions
  (
    'If animals could talk, which species would be the rudest?',
    (SELECT id FROM question_categories WHERE name = 'random')
  ),
  (
    'Would you rather fight one horse-sized duck or 100 duck-sized horses?',
    (SELECT id FROM question_categories WHERE name = 'random')
  ),
  (
    'If you were a vegetable, what vegetable would you be?',
    (SELECT id FROM question_categories WHERE name = 'random')
  ),
  (
    'What conspiracy theory do you secretly think might be true?',
    (SELECT id FROM question_categories WHERE name = 'random')
  ),
  (
    'If you had to wear one outfit for the rest of your life, what would it be?',
    (SELECT id FROM question_categories WHERE name = 'random')
  );
