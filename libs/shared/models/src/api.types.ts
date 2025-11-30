/**
 * API Response Types for Game Functions
 * These match the database functions we created
 */

import { Game, Player, QuestionCard, Reaction, Round } from './database.types';
import { GameMode, GameSettings } from './database.types';

/**
 * Function: create_game()
 */
export interface CreateGameParams {
  name?: string;
  gameMode?: GameMode;
  maxPlayers?: number;
  totalRounds?: number;
  settings?: Partial<GameSettings>;
}

export type CreateGameResponse = Game;

/**
 * Function: join_game()
 */
export interface JoinGameParams {
  gameCode: string;
  displayName: string;
  avatarUrl?: string;
}

export type JoinGameResponse = Player;

/**
 * Function: start_game()
 */
export interface StartGameParams {
  gameId: string;
}

export type StartGameResponse = Game;

/**
 * Function: draw_card()
 */
export interface DrawCardParams {
  gameId: string;
  categoryName?: string;
}

export type DrawCardResponse = QuestionCard;

/**
 * Function: play_card()
 */
export interface PlayCardParams {
  gameId: string;
  cardId: string;
  wasSkipped?: boolean;
  timeSpentSeconds?: number;
}

export type PlayCardResponse = Round;

/**
 * Function: add_reaction()
 */
export interface AddReactionParams {
  cardPlayId: string;
  reactionType: string;
}

export type AddReactionResponse = Reaction;

/**
 * Function: leave_game()
 */
export interface LeaveGameParams {
  gameId: string;
}

export type LeaveGameResponse = boolean;

/**
 * Error response from database functions
 */
export interface GameError {
  message: string;
  code?: string;
  details?: unknown;
}

/**
 * Generic API response wrapper
 */
export interface ApiResponse<T> {
  data: T | null;
  error: GameError | null;
}
