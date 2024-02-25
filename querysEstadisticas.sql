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

WITH goal_details AS (
  SELECT
    g.league_id,
    g.season,
    g.home_team_id AS team_id,
    SUM(g.home_goals) AS goals_for,
    SUM(g.away_goals) AS goals_against,
    (SUM(g.home_goals) - SUM(g.away_goals)) AS goal_difference
  FROM
    games g
  GROUP BY
    g.league_id, g.season, g.home_team_id
  UNION ALL
  SELECT
    g.league_id,
    g.season,
    g.away_team_id AS team_id,
    SUM(g.away_goals) AS goals_for,
    SUM(g.home_goals) AS goals_against,
    (SUM(g.away_goals) - SUM(g.home_goals)) AS goal_difference
  FROM
    games g
  GROUP BY
    g.league_id, g.season, g.away_team_id
),
ranked_teams AS (
  SELECT
    league_id,
    season,
    team_id,
    SUM(goals_for) AS total_goals_for,
    SUM(goals_against) AS total_goals_against,
    SUM(goal_difference) AS total_goal_difference,
    RANK() OVER (
      PARTITION BY league_id, season
      ORDER BY SUM(goal_difference) DESC
    ) AS rank
  FROM
    goal_details
  GROUP BY
    league_id, season, team_id
)
SELECT
  r.league_id,
  l.name AS league_name,
  r.season,
  t.name AS team_name,
  r.total_goals_for,
  r.total_goals_against,
  r.total_goal_difference,
  r.rank
FROM
  ranked_teams r
JOIN
  teams t ON r.team_id = t.team_id
JOIN
  leagues l ON r.league_id = l.league_id
ORDER BY
  r.rank,l.name, r.season;



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


-- Jugadores con más goles realizados con el pie izquierdo y derecho
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

