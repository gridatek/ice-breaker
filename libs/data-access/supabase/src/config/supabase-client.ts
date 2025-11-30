/**
 * Supabase Client Instance
 * Singleton pattern for Supabase client
 */

import { createClient, SupabaseClient } from '@supabase/supabase-js';
import type { Database } from '@ice-breaker/shared-models';
import type { SupabaseConfig } from './supabase-config';

let supabaseInstance: SupabaseClient<Database> | null = null;

/**
 * Initialize Supabase client
 */
export function initializeSupabase(config: SupabaseConfig): SupabaseClient<Database> {
  if (supabaseInstance) {
    console.warn('Supabase client already initialized. Returning existing instance.');
    return supabaseInstance;
  }

  supabaseInstance = createClient<Database>(config.url, config.anonKey, config.options);

  return supabaseInstance;
}

/**
 * Get Supabase client instance
 * Throws if not initialized
 */
export function getSupabase(): SupabaseClient<Database> {
  if (!supabaseInstance) {
    throw new Error(
      'Supabase client not initialized. Call initializeSupabase() first.'
    );
  }

  return supabaseInstance;
}

/**
 * Check if Supabase is initialized
 */
export function isSupabaseInitialized(): boolean {
  return supabaseInstance !== null;
}

/**
 * Reset Supabase instance (useful for testing)
 */
export function resetSupabase(): void {
  supabaseInstance = null;
}
