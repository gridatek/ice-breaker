/**
 * Authentication Service
 * Handles user authentication (for game hosts)
 */

import { getSupabase } from '../config/supabase-client';
import type { User, Session } from '@supabase/supabase-js';

export interface SignUpParams {
  email: string;
  password: string;
  displayName?: string;
}

export interface SignInParams {
  email: string;
  password: string;
}

/**
 * Sign up a new user
 */
export async function signUp(params: SignUpParams) {
  const supabase = getSupabase();

  const { data, error } = await supabase.auth.signUp({
    email: params.email,
    password: params.password,
    options: {
      data: {
        display_name: params.displayName,
      },
    },
  });

  return { data, error };
}

/**
 * Sign in existing user
 */
export async function signIn(params: SignInParams) {
  const supabase = getSupabase();

  const { data, error } = await supabase.auth.signInWithPassword({
    email: params.email,
    password: params.password,
  });

  return { data, error };
}

/**
 * Sign out current user
 */
export async function signOut() {
  const supabase = getSupabase();
  const { error } = await supabase.auth.signOut();
  return { error };
}

/**
 * Get current session
 */
export async function getSession(): Promise<Session | null> {
  const supabase = getSupabase();
  const { data } = await supabase.auth.getSession();
  return data.session;
}

/**
 * Get current user
 */
export async function getUser(): Promise<User | null> {
  const supabase = getSupabase();
  const { data } = await supabase.auth.getUser();
  return data.user;
}

/**
 * Listen to auth state changes
 */
export function onAuthStateChange(callback: (user: User | null) => void) {
  const supabase = getSupabase();

  const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
    callback(session?.user ?? null);
  });

  return subscription;
}
