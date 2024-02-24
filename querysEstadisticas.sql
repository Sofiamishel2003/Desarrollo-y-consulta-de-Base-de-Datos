--1. La cantidad de juegos jugados en cada temporada por cada equipo, de cada liga (tome en cuenta que cada equipo puede jugar como visitante o como anfitrión.--

SELECT league_id, season, team_id, COUNT(*) AS games_played
FROM (
    SELECT league_id, season, home_team_id AS team_id FROM games
    UNION ALL
    SELECT league_id, season, away_team_id AS team_id FROM games
) AS subquery
GROUP BY league_id, season, team_id
ORDER BY league_id, season, games_played DESC;
--2.¿Quién es el mejor equipo de todas las ligas y de todas las temporadas según las estadísticas de diferencia de goles?--

WITH team_scores AS (
    SELECT league_id, season, home_team_id AS team_id, home_goals AS goals_for, away_goals AS goals_against FROM games
    UNION ALL
    SELECT league_id, season, away_team_id AS team_id, away_goals AS goals_for, home_goals AS goals_against FROM games
),
goal_differences AS (
    SELECT league_id, season, team_id, SUM(goals_for) AS total_goals_for, SUM(goals_against) AS total_goals_against, 
    (SUM(goals_for) - SUM(goals_against)) AS goal_difference
    FROM team_scores
    GROUP BY league_id, season, team_id
)
SELECT league_id, season, team_id, total_goals_for, total_goals_against, goal_difference,
RANK() OVER (PARTITION BY league_id, season ORDER BY goal_difference DESC) AS rank
FROM goal_differences
ORDER BY league_id, season, rank;

--3.¿Quiénes son los jugadores que han realizado mayor cantidad de goles a través de todas las temporadas?--
-- Jugadores con más goles en todas las temporadas
SELECT player_id, SUM(goals) AS total_goals
FROM appearances
GROUP BY player_id
ORDER BY total_goals DESC;

-- Jugadores con más goles realizados con el pie izquierdo y derecho
SELECT 
    shooter_id AS player_id,
    SUM(CASE WHEN shot_type = 'LeftFoot' AND shot_result = 'Goal' THEN 1 ELSE 0 END) AS left_foot_goals,
    SUM(CASE WHEN shot_type = 'RightFoot' AND shot_result = 'Goal' THEN 1 ELSE 0 END) AS right_foot_goals
FROM shots
GROUP BY shooter_id
ORDER BY left_foot_goals DESC, right_foot_goals DESC;
