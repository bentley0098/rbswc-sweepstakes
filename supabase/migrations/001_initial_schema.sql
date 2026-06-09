CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── participants ─────────────────────────────────────────────────────────────
CREATE TABLE participants (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name      TEXT NOT NULL,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── teams ───────────────────────────────────────────────────────────────────
CREATE TABLE teams (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  api_team_id  INTEGER NOT NULL UNIQUE,
  name         TEXT NOT NULL,
  country_code TEXT NOT NULL,
  flag_url     TEXT NOT NULL,
  fifa_rank    INTEGER NOT NULL,
  seed         INTEGER NOT NULL CHECK (seed BETWEEN 1 AND 4)
);

-- ─── draws ───────────────────────────────────────────────────────────────────
CREATE TABLE draws (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  participant_id UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  team_id        UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  drawn_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(participant_id, team_id),
  UNIQUE(team_id)
);

-- ─── matches ─────────────────────────────────────────────────────────────────
CREATE TABLE matches (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  api_fixture_id   INTEGER NOT NULL UNIQUE,
  home_team_api_id INTEGER NOT NULL,
  away_team_api_id INTEGER NOT NULL,
  home_score       INTEGER,
  away_score       INTEGER,
  stage            TEXT NOT NULL,
  match_date       TIMESTAMPTZ NOT NULL,
  status           TEXT NOT NULL DEFAULT 'NS',
  synced_at        TIMESTAMPTZ
);

-- ─── points_log ──────────────────────────────────────────────────────────────
CREATE TABLE points_log (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  participant_id UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  team_id        UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  match_id       UUID REFERENCES matches(id) ON DELETE SET NULL,
  event_type     TEXT NOT NULL,
  points         INTEGER NOT NULL,
  description    TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── app_state ───────────────────────────────────────────────────────────────
CREATE TABLE app_state (
  id                INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  draw_completed    BOOLEAN NOT NULL DEFAULT FALSE,
  participant_count INTEGER NOT NULL DEFAULT 0,
  last_sync_at      TIMESTAMPTZ,
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO app_state DEFAULT VALUES;

-- ─── Indexes ─────────────────────────────────────────────────────────────────
CREATE INDEX idx_draws_participant ON draws(participant_id);
CREATE INDEX idx_draws_team        ON draws(team_id);
CREATE INDEX idx_matches_stage     ON matches(stage);
CREATE INDEX idx_matches_status    ON matches(status);
CREATE INDEX idx_matches_date      ON matches(match_date);
CREATE INDEX idx_points_participant ON points_log(participant_id);
CREATE INDEX idx_points_match       ON points_log(match_id);

-- ─── Row Level Security ───────────────────────────────────────────────────────
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams        ENABLE ROW LEVEL SECURITY;
ALTER TABLE draws        ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches      ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_log   ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_state    ENABLE ROW LEVEL SECURITY;

-- Everyone can read
CREATE POLICY "public read participants" ON participants FOR SELECT USING (true);
CREATE POLICY "public read teams"        ON teams        FOR SELECT USING (true);
CREATE POLICY "public read draws"        ON draws        FOR SELECT USING (true);
CREATE POLICY "public read matches"      ON matches      FOR SELECT USING (true);
CREATE POLICY "public read points_log"   ON points_log   FOR SELECT USING (true);
CREATE POLICY "public read app_state"    ON app_state    FOR SELECT USING (true);

-- Anon key can only insert participants (join flow — code validated server-side)
CREATE POLICY "anon insert participants" ON participants FOR INSERT WITH CHECK (true);

-- All other writes go through server routes using service-role key (bypasses RLS)
