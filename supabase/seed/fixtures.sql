-- World Cup 2026 — Group Stage Fixtures (72 matches)
--
-- Run AFTER teams_update.sql (requires all 48 teams to exist).
-- api_fixture_id range 10001–10072 (synthetic — no TheSportsDB collision).
-- match_date is stored in UTC; times converted from worldcup_data.json UTC offsets.
-- status = 'NS' (not started) — enter results via the admin panel.
--
-- Team api_team_id reference:
--   134509 Argentina   133913 France      133914 England     134496 Brazil
--   133909 Spain       134515 Belgium     133908 Portugal    133905 Netherlands
--   133907 Germany     134501 Colombia    134504 Uruguay     134514 USA
--   133912 Croatia     136139 Morocco     134503 Japan       134506 Switzerland
--   135986 Austria     136143 Senegal     134517 S. Korea    134507 Ecuador
--   134497 Mexico      135985 Turkey      140073 Canada      134511 Iran
--   136137 Saudi Ara.  134500 Australia   134502 Ivory Coast 136471 Paraguay
--   136482 S. Africa   136450 Scotland    134516 Algeria     136475 DR Congo
--   134513 Ghana       140145 Jordan      140148 Iraq        137449 New Zealand
--   200001 Norway      200002 Sweden      200003 Czech Rep.  200004 Egypt
--   200005 Uzbekistan  200006 Bosnia&Herz 200007 Panama      200008 Tunisia
--   200009 Cape Verde  200010 Haiti       200011 Curaçao     200012 Qatar

INSERT INTO matches (api_fixture_id, home_team_api_id, away_team_api_id, stage, match_date, status) VALUES

-- ─── GROUP A: Mexico, South Korea, Czechia, South Africa ───────────────
(10001, 134497, 136482, 'Group Stage', '2026-06-11T19:00:00Z', 'NS'), -- Mexico vs South Africa
(10002, 134517, 200003, 'Group Stage', '2026-06-12T02:00:00Z', 'NS'), -- South Korea vs Czechia
(10003, 200003, 136482, 'Group Stage', '2026-06-18T16:00:00Z', 'NS'), -- Czechia vs South Africa
(10004, 134497, 134517, 'Group Stage', '2026-06-19T01:00:00Z', 'NS'), -- Mexico vs South Korea
(10005, 200003, 134497, 'Group Stage', '2026-06-25T01:00:00Z', 'NS'), -- Czechia vs Mexico
(10006, 136482, 134517, 'Group Stage', '2026-06-25T01:00:00Z', 'NS'), -- South Africa vs South Korea

-- ─── GROUP B: Canada, Bosnia & Herzegovina, Qatar, Switzerland ───────────────
(10007, 140073, 200006, 'Group Stage', '2026-06-12T19:00:00Z', 'NS'), -- Canada vs Bosnia & Herzegovina
(10008, 200012, 134506, 'Group Stage', '2026-06-13T19:00:00Z', 'NS'), -- Qatar vs Switzerland
(10009, 134506, 200006, 'Group Stage', '2026-06-18T19:00:00Z', 'NS'), -- Switzerland vs Bosnia & Herzegovina
(10010, 140073, 200012, 'Group Stage', '2026-06-18T22:00:00Z', 'NS'), -- Canada vs Qatar
(10011, 134506, 140073, 'Group Stage', '2026-06-24T19:00:00Z', 'NS'), -- Switzerland vs Canada
(10012, 200006, 200012, 'Group Stage', '2026-06-24T19:00:00Z', 'NS'), -- Bosnia & Herzegovina vs Qatar

-- ─── GROUP C: Brazil, Morocco, Haiti, Scotland ───────────────────────────────
(10013, 134496, 136139, 'Group Stage', '2026-06-13T22:00:00Z', 'NS'), -- Brazil vs Morocco
(10014, 200010, 136450, 'Group Stage', '2026-06-14T01:00:00Z', 'NS'), -- Haiti vs Scotland
(10015, 136450, 136139, 'Group Stage', '2026-06-19T22:00:00Z', 'NS'), -- Scotland vs Morocco
(10016, 134496, 200010, 'Group Stage', '2026-06-20T00:30:00Z', 'NS'), -- Brazil vs Haiti
(10017, 136450, 134496, 'Group Stage', '2026-06-24T22:00:00Z', 'NS'), -- Scotland vs Brazil
(10018, 136139, 200010, 'Group Stage', '2026-06-24T22:00:00Z', 'NS'), -- Morocco vs Haiti

-- ─── GROUP D: USA, Paraguay, Australia, Turkey ───────────────────────────────
(10019, 134514, 136471, 'Group Stage', '2026-06-13T01:00:00Z', 'NS'), -- USA vs Paraguay
(10020, 134500, 135985, 'Group Stage', '2026-06-14T04:00:00Z', 'NS'), -- Australia vs Turkey
(10021, 134514, 134500, 'Group Stage', '2026-06-19T19:00:00Z', 'NS'), -- USA vs Australia
(10022, 135985, 136471, 'Group Stage', '2026-06-20T03:00:00Z', 'NS'), -- Turkey vs Paraguay
(10023, 135985, 134514, 'Group Stage', '2026-06-26T02:00:00Z', 'NS'), -- Turkey vs USA
(10024, 136471, 134500, 'Group Stage', '2026-06-26T02:00:00Z', 'NS'), -- Paraguay vs Australia

-- ─── GROUP E: Germany, Curaçao, Ivory Coast, Ecuador ────────────────────────
(10025, 133907, 200011, 'Group Stage', '2026-06-14T17:00:00Z', 'NS'), -- Germany vs Curaçao
(10026, 134502, 134507, 'Group Stage', '2026-06-14T23:00:00Z', 'NS'), -- Ivory Coast vs Ecuador
(10027, 133907, 134502, 'Group Stage', '2026-06-20T20:00:00Z', 'NS'), -- Germany vs Ivory Coast
(10028, 134507, 200011, 'Group Stage', '2026-06-21T00:00:00Z', 'NS'), -- Ecuador vs Curaçao
(10029, 200011, 134502, 'Group Stage', '2026-06-25T20:00:00Z', 'NS'), -- Curaçao vs Ivory Coast
(10030, 134507, 133907, 'Group Stage', '2026-06-25T20:00:00Z', 'NS'), -- Ecuador vs Germany

-- ─── GROUP F: Netherlands, Japan, Sweden, Tunisia ────────────────────────────
(10031, 133905, 134503, 'Group Stage', '2026-06-14T20:00:00Z', 'NS'), -- Netherlands vs Japan
(10032, 200002, 200008, 'Group Stage', '2026-06-15T02:00:00Z', 'NS'), -- Sweden vs Tunisia
(10033, 133905, 200002, 'Group Stage', '2026-06-20T17:00:00Z', 'NS'), -- Netherlands vs Sweden
(10034, 200008, 134503, 'Group Stage', '2026-06-21T04:00:00Z', 'NS'), -- Tunisia vs Japan
(10035, 134503, 200002, 'Group Stage', '2026-06-25T23:00:00Z', 'NS'), -- Japan vs Sweden
(10036, 200008, 133905, 'Group Stage', '2026-06-25T23:00:00Z', 'NS'), -- Tunisia vs Netherlands

-- ─── GROUP G: Belgium, Egypt, Iran, New Zealand ──────────────────────────────
(10037, 134515, 200004, 'Group Stage', '2026-06-15T19:00:00Z', 'NS'), -- Belgium vs Egypt
(10038, 134511, 137449, 'Group Stage', '2026-06-16T01:00:00Z', 'NS'), -- Iran vs New Zealand
(10039, 134515, 134511, 'Group Stage', '2026-06-21T19:00:00Z', 'NS'), -- Belgium vs Iran
(10040, 137449, 200004, 'Group Stage', '2026-06-22T01:00:00Z', 'NS'), -- New Zealand vs Egypt
(10041, 200004, 134511, 'Group Stage', '2026-06-27T03:00:00Z', 'NS'), -- Egypt vs Iran
(10042, 137449, 134515, 'Group Stage', '2026-06-27T03:00:00Z', 'NS'), -- New Zealand vs Belgium

-- ─── GROUP H: Spain, Cape Verde, Saudi Arabia, Uruguay ───────────────────────
(10043, 133909, 200009, 'Group Stage', '2026-06-15T16:00:00Z', 'NS'), -- Spain vs Cape Verde
(10044, 136137, 134504, 'Group Stage', '2026-06-15T22:00:00Z', 'NS'), -- Saudi Arabia vs Uruguay
(10045, 133909, 136137, 'Group Stage', '2026-06-21T16:00:00Z', 'NS'), -- Spain vs Saudi Arabia
(10046, 134504, 200009, 'Group Stage', '2026-06-21T22:00:00Z', 'NS'), -- Uruguay vs Cape Verde
(10047, 200009, 136137, 'Group Stage', '2026-06-27T00:00:00Z', 'NS'), -- Cape Verde vs Saudi Arabia
(10048, 134504, 133909, 'Group Stage', '2026-06-27T00:00:00Z', 'NS'), -- Uruguay vs Spain

-- ─── GROUP I: France, Senegal, Iraq, Norway ──────────────────────────────────
(10049, 133913, 136143, 'Group Stage', '2026-06-16T19:00:00Z', 'NS'), -- France vs Senegal
(10050, 140148, 200001, 'Group Stage', '2026-06-16T22:00:00Z', 'NS'), -- Iraq vs Norway
(10051, 133913, 140148, 'Group Stage', '2026-06-22T21:00:00Z', 'NS'), -- France vs Iraq
(10052, 200001, 136143, 'Group Stage', '2026-06-23T00:00:00Z', 'NS'), -- Norway vs Senegal
(10053, 200001, 133913, 'Group Stage', '2026-06-26T19:00:00Z', 'NS'), -- Norway vs France
(10054, 136143, 140148, 'Group Stage', '2026-06-26T19:00:00Z', 'NS'), -- Senegal vs Iraq

-- ─── GROUP J: Argentina, Algeria, Austria, Jordan ────────────────────────────
(10055, 134509, 134516, 'Group Stage', '2026-06-17T01:00:00Z', 'NS'), -- Argentina vs Algeria
(10056, 135986, 140145, 'Group Stage', '2026-06-17T04:00:00Z', 'NS'), -- Austria vs Jordan
(10057, 134509, 135986, 'Group Stage', '2026-06-22T17:00:00Z', 'NS'), -- Argentina vs Austria
(10058, 140145, 134516, 'Group Stage', '2026-06-23T03:00:00Z', 'NS'), -- Jordan vs Algeria
(10059, 134516, 135986, 'Group Stage', '2026-06-28T02:00:00Z', 'NS'), -- Algeria vs Austria
(10060, 140145, 134509, 'Group Stage', '2026-06-28T02:00:00Z', 'NS'), -- Jordan vs Argentina

-- ─── GROUP K: Portugal, DR Congo, Uzbekistan, Colombia ───────────────────────
(10061, 133908, 136475, 'Group Stage', '2026-06-17T17:00:00Z', 'NS'), -- Portugal vs DR Congo
(10062, 200005, 134501, 'Group Stage', '2026-06-18T02:00:00Z', 'NS'), -- Uzbekistan vs Colombia
(10063, 133908, 200005, 'Group Stage', '2026-06-23T17:00:00Z', 'NS'), -- Portugal vs Uzbekistan
(10064, 134501, 136475, 'Group Stage', '2026-06-24T02:00:00Z', 'NS'), -- Colombia vs DR Congo
(10065, 134501, 133908, 'Group Stage', '2026-06-27T23:30:00Z', 'NS'), -- Colombia vs Portugal
(10066, 136475, 200005, 'Group Stage', '2026-06-27T23:30:00Z', 'NS'), -- DR Congo vs Uzbekistan

-- ─── GROUP L: England, Croatia, Ghana, Panama ────────────────────────────────
(10067, 133914, 133912, 'Group Stage', '2026-06-17T20:00:00Z', 'NS'), -- England vs Croatia
(10068, 134513, 200007, 'Group Stage', '2026-06-17T23:00:00Z', 'NS'), -- Ghana vs Panama
(10069, 133914, 134513, 'Group Stage', '2026-06-23T20:00:00Z', 'NS'), -- England vs Ghana
(10070, 200007, 133912, 'Group Stage', '2026-06-23T23:00:00Z', 'NS'), -- Panama vs Croatia
(10071, 200007, 133914, 'Group Stage', '2026-06-27T21:00:00Z', 'NS'), -- Panama vs England
(10072, 133912, 134513, 'Group Stage', '2026-06-27T21:00:00Z', 'NS'); -- Croatia vs Ghana
