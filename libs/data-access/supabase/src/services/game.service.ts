/**
 * Game Service
 * Handles all game-related API calls
 */

import { getSupabase } from '../config/supabase-client';
import type {
  Game,
  Player,
  QuestionCard,
  Round,
  Reaction,
  CreateGameParams,
  JoinGameParams,
  DrawCardParams,
  PlayCardParams,
  AddReactionParams,
  ApiResponse,
} from '@ice-breaker/shared-models';

/**
 * Create a new game
 */
export async function createGame(params: CreateGameParams): Promise<ApiResponse<Game>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase.rpc('create_game', {
      p_name: params.name,
      p_game_mode: params.gameMode,
      p_max_players: params.maxPlayers,
      p_total_rounds: params.totalRounds,
      p_settings: params.settings as any,
    });

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as Game, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Join an existing game
 */
export async function joinGame(params: JoinGameParams): Promise<ApiResponse<Player>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase.rpc('join_game', {
      p_game_code: params.gameCode,
      p_display_name: params.displayName,
      p_avatar_url: params.avatarUrl,
    });

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as Player, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Start a game (host only)
 */
export async function startGame(gameId: string): Promise<ApiResponse<Game>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase.rpc('start_game', {
      p_game_id: gameId,
    });

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as Game, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Draw a question card
 */
export async function drawCard(params: DrawCardParams): Promise<ApiResponse<QuestionCard>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase.rpc('draw_card', {
      p_game_id: params.gameId,
      p_category_name: params.categoryName,
    });

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as QuestionCard, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Play a card and advance to next round
 */
export async function playCard(params: PlayCardParams): Promise<ApiResponse<Round>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase.rpc('play_card', {
      p_game_id: params.gameId,
      p_card_id: params.cardId,
      p_was_skipped: params.wasSkipped ?? false,
      p_time_spent_seconds: params.timeSpentSeconds,
    });

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as Round, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Add a reaction to a card play
 */
export async function addReaction(params: AddReactionParams): Promise<ApiResponse<Reaction>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase.rpc('add_reaction', {
      p_card_play_id: params.cardPlayId,
      p_reaction_type: params.reactionType,
    });

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as Reaction, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Leave a game
 */
export async function leaveGame(gameId: string): Promise<ApiResponse<boolean>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase.rpc('leave_game', {
      p_game_id: gameId,
    });

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as boolean, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Get game by ID
 */
export async function getGame(gameId: string): Promise<ApiResponse<Game>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase
      .from('games')
      .select('*')
      .eq('id', gameId)
      .single();

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as Game, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Get game by code
 */
export async function getGameByCode(code: string): Promise<ApiResponse<Game>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase
      .from('games')
      .select('*')
      .eq('code', code)
      .single();

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as Game, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Get players in a game
 */
export async function getGamePlayers(gameId: string): Promise<ApiResponse<Player[]>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase
      .from('players')
      .select('*')
      .eq('game_id', gameId)
      .is('left_at', null)
      .order('joined_at', { ascending: true });

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as Player[], error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}

/**
 * Get current round for a game
 */
export async function getCurrentRound(gameId: string): Promise<ApiResponse<Round>> {
  try {
    const supabase = getSupabase();

    const { data, error } = await supabase
      .from('rounds')
      .select('*')
      .eq('game_id', gameId)
      .eq('status', 'active')
      .order('round_number', { ascending: false })
      .limit(1)
      .single();

    if (error) {
      return { data: null, error: { message: error.message, code: error.code } };
    }

    return { data: data as Round, error: null };
  } catch (err) {
    return {
      data: null,
      error: { message: err instanceof Error ? err.message : 'Unknown error' },
    };
  }
}
