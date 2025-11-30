/**
 * Database Table Interfaces
 * These match the Supabase schema exactly
 */

import {
  AchievementCategory,
  AchievementRarity,
  CardCategoryName,
  GameMode,
  GameStatus,
  PlayerConnectionStatus,
  ReactionType,
  RoundStatus,
} from './enums';

/**
 * Base timestamp fields that all tables have
 */
export interface BaseTimestamps {
  created_at: string;
}

export interface UpdatedTimestamps extends BaseTimestamps {
  updated_at: string;
}

/**
 * Card Categories Table
 */
export interface CardCategory extends BaseTimestamps {
  id: string;
  name: CardCategoryName;
  display_name: string;
  description: string | null;
  icon: string | null;
  color: string | null;
  is_active: boolean;
  sort_order: number;
}

/**
 * Question Cards Table
 */
export interface QuestionCard extends BaseTimestamps {
  id: string;
  text: string;
  category_id: string | null;
  difficulty: number | null; // 1-5
  spice_level: number | null; // 1-5
  is_active: boolean;
  uses_count: number;
  average_rating: number | null; // 0-5
  tags: string[] | null;
  created_by: string | null;
}

/**
 * Game Settings stored in JSONB
 */
export interface GameSettings {
  categories_enabled: CardCategoryName[];
  allow_skip: boolean;
  round_timer_seconds: number;
  auto_next_round: boolean;
  show_player_stats?: boolean;
}

/**
 * Games Table
 */
export interface Game extends BaseTimestamps {
  id: string;
  code: string; // 6-char join code
  name: string | null;
  host_id: string | null;
  status: GameStatus;
  game_mode: GameMode;
  max_players: number; // 2-10
  current_round: number;
  total_rounds: number | null;
  settings: GameSettings;
  started_at: string | null;
  finished_at: string | null;
  total_cards_played: number;
  total_reactions: number;
}

/**
 * Players Table
 */
export interface Player extends BaseTimestamps {
  id: string;
  game_id: string;
  user_id: string | null;
  display_name: string;
  avatar_url: string | null;
  is_host: boolean;
  is_guest: boolean;
  connection_status: PlayerConnectionStatus;
  peer_id: string | null; // WebRTC peer ID
  cards_drawn: number;
  reactions_given: number;
  reactions_received: number;
  favorite_cards: string[]; // array of card IDs
  joined_at: string;
  left_at: string | null;
  last_seen_at: string;
}

/**
 * Rounds Table
 */
export interface Round extends BaseTimestamps {
  id: string;
  game_id: string;
  round_number: number;
  current_player_id: string | null;
  current_card_id: string | null;
  card_category_id: string | null;
  status: RoundStatus;
  started_at: string;
  completed_at: string | null;
}

/**
 * Card Plays Table
 */
export interface CardPlay extends BaseTimestamps {
  id: string;
  game_id: string;
  round_id: string;
  card_id: string;
  player_id: string | null;
  was_skipped: boolean;
  time_spent_seconds: number | null;
  played_at: string;
}

/**
 * Reactions Table
 */
export interface Reaction extends BaseTimestamps {
  id: string;
  card_play_id: string;
  player_id: string;
  reaction_type: ReactionType;
  created_at: string;
}

/**
 * Player Profile Preferences stored in JSONB
 */
export interface PlayerPreferences {
  default_game_mode: GameMode;
  preferred_categories: CardCategoryName[];
  notification_settings: Record<string, boolean>;
}

/**
 * Player Profiles Table
 */
export interface PlayerProfile extends UpdatedTimestamps {
  user_id: string;
  username: string | null;
  bio: string | null;
  avatar_url: string | null;
  total_games_played: number;
  total_games_hosted: number;
  total_cards_played: number;
  total_reactions_given: number;
  total_reactions_received: number;
  favorite_category_id: string | null;
  achievements: unknown; // JSONB array
  preferences: PlayerPreferences;
}

/**
 * Achievement Criteria stored in JSONB
 */
export interface AchievementCriteria {
  games_hosted?: number;
  unique_players?: number;
  total_games_played?: number;
  total_cards_played?: number;
  category_plays?: Record<string, number>;
  reactions_given?: Record<string, number>;
  reactions_received?: number;
  played_after_hour?: number;
  round_time_seconds?: number;
  game_duration_minutes?: number;
}

/**
 * Achievements Table
 */
export interface Achievement extends BaseTimestamps {
  id: string;
  code: string;
  name: string;
  description: string;
  icon: string | null;
  category: AchievementCategory;
  rarity: AchievementRarity;
  criteria: AchievementCriteria;
}

/**
 * Player Achievements Table
 */
export interface PlayerAchievement extends BaseTimestamps {
  id: string;
  player_profile_id: string;
  achievement_id: string;
  unlocked_at: string;
  game_id: string | null;
}

/**
 * Database schema - all tables combined
 */
export interface Database {
  public: {
    Tables: {
      card_categories: CardCategory;
      question_cards: QuestionCard;
      games: Game;
      players: Player;
      rounds: Round;
      card_plays: CardPlay;
      reactions: Reaction;
      player_profiles: PlayerProfile;
      achievements: Achievement;
      player_achievements: PlayerAchievement;
    };
  };
}
