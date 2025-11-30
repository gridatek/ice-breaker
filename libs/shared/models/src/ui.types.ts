/**
 * UI-specific types and view models
 * These combine database types for easier UI consumption
 */

import {
  CardCategory,
  Game,
  Player,
  QuestionCard,
  Reaction,
  Round,
  CardPlay,
  Achievement,
} from './database.types';

/**
 * Game with populated relationships
 */
export interface GameWithPlayers extends Game {
  players: Player[];
  current_round_data?: Round;
}

/**
 * Player with populated user data
 */
export interface PlayerWithStats extends Player {
  total_reactions: number;
  is_current_turn: boolean;
}

/**
 * Round with populated card and player
 */
export interface RoundWithDetails extends Round {
  card?: QuestionCard;
  category?: CardCategory;
  player?: Player;
}

/**
 * Card play with reactions and player info
 */
export interface CardPlayWithDetails extends CardPlay {
  card: QuestionCard;
  player?: Player;
  reactions: ReactionWithPlayer[];
}

/**
 * Reaction with player info
 */
export interface ReactionWithPlayer extends Reaction {
  player: Player;
}

/**
 * Achievement with unlock status
 */
export interface AchievementWithStatus extends Achievement {
  unlocked: boolean;
  unlocked_at?: string;
  progress?: number; // 0-1 for progress towards unlock
}

/**
 * Game lobby view model
 */
export interface GameLobbyView {
  game: Game;
  players: Player[];
  host: Player;
  canStart: boolean;
  isFull: boolean;
}

/**
 * Active game view model
 */
export interface ActiveGameView {
  game: GameWithPlayers;
  currentRound: RoundWithDetails;
  currentPlayer: Player;
  isMyTurn: boolean;
  recentCardPlays: CardPlayWithDetails[];
}

/**
 * Player stats summary
 */
export interface PlayerStats {
  gamesPlayed: number;
  gamesHosted: number;
  cardsPlayed: number;
  reactionsGiven: number;
  reactionsReceived: number;
  favoriteCategory?: CardCategory;
  achievements: Achievement[];
}

/**
 * Game results/summary
 */
export interface GameSummary {
  game: Game;
  players: PlayerWithStats[];
  totalRounds: number;
  totalReactions: number;
  topCard?: QuestionCard;
  mvp?: Player; // Most reactions received
  duration?: number; // in minutes
}

/**
 * Card with category info
 */
export interface CardWithCategory extends QuestionCard {
  category?: CardCategory;
}

/**
 * Realtime event payloads
 */
export interface PlayerJoinedEvent {
  player: Player;
  totalPlayers: number;
}

export interface PlayerLeftEvent {
  playerId: string;
  totalPlayers: number;
}

export interface GameStartedEvent {
  game: Game;
  firstRound: Round;
}

export interface RoundChangedEvent {
  round: Round;
  nextPlayer: Player;
}

export interface CardDrawnEvent {
  card: QuestionCard;
  playerId: string;
}

export interface ReactionAddedEvent {
  reaction: Reaction;
  player: Player;
}

/**
 * Form data types
 */
export interface CreateGameFormData {
  name?: string;
  gameMode: string;
  maxPlayers: number;
  totalRounds?: number;
  categoriesEnabled: string[];
  allowSkip: boolean;
  roundTimerSeconds: number;
}

export interface JoinGameFormData {
  gameCode: string;
  displayName: string;
}

/**
 * Filter/query types
 */
export interface CardFilter {
  categories?: string[];
  minDifficulty?: number;
  maxDifficulty?: number;
  minSpiceLevel?: number;
  maxSpiceLevel?: number;
  tags?: string[];
  searchText?: string;
}

export interface GameFilter {
  status?: string[];
  gameMode?: string[];
  hasSlots?: boolean; // games that aren't full
}
