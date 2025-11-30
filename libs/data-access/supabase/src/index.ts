/**
 * @ice-breaker/data-access-supabase
 * Supabase client and services for IceBreaker game
 */

// Configuration
export * from './config/supabase-config';
export * from './config/supabase-client';

// Services
export * from './services/game.service';
export * from './services/realtime.service';
export * from './services/auth.service';

// Utils
export * from './utils/error-handler';
