/**
 * Error Handling Utilities
 */

import type { GameError } from '@ice-breaker/shared-models';

/**
 * Map Supabase error to user-friendly message
 */
export function mapSupabaseError(error: any): GameError {
  const message = error?.message || 'An unexpected error occurred';
  const code = error?.code;

  // Map common Supabase errors to friendly messages
  const errorMap: Record<string, string> = {
    'PGRST116': 'Not found',
    '23505': 'This value already exists',
    '23503': 'Related record not found',
    '42501': 'Permission denied',
    'PGRST301': 'Invalid request',
  };

  const friendlyMessage = code && errorMap[code] ? errorMap[code] : message;

  return {
    message: friendlyMessage,
    code,
    details: error,
  };
}

/**
 * Check if error is a network error
 */
export function isNetworkError(error: any): boolean {
  return (
    error?.message?.includes('fetch') ||
    error?.message?.includes('network') ||
    error?.status === 0
  );
}

/**
 * Check if error is an auth error
 */
export function isAuthError(error: any): boolean {
  return error?.status === 401 || error?.code === '42501';
}

/**
 * Check if error is a validation error
 */
export function isValidationError(error: any): boolean {
  return error?.code?.startsWith('23') || error?.code === 'PGRST301';
}
