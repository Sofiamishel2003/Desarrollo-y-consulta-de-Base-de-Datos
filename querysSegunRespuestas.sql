--4.  Realice un comparativo de las probabilidades--
WITH HighestOdds AS (
    SELECT 
        game_id,
        league_id,
        season,
        home_team_id,
        away_team_id,
        GREATEST(
            1 / NULLIF(B365H, 0), 
            1 / NULLIF(BWH, 0), 
            1 / NULLIF(IWH, 0), 
            1 / NULLIF(PSH, 0), 
            1 / NULLIF(WHH, 0), 
            1 / NULLIF(VCH, 0), 
            1 / NULLIF(PSCH, 0)
        ) AS highest_home_win_prob,
        GREATEST(
            1 / NULLIF(B365A, 0), 
            1 / NULLIF(BWA, 0), 
            1 / NULLIF(IWA, 0), 
            1 / NULLIF(PSA, 0), 
            1 / NULLIF(WHA, 0), 
            1 / NULLIF(VCA, 0), 
            1 / NULLIF(PSCA, 0)
        ) AS highest_away_win_prob
    FROM games
),
RankedProbabilities AS (
    SELECT 
        season,
        league_id,
        home_team_id AS team_id,
        'Home' AS location,
        highest_home_win_prob AS win_prob,
        RANK() OVER (PARTITION BY league_id, season ORDER BY highest_home_win_prob DESC) AS rank
    FROM HighestOdds
    UNION ALL
    SELECT 
        season,
        league_id,
        away_team_id AS team_id,
        'Away' AS location,
        highest_away_win_prob AS win_prob,
        RANK() OVER (PARTITION BY league_id, season ORDER BY highest_away_win_prob DESC) AS rank
    FROM HighestOdds
)
SELECT 
    t.name AS team_name,
    l.name AS league_name,
    r.season,
    r.location,
    r.win_prob,
    r.rank
FROM 
    RankedProbabilities r
JOIN 
    leagues l ON r.league_id = l.league_id
JOIN 
    teams t ON r.team_id = t.team_id
ORDER BY 
	r.rank,
    r.season, 
    l.name, 
    r.rank;
--5. ¿Cuál es el mejor equipo de todas las ligas y de todas las temporadas según las apuestas?--

WITH HighestOdds AS (
    SELECT 
        game_id,
        league_id,
        season,
        home_team_id,
        away_team_id,
        GREATEST(
            1 / NULLIF(B365H, 0), 
            1 / NULLIF(BWH, 0), 
            1 / NULLIF(IWH, 0), 
            1 / NULLIF(PSH, 0), 
            1 / NULLIF(WHH, 0), 
            1 / NULLIF(VCH, 0), 
            1 / NULLIF(PSCH, 0)
        ) AS highest_home_win_prob,
        GREATEST(
            1 / NULLIF(B365A, 0), 
            1 / NULLIF(BWA, 0), 
            1 / NULLIF(IWA, 0), 
            1 / NULLIF(PSA, 0), 
            1 / NULLIF(WHA, 0), 
            1 / NULLIF(VCA, 0), 
            1 / NULLIF(PSCA, 0)
        ) AS highest_away_win_prob
    FROM games
),
RankedProbabilities AS (
    SELECT 
        season,
        league_id,
        home_team_id AS team_id,
        'Home' AS location,
        highest_home_win_prob AS win_prob,
        RANK() OVER (PARTITION BY league_id, season ORDER BY highest_home_win_prob DESC) AS rank
    FROM HighestOdds
    UNION ALL
    SELECT 
        season,
        league_id,
        away_team_id AS team_id,
        'Away' AS location,
        highest_away_win_prob AS win_prob,
        RANK() OVER (PARTITION BY league_id, season ORDER BY highest_away_win_prob DESC) AS rank
    FROM HighestOdds
),
AverageWinProbabilities AS (
    SELECT 
        team_id,
        AVG(win_prob) AS average_win_prob
    FROM RankedProbabilities
    GROUP BY team_id
)
SELECT 
    t.name AS team_name,
    MAX(average_win_prob) AS max_average_win_prob
FROM 
    AverageWinProbabilities awp
JOIN 
    teams t ON awp.team_id = t.team_id
GROUP BY 
    t.name
ORDER BY 
    max_average_win_prob DESC
LIMIT 10;
