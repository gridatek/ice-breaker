/**
 * Supabase Configuration
 * Manages environment variables and client initialization
 */

export interface SupabaseConfig {
  url: string;
  anonKey: string;
  options?: {
    auth?: {
      autoRefreshToken?: boolean;
      persistSession?: boolean;
      detectSessionInUrl?: boolean;
    };
    realtime?: {
      params?: {
        eventsPerSecond?: number;
      };
    };
  };
}

/**
 * Default Supabase configuration
 */
export const DEFAULT_SUPABASE_CONFIG: Partial<SupabaseConfig> = {
  options: {
    auth: {
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: true,
    },
    realtime: {
      params: {
        eventsPerSecond: 10,
      },
    },
  },
};

/**
 * Environment variable keys
 */
export const ENV_KEYS = {
  SUPABASE_URL: 'SUPABASE_URL',
  SUPABASE_ANON_KEY: 'SUPABASE_ANON_KEY',
} as const;

/**
 * Validate Supabase configuration
 */
export function validateSupabaseConfig(config: Partial<SupabaseConfig>): config is SupabaseConfig {
  if (!config.url) {
    console.error('Missing SUPABASE_URL in configuration');
    return false;
  }

  if (!config.anonKey) {
    console.error('Missing SUPABASE_ANON_KEY in configuration');
    return false;
  }

  // Validate URL format
  try {
    new URL(config.url);
  } catch {
    console.error('Invalid SUPABASE_URL format');
    return false;
  }

  return true;
}

/**
 * Get Supabase configuration from environment
 * This is a helper for apps to use, they should pass their own env vars
 */
export function getSupabaseConfigFromEnv(env: Record<string, string | undefined>): SupabaseConfig | null {
  const config: Partial<SupabaseConfig> = {
    url: env[ENV_KEYS.SUPABASE_URL],
    anonKey: env[ENV_KEYS.SUPABASE_ANON_KEY],
    ...DEFAULT_SUPABASE_CONFIG,
  };

  if (!validateSupabaseConfig(config)) {
    return null;
  }

  return config;
}
