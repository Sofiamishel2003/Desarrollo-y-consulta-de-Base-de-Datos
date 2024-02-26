--1. La cantidad de juegos jugados en cada temporada por cada equipo, de cada liga (tome en cuenta que cada equipo puede jugar como visitante o como anfitrión.--
SELECT 
    t.name AS team_name,
    l.name AS league_name,
    g.season,
    COUNT(*) AS games_played
FROM 
    games g
JOIN 
    teams t ON g.home_team_id = t.team_id OR g.away_team_id = t.team_id
JOIN 
    leagues l ON g.league_id = l.league_id
GROUP BY 
    l.name, t.name, g.season
ORDER BY 
     games_played DESC; 
--2.¿Quién es el mejor equipo de todas las ligas y de todas las temporadas según las estadísticas de diferencia de goles?--
--Mejor de todas las ligas
WITH LeagueRankings AS (
    SELECT
        l.name AS league_name,
        t.name AS team_name,
        SUM(CASE WHEN g.home_team_id = t.team_id THEN g.home_goals ELSE g.away_goals END) AS goals_for,
        SUM(CASE WHEN g.home_team_id = t.team_id THEN g.away_goals ELSE g.home_goals END) AS goals_against,
        SUM(CASE WHEN g.home_team_id = t.team_id THEN g.home_goals - g.away_goals ELSE g.away_goals - g.home_goals END) AS goal_difference,
        RANK() OVER (PARTITION BY l.name ORDER BY SUM(CASE WHEN g.home_team_id = t.team_id THEN g.home_goals - g.away_goals ELSE g.away_goals - g.home_goals END) DESC) AS league_rank
    FROM
        teams t
    JOIN
        games g ON g.home_team_id = t.team_id OR g.away_team_id = t.team_id
    JOIN
        leagues l ON g.league_id = l.league_id
    GROUP BY
        l.name, t.name
)
SELECT
    league_name,
    team_name,
    goals_for,
    goals_against,
    goal_difference
FROM
    LeagueRankings
WHERE
    league_rank = 1
ORDER BY
    goal_difference DESC,league_name;
--Mejor de todas las temporadas
WITH SeasonalRankings AS (
    SELECT
        l.name AS league_name,
        t.name AS team_name,
        g.season,
        SUM(CASE WHEN g.home_team_id = t.team_id THEN g.home_goals ELSE g.away_goals END) AS goals_for,
        SUM(CASE WHEN g.home_team_id = t.team_id THEN g.away_goals ELSE g.home_goals END) AS goals_against,
        (SUM(CASE WHEN g.home_team_id = t.team_id THEN g.home_goals ELSE g.away_goals END) - SUM(CASE WHEN g.home_team_id = t.team_id THEN g.away_goals ELSE g.home_goals END)) AS goal_difference,
        RANK() OVER (PARTITION BY g.season, l.league_id ORDER BY (SUM(CASE WHEN g.home_team_id = t.team_id THEN g.home_goals ELSE g.away_goals END) - SUM(CASE WHEN g.home_team_id = t.team_id THEN g.away_goals ELSE g.home_goals END)) DESC) AS ranking
    FROM
        games g
    JOIN
        teams t ON g.home_team_id = t.team_id OR g.away_team_id = t.team_id
    JOIN
        leagues l ON g.league_id = l.league_id
    GROUP BY
        g.season, l.league_id, t.name
)
SELECT
    league_name,
    team_name,
    season,
    goals_for,
    goals_against,
    goal_difference
FROM
    SeasonalRankings
WHERE
    ranking = 1
ORDER BY
    goal_difference DESC, league_name;


--3.¿Quiénes son los jugadores que han realizado mayor cantidad de goles a través de todas las temporadas?--
-- Jugadores con más goles en todas las temporadas
SELECT
    a.player_id,
    p.name AS player_name,
    SUM(a.goals) AS total_goals
FROM appearances a
JOIN players p ON a.player_id = p.player_id
GROUP BY a.player_id, p.name
ORDER BY total_goals DESC;


-- Jugadores con más goles realizados con el pie derecho
SELECT 
    p.name,
    SUM(CASE WHEN s.shot_type = 'RightFoot' AND s.shot_result = 'Goal' THEN 1 ELSE 0 END) AS right_foot_assists
FROM 
    shots s
JOIN 
    players p ON s.assister_id = p.player_id
WHERE 
    s.shot_result = 'Goal' AND s.last_action = 'Pass'
GROUP BY 
    p.name
ORDER BY 
    right_foot_assists DESC;
--Jugadores con más goles realizados con el pie izquierdo 
SELECT 
    p.name,
    SUM(CASE WHEN s.shot_type = 'LeftFoot' AND s.shot_result = 'Goal' THEN 1 ELSE 0 END) AS left_foot_assists
FROM 
    shots s
JOIN 
    players p ON s.assister_id = p.player_id
WHERE 
    s.shot_result = 'Goal' AND s.last_action = 'Pass'
GROUP BY 
    p.name
ORDER BY 
    left_foot_assists DESC;
--Jugadores con más goles realizados con el pie izquierdo  y derecho

SELECT 
    p.name,
    SUM(CASE WHEN s.shot_type = 'RightFoot' AND s.shot_result = 'Goal' THEN 1 ELSE 0 END) AS right_foot_assists,
    SUM(CASE WHEN s.shot_type = 'LeftFoot' AND s.shot_result = 'Goal' THEN 1 ELSE 0 END) AS left_foot_assists
FROM 
    shots s
JOIN 
    players p ON s.assister_id = p.player_id
WHERE 
    s.shot_result = 'Goal' AND s.last_action = 'Pass'
GROUP BY 
    p.name
ORDER BY 
    right_foot_assists DESC, left_foot_assists DESC;
