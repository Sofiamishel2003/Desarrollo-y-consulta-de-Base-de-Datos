--6. ¿Quiénes son los jugadores de cada liga y cada temporada que tienen los mejores atributos – características de juego -pases, goles, etc.? ¿De acuerdo a este inciso, y comparándolo con el inciso 2 y 5 anteriores, alguno de los jugadores más valiosos se encuentra dentro del mejor equipo?--

WITH LeaderPlayers AS (
    SELECT
        g.season,
        g.league_id,
        a.player_id AS leader_player_id,
        ROW_NUMBER() OVER (PARTITION BY g.season, g.league_id ORDER BY SUM(a.goals) DESC, SUM(a.assists) DESC, SUM(a.key_passes) DESC) AS ranking
    FROM
        appearances a
    JOIN
        games g ON a.game_id = g.game_id
    GROUP BY
        g.season,
        g.league_id,
        a.player_id
)

SELECT
    lp.season,
    lp.league_id,
    lp.leader_player_id,
    p.name AS leader_player_name,
    l.name AS league_name,
    SUM(a.goals) AS total_goals,
    SUM(a.assists) AS total_assists,
    SUM(a.key_passes) AS total_key_passes
FROM
    LeaderPlayers lp
JOIN
    appearances a ON lp.leader_player_id = a.player_id
JOIN
    players p ON lp.leader_player_id = p.player_id
JOIN
    leagues l ON lp.league_id = l.league_id
WHERE
    lp.ranking = 1
GROUP BY
    lp.season,
    lp.league_id,
    lp.leader_player_id,
    p.name,
    l.name;

--7. Obtenga el rendimiento de los equipos en promedio, comparando goles metidos contra la expectativa de goles, determinando qué equipo era quien tenía más expectativa de goles contra quien fue en realidad el que acertó más goles (goals vs expected goals, xgoals) en general, pero también es necesario que lo muestre si dichos equipos jugaron como locales o como extranjeros.--

--Mayor expectativa de goles en promedio--

WITH TeamPerformance AS (
    SELECT
        ts.team_id,
        ts.location,
        AVG(ts.goals) AS avg_goals_scored,
        AVG(ts.xgoals) AS avg_expected_goals
    FROM
        teamstats ts
    GROUP BY
        ts.team_id,
        ts.location
),
GoalsExceeded AS (
    SELECT
        team_id,
        location,
        SUM(CASE WHEN goals > xgoals THEN 1 ELSE 0 END) AS goals_exceeded
    FROM
        teamstats
    GROUP BY
        team_id,
        location
)

SELECT
    tp.team_id,
    t.name AS team_name,
    tp.location,
    tp.avg_goals_scored,
    tp.avg_expected_goals,
    ge.goals_exceeded
FROM
    TeamPerformance tp
JOIN
    teams t ON tp.team_id = t.team_id
JOIN
    GoalsExceeded ge ON tp.team_id = ge.team_id AND tp.location = ge.location
ORDER BY
    tp.avg_expected_goals DESC
LIMIT 1;
--mayor cantidad de goles en promedio--

WITH TeamPerformance AS (
    SELECT
        ts.team_id,
        ts.location,
        AVG(ts.goals) AS avg_goals_scored,
        AVG(ts.xgoals) AS avg_expected_goals
    FROM
        teamstats ts
    GROUP BY
        ts.team_id,
        ts.location
),
GoalsExceeded AS (
    SELECT
        team_id,
        location,
        SUM(CASE WHEN goals > xgoals THEN 1 ELSE 0 END) AS goals_exceeded
    FROM
        teamstats
    GROUP BY
        team_id,
        location
)

SELECT
    tp.team_id,
    t.name AS team_name,
    tp.location,
    tp.avg_goals_scored,
    tp.avg_expected_goals,
    ge.goals_exceeded
FROM
    TeamPerformance tp
JOIN
    teams t ON tp.team_id = t.team_id
JOIN
    GoalsExceeded ge ON tp.team_id = ge.team_id AND tp.location = ge.location
ORDER BY
    tp.avg_goals_scored DESC
    --tp.avg_expected_goals DESC
LIMIT 1;

--8. ¿Cuáles son las características/atributos de los equipos que han sido los líderes de sus ligas en las distintas temporadas? ¿Sus comportamientos son similares?--

WITH LeaderTeams AS (
    SELECT
        ts.season,
        g.league_id,
        ts.team_id AS leader_team_id,
        ROW_NUMBER() OVER (PARTITION BY ts.season, g.league_id ORDER BY COUNT(ts.game_id) DESC) AS ranking
    FROM
        teamstats ts
    JOIN
        games g ON ts.game_id = g.game_id
    WHERE
        ts.result = 'W' 
    GROUP BY
        ts.season,
        g.league_id,
        ts.team_id
)

SELECT
    lt.season,
    lt.league_id,
    lt.leader_team_id,
    t.name AS leader_team_name,
    l.name AS league_name,
    SUM(ts.goals) AS total_goals,
    AVG(ts.xgoals) AS avg_xgoals,
    SUM(ts.shots) AS total_shots,
    SUM(ts.shots_on_target) AS total_shots_on_target,
    SUM(ts.deep) AS total_deep,
    AVG(ts.ppda) AS avg_ppda,
    SUM(ts.fouls) AS total_fouls,
    SUM(ts.corners) AS total_corners,
    SUM(ts.yellow_cards) AS total_yellow_cards,
    SUM(ts.red_cards) AS total_red_cards
FROM
    LeaderTeams lt
JOIN
    teamstats ts ON lt.season = ts.season AND lt.leader_team_id = ts.team_id
JOIN
    teams t ON lt.leader_team_id = t.team_id
JOIN
    leagues l ON lt.league_id = l.league_id
WHERE
    lt.ranking = 1 
GROUP BY
    lt.season,
    lt.league_id,
    lt.leader_team_id,
    t.name,
    l.name;

--9. ¿Según la casa de apuesta Beat365 (tome la mejor probabilidad de las 3 medidas), cuales deberían de ser los equipos que tenían la mayor probabilidad de ganar en cada una de las temporadas (seasons)?--

WITH RankedTeams AS (
    SELECT
        g.season,
        CASE
            WHEN MAX(g.B365H) >= MAX(g.B365A) THEN g.home_team_id
            ELSE g.away_team_id
        END AS team_id,
        GREATEST(MAX(g.B365H), MAX(g.B365A)) AS max_win_probability,
        ROW_NUMBER() OVER (PARTITION BY g.season ORDER BY GREATEST(MAX(g.B365H), MAX(g.B365A)) DESC) AS ranking
    FROM
        games g
    GROUP BY
        g.season,
		g.home_team_id,
		g.away_team_id
)

SELECT
    rt.season,
    rt.team_id,
    t.name AS team_name,
    rt.max_win_probability
FROM
    RankedTeams rt
JOIN
    teams t ON rt.team_id = t.team_id
WHERE
    rt.ranking = 1
ORDER BY
    rt.season;

-- 10. Obtenga el top 10 de estadísticas de los equipos más limpios en jugar (mejor faltas, menos tarjetas amarillas, menos tarjetas rojas) y también el top 10 de los equipos más sucios.--

--Equipos más limpios--

SELECT
    t.team_id,
    t.name AS team_name,
    SUM(ts.fouls) AS total_faltas,
    SUM(ts.yellow_cards) AS total_tarjetas_amarillas,
    SUM(ts.red_cards) AS total_tarjetas_rojas
FROM
    teamstats ts
JOIN
    teams t ON ts.team_id = t.team_id
GROUP BY
    t.team_id,
    t.name
ORDER BY
    total_faltas ASC,
    total_tarjetas_amarillas ASC,
    total_tarjetas_rojas ASC
LIMIT 10;

--Equipos más sucios--

SELECT
    t.team_id,
    t.name AS team_name,
    SUM(ts.fouls) AS total_faltas,
    SUM(ts.yellow_cards) AS total_tarjetas_amarillas,
    SUM(ts.red_cards) AS total_tarjetas_rojas
FROM
    teamstats ts
JOIN
    teams t ON ts.team_id = t.team_id
GROUP BY
    t.team_id,
    t.name
ORDER BY
    total_faltas DESC,
    total_tarjetas_amarillas DESC,
    total_tarjetas_rojas DESC
LIMIT 10;