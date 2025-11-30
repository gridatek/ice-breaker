/**
 * Game and Player Status Enums
 * These match the database CHECK constraints exactly
 */

export enum GameStatus {
  LOBBY = 'lobby',
  PLAYING = 'playing',
  PAUSED = 'paused',
  FINISHED = 'finished',
  ABANDONED = 'abandoned',
}

export enum GameMode {
  CLASSIC = 'classic',
  SPEED = 'speed',
  DEEP_DIVE = 'deep-dive',
  PARTY = 'party',
}

export enum PlayerConnectionStatus {
  ONLINE = 'online',
  OFFLINE = 'offline',
  AWAY = 'away',
}

export enum RoundStatus {
  ACTIVE = 'active',
  COMPLETED = 'completed',
  SKIPPED = 'skipped',
}

export enum ReactionType {
  LOVE = 'love',
  LAUGH = 'laugh',
  MIND_BLOWN = 'mind_blown',
  FIRE = 'fire',
  SKIP = 'skip',
  SAVE = 'save',
}

export enum AchievementCategory {
  SOCIAL = 'social',
  CONVERSATION = 'conversation',
  HOST = 'host',
  ENGAGEMENT = 'engagement',
  SPECIAL = 'special',
}

export enum AchievementRarity {
  COMMON = 'common',
  RARE = 'rare',
  EPIC = 'epic',
  LEGENDARY = 'legendary',
}

/**
 * Card category names (lowercase for database, display names with emojis in UI)
 */
export enum CardCategoryName {
  LAUGH = 'laugh',
  THINK = 'think',
  FLIRT = 'flirt',
  WILD = 'wild',
}

/**
 * Helper to get emoji for category
 */
export const CATEGORY_EMOJIS: Record<CardCategoryName, string> = {
  [CardCategoryName.LAUGH]: '😂',
  [CardCategoryName.THINK]: '🤔',
  [CardCategoryName.FLIRT]: '😍',
  [CardCategoryName.WILD]: '🎲',
};

/**
 * Helper to get emoji for reaction
 */
export const REACTION_EMOJIS: Record<ReactionType, string> = {
  [ReactionType.LOVE]: '❤️',
  [ReactionType.LAUGH]: '😂',
  [ReactionType.MIND_BLOWN]: '🤯',
  [ReactionType.FIRE]: '🔥',
  [ReactionType.SKIP]: '⏭️',
  [ReactionType.SAVE]: '💾',
};

/**
 * Helper to get display label for reaction
 */
export const REACTION_LABELS: Record<ReactionType, string> = {
  [ReactionType.LOVE]: 'Love it!',
  [ReactionType.LAUGH]: 'Hilarious',
  [ReactionType.MIND_BLOWN]: 'Mind Blown',
  [ReactionType.FIRE]: 'Spicy!',
  [ReactionType.SKIP]: 'Skip',
  [ReactionType.SAVE]: 'Save',
};
