-- World Cup 2026 — 48 Teams Seed Data
--
-- Rankings sourced from ESPN: "All 48 national teams ranked by chance to win"
-- https://www.espn.co.uk/football/story/_/id/48941820/...
--
-- Seed 1 = ESPN ranks 1–12 (favourites), Seed 4 = ranks 37–48 (underdogs).
-- api_team_id: TheSportsDB IDs where known; 200001–200012 synthetic for new qualifiers.

INSERT INTO teams (api_team_id, name, country_code, flag_url, fifa_rank, seed) VALUES

-- ─── SEED 1 (ESPN ranks 1–12) ─────────────────────────────────────────────────
(133913, 'France',       'fr',     'https://flagcdn.com/w40/fr.png',     1,  1),
(133909, 'Spain',        'es',     'https://flagcdn.com/w40/es.png',     2,  1),
(133914, 'England',      'gb-eng', 'https://flagcdn.com/w40/gb-eng.png', 3,  1),
(133908, 'Portugal',     'pt',     'https://flagcdn.com/w40/pt.png',     4,  1),
(133907, 'Germany',      'de',     'https://flagcdn.com/w40/de.png',     5,  1),
(134496, 'Brazil',       'br',     'https://flagcdn.com/w40/br.png',     6,  1),
(134509, 'Argentina',    'ar',     'https://flagcdn.com/w40/ar.png',     7,  1),
(133905, 'Netherlands',  'nl',     'https://flagcdn.com/w40/nl.png',     8,  1),
(200001, 'Norway',       'no',     'https://flagcdn.com/w40/no.png',     9,  1),
(135985, 'Türkiye',      'tr',     'https://flagcdn.com/w40/tr.png',     10, 1),
(136143, 'Senegal',      'sn',     'https://flagcdn.com/w40/sn.png',     11, 1),
(134515, 'Belgium',      'be',     'https://flagcdn.com/w40/be.png',     12, 1),

-- ─── SEED 2 (ESPN ranks 13–24) ────────────────────────────────────────────────
(134504, 'Uruguay',      'uy',     'https://flagcdn.com/w40/uy.png',     13, 2),
(136139, 'Morocco',      'ma',     'https://flagcdn.com/w40/ma.png',     14, 2),
(134507, 'Ecuador',      'ec',     'https://flagcdn.com/w40/ec.png',     15, 2),
(133912, 'Croatia',      'hr',     'https://flagcdn.com/w40/hr.png',     16, 2),
(134502, 'Ivory Coast',  'ci',     'https://flagcdn.com/w40/ci.png',     17, 2),
(134501, 'Colombia',     'co',     'https://flagcdn.com/w40/co.png',     18, 2),
(134506, 'Switzerland',  'ch',     'https://flagcdn.com/w40/ch.png',     19, 2),
(200002, 'Sweden',       'se',     'https://flagcdn.com/w40/se.png',     20, 2),
(134503, 'Japan',        'jp',     'https://flagcdn.com/w40/jp.png',     21, 2),
(134514, 'United States','us',     'https://flagcdn.com/w40/us.png',     22, 2),
(135986, 'Austria',      'at',     'https://flagcdn.com/w40/at.png',     23, 2),
(134497, 'Mexico',       'mx',     'https://flagcdn.com/w40/mx.png',     24, 2),

-- ─── SEED 3 (ESPN ranks 25–36) ────────────────────────────────────────────────
(140073, 'Canada',       'ca',     'https://flagcdn.com/w40/ca.png',     25, 3),
(134516, 'Algeria',      'dz',     'https://flagcdn.com/w40/dz.png',     26, 3),
(136471, 'Paraguay',     'py',     'https://flagcdn.com/w40/py.png',     27, 3),
(136450, 'Scotland',     'gb-sct', 'https://flagcdn.com/w40/gb-sct.png', 28, 3),
(200003, 'Czechia',      'cz',     'https://flagcdn.com/w40/cz.png',     29, 3),
(134517, 'South Korea',  'kr',     'https://flagcdn.com/w40/kr.png',     30, 3),
(200004, 'Egypt',        'eg',     'https://flagcdn.com/w40/eg.png',     31, 3),
(134500, 'Australia',    'au',     'https://flagcdn.com/w40/au.png',     32, 3),
(136475, 'Congo DR',     'cd',     'https://flagcdn.com/w40/cd.png',     33, 3),
(200005, 'Uzbekistan',   'uz',     'https://flagcdn.com/w40/uz.png',     34, 3),
(134511, 'Iran',         'ir',     'https://flagcdn.com/w40/ir.png',     35, 3),
(134513, 'Ghana',        'gh',     'https://flagcdn.com/w40/gh.png',     36, 3),

-- ─── SEED 4 (ESPN ranks 37–48) ────────────────────────────────────────────────
(200006, 'Bosnia & Herzegovina', 'ba', 'https://flagcdn.com/w40/ba.png', 37, 4),
(200007, 'Panama',       'pa',     'https://flagcdn.com/w40/pa.png',     38, 4),
(200008, 'Tunisia',      'tn',     'https://flagcdn.com/w40/tn.png',     39, 4),
(140145, 'Jordan',       'jo',     'https://flagcdn.com/w40/jo.png',     40, 4),
(137449, 'New Zealand',  'nz',     'https://flagcdn.com/w40/nz.png',     41, 4),
(140148, 'Iraq',         'iq',     'https://flagcdn.com/w40/iq.png',     42, 4),
(200009, 'Cape Verde',   'cv',     'https://flagcdn.com/w40/cv.png',     43, 4),
(136137, 'Saudi Arabia', 'sa',     'https://flagcdn.com/w40/sa.png',     44, 4),
(200010, 'Haiti',        'ht',     'https://flagcdn.com/w40/ht.png',     45, 4),
(136482, 'South Africa', 'za',     'https://flagcdn.com/w40/za.png',     46, 4),
(200011, 'Curaçao',      'cw',     'https://flagcdn.com/w40/cw.png',     47, 4),
(200012, 'Qatar',        'qa',     'https://flagcdn.com/w40/qa.png',     48, 4);
