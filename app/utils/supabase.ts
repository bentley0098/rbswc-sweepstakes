import { createClient, type SupabaseClient } from '@supabase/supabase-js'
import type { Database } from '~/types/database'

let _client: SupabaseClient<Database> | null = null

export const useSupabase = (): SupabaseClient<Database> => {
  if (_client) return _client
  const config = useRuntimeConfig()
  _client = createClient<Database>(
    config.public.supabaseUrl,
    config.public.supabaseAnonKey
  )
  return _client
}
