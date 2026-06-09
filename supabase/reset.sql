-- ─── FULL RESET ──────────────────────────────────────────────────────────────
-- Clears all user data, scores, points, and draws.
-- Teams and group-stage fixtures are preserved exactly as seeded.
--
-- HOW TO RUN:
--   1. Open your Supabase project → SQL Editor
--   2. Paste this entire file and click Run
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;

-- 1. Wipe all awarded points
DELETE FROM points_log;

-- 2. Wipe team assignments
DELETE FROM draws;

-- 3. Wipe participants (cascades to draws, but draws already cleared above)
DELETE FROM participants;

-- 4. Reset group-stage match scores (keep the fixture schedule intact)
UPDATE matches
SET home_score = NULL,
    away_score = NULL,
    status     = 'NS',
    synced_at  = NULL
WHERE stage = 'Group Stage';

-- 5. Remove any manually-added knockout matches
DELETE FROM matches
WHERE stage != 'Group Stage';

-- 6. Reset app state
UPDATE app_state
SET draw_completed    = FALSE,
    participant_count = 0,
    last_sync_at      = NULL,
    updated_at        = NOW()
WHERE id = 1;

COMMIT;
