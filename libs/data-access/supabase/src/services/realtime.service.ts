/**
 * Realtime Service
 * Handles Supabase Realtime subscriptions
 */

import { RealtimeChannel } from '@supabase/supabase-js';
import { getSupabase } from '../config/supabase-client';
import type {
  Player,
  Round,
  Reaction,
  Game,
  PlayerJoinedEvent,
  PlayerLeftEvent,
  GameStartedEvent,
  RoundChangedEvent,
  ReactionAddedEvent,
} from '@ice-breaker/shared-models';

export type RealtimeEventHandler<T> = (payload: T) => void;

/**
 * Subscribe to player changes in a game
 */
export function subscribeToPlayers(
  gameId: string,
  handlers: {
    onJoined?: RealtimeEventHandler<PlayerJoinedEvent>;
    onLeft?: RealtimeEventHandler<PlayerLeftEvent>;
    onUpdated?: RealtimeEventHandler<Player>;
  }
): RealtimeChannel {
  const supabase = getSupabase();

  const channel = supabase
    .channel(`game-${gameId}-players`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'players',
        filter: `game_id=eq.${gameId}`,
      },
      (payload) => {
        if (handlers.onJoined) {
          const player = payload.new as Player;
          // We'd need to query total count, simplified here
          handlers.onJoined({ player, totalPlayers: 0 });
        }
      }
    )
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'players',
        filter: `game_id=eq.${gameId}`,
      },
      (payload) => {
        const player = payload.new as Player;

        // Check if player left (left_at became non-null)
        if (player.left_at && handlers.onLeft) {
          handlers.onLeft({ playerId: player.id, totalPlayers: 0 });
        } else if (handlers.onUpdated) {
          handlers.onUpdated(player);
        }
      }
    )
    .subscribe();

  return channel;
}

/**
 * Subscribe to game status changes
 */
export function subscribeToGame(
  gameId: string,
  handlers: {
    onStarted?: RealtimeEventHandler<GameStartedEvent>;
    onUpdated?: RealtimeEventHandler<Game>;
    onFinished?: RealtimeEventHandler<Game>;
  }
): RealtimeChannel {
  const supabase = getSupabase();

  const channel = supabase
    .channel(`game-${gameId}`)
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'games',
        filter: `id=eq.${gameId}`,
      },
      (payload) => {
        const game = payload.new as Game;

        // Check what changed
        const oldGame = payload.old as Game;

        if (game.status === 'playing' && oldGame.status === 'lobby' && handlers.onStarted) {
          // Game just started - would need to fetch first round
          handlers.onStarted({ game, firstRound: {} as Round });
        } else if (game.status === 'finished' && handlers.onFinished) {
          handlers.onFinished(game);
        } else if (handlers.onUpdated) {
          handlers.onUpdated(game);
        }
      }
    )
    .subscribe();

  return channel;
}

/**
 * Subscribe to round changes
 */
export function subscribeToRounds(
  gameId: string,
  handlers: {
    onRoundChanged?: RealtimeEventHandler<RoundChangedEvent>;
    onRoundCompleted?: RealtimeEventHandler<Round>;
  }
): RealtimeChannel {
  const supabase = getSupabase();

  const channel = supabase
    .channel(`game-${gameId}-rounds`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'rounds',
        filter: `game_id=eq.${gameId}`,
      },
      (payload) => {
        if (handlers.onRoundChanged) {
          const round = payload.new as Round;
          // Would need to fetch next player
          handlers.onRoundChanged({ round, nextPlayer: {} as Player });
        }
      }
    )
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'rounds',
        filter: `game_id=eq.${gameId}`,
      },
      (payload) => {
        const round = payload.new as Round;

        if (round.status === 'completed' && handlers.onRoundCompleted) {
          handlers.onRoundCompleted(round);
        }
      }
    )
    .subscribe();

  return channel;
}

/**
 * Subscribe to reactions
 */
export function subscribeToReactions(
  gameId: string,
  handler: RealtimeEventHandler<ReactionAddedEvent>
): RealtimeChannel {
  const supabase = getSupabase();

  const channel = supabase
    .channel(`game-${gameId}-reactions`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'reactions',
      },
      (payload) => {
        const reaction = payload.new as Reaction;
        // Would need to fetch player info
        handler({ reaction, player: {} as Player });
      }
    )
    .subscribe();

  return channel;
}

/**
 * Unsubscribe from a channel
 */
export async function unsubscribe(channel: RealtimeChannel): Promise<void> {
  const supabase = getSupabase();
  await supabase.removeChannel(channel);
}

/**
 * Unsubscribe from all channels
 */
export async function unsubscribeAll(): Promise<void> {
  const supabase = getSupabase();
  await supabase.removeAllChannels();
}
