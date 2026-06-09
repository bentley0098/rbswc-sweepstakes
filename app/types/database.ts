export type Stage =
  | 'Group Stage'
  | 'Round of 32'
  | 'Round of 16'
  | 'Quarter-finals'
  | 'Semi-finals'
  | 'Third Place'
  | 'Final'

export type EventType =
  | 'group_win'
  | 'group_draw'
  | 'round_of_32'
  | 'round_of_16'
  | 'quarter_final'
  | 'semi_final'
  | 'third_place'
  | 'runner_up'
  | 'winner'
  | 'upset_bonus'

export interface Participant {
  id: string
  name: string
  joined_at: string
}

export interface Team {
  id: string
  api_team_id: number
  name: string
  country_code: string
  flag_url: string
  fifa_rank: number
  seed: 1 | 2 | 3 | 4
}

export interface Draw {
  id: string
  participant_id: string
  team_id: string
  drawn_at: string
}

export interface Match {
  id: string
  api_fixture_id: number
  home_team_api_id: number
  away_team_api_id: number
  home_score: number | null
  away_score: number | null
  stage: Stage
  match_date: string
  status: string
  synced_at: string | null
}

export interface PointsLog {
  id: string
  participant_id: string
  team_id: string
  match_id: string | null
  event_type: EventType
  points: number
  description: string | null
  created_at: string
}

export interface AppState {
  id: 1
  draw_completed: boolean
  participant_count: number
  last_sync_at: string | null
  updated_at: string
}

export interface LeaderboardEntry {
  participant: Participant
  teams: Team[]
  totalPoints: number
}

export type Database = {
  public: {
    Tables: {
      participants: {
        Row: Participant
        Insert: { id?: string; name: string; joined_at?: string }
        Update: Partial<Omit<Participant, 'id'>>
      }
      teams: {
        Row: Team
        Insert: Omit<Team, 'id'> & { id?: string }
        Update: Partial<Omit<Team, 'id'>>
      }
      draws: {
        Row: Draw
        Insert: { id?: string; participant_id: string; team_id: string; drawn_at?: string }
        Update: Partial<Omit<Draw, 'id'>>
      }
      matches: {
        Row: Match
        Insert: Omit<Match, 'id'> & { id?: string }
        Update: Partial<Omit<Match, 'id'>>
      }
      points_log: {
        Row: PointsLog
        Insert: Omit<PointsLog, 'id' | 'created_at'> & { id?: string; created_at?: string }
        Update: Partial<Omit<PointsLog, 'id'>>
      }
      app_state: {
        Row: AppState
        Insert: Partial<AppState>
        Update: Partial<Omit<AppState, 'id'>>
      }
    }
    Views: Record<string, never>
    Functions: Record<string, never>
    Enums: Record<string, never>
  }
}
